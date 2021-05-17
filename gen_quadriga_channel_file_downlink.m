function [H_ue, H_in] = gen_quadriga_channel_file_downlink(par, nbr_of_RB, nbr_of_ue, nbr_of_in, cluster_num, fname, new_generate) % check if result same
    % Example:
    %       [H_ue, H_in, lay] = gen_quadriga_channel_file(4, 8, 8, 1);

    %%%%% CHECK SAVE REQUIRED OR NOT
    dir_name = 'ch_files';

    if exist('fname', 'var')
        full_path = [dir_name filesep fname];
        do_save = true;
    else
        do_save = false;
    end

    if exist('new_generate', 'var') && new_generate == true
        do_save = false;
    end

    %%%%% LOAD OR GENERATE CHANNEL INFORMATION
    if do_save && isfile(full_path)
        res = load(full_path);
        H_ue = res.res.H_ue;
        H_in = res.res.H_in;
    else

        % fixed parameters
        s = qd_simulation_parameters; % new simulation parameters
        s.center_frequency = 4.9e9; % 4.9 GHz carrier frequency
        s.use_absolute_delays = 0; % exclude delay of the LOS path
        s.samples_per_meter = 2; % 2 samples
        s.show_progress_bars = 1; % enable progress bars
        s.use_3GPP_baseline = 1; % disable extra features not specified by 3GPP
        s.use_random_initial_phase = 1;
        s.autocorrelation_function = 'Comb300';

        % fixed transmitter setup
        layout = qd_layout(s); % create new QuaDRiGa layout
        M = 4; % number of vertical pendulums per channel
        N = 1; % number of horizontal pendulums per channel
        pol = 6; % +/- 45 degree polarized elements
        tilt = 15;
        spacing = 0.67; % spacing between vertical pendulums: 0.67 times the wavelength
        Ng = 16; % number of horizontal channels
        Mg = B / Ng / 2; % number of vertical channels
        dgv = 2.68; % spacing between adjecent vertical channels
        dgh = 0.5; % spacing between adjecent horizontal channels
        layout.no_tx = 1;
        layout.tx_array = qd_arrayant('3gpp-mmw', M, N, ...
            s.center_frequency, pol, tilt, spacing, ...
            Mg, Ng, dgv, dgh); % using 3gpp-mmw antenna model
        rotation_angle = 30;
        layout.tx_array.rotate_pattern(30, 'y'); % turn it right
        layout.tx_position(3) = 25; % tx elevated to 25m

        % receivers setup
        UMin = 'WINNER_UMi_B1_NLOS'; % NLOS scenario name
        layout.no_rx = nbr_of_ue + nbr_of_in; % 2 groups of receiver
        ue_ant = 'xpol4';
        layout.rx_array = qd_arrayant(ue_ant); % Huawei customized antenna
        track_len = 1;

        for rx = 1:layout.no_rx
            index = mod(rx - 1, nbr_of_ue) + 1;
            loc_angle = (-1)^(index + 1) * (5 + (index -1 - mod(index - 1, 2)) * 5);
            loc_angle_rad = deg2rad(loc_angle);
            radius = layout.tx_position(3) / tan(deg2rad(rotation_angle));

            position = [...
                        cos(loc_angle_rad) * radius; ...
                        sin(loc_angle_rad) * radius; ...
                        1.5; ...
                        ];

            motion_direction = 2 * pi * rand; % random motion_direction

            layout.rx_track(1, rx) = qd_track('linear', track_len, motion_direction);
            layout.rx_track(1, rx).initial_position = position;
            layout.rx_track(1, rx).segment_index = 1; % segments
            layout.rx_track(1, rx).scenario = {UMin}; % scenarios
            layout.rx_track(1, rx).name = ['Rx' num2str(rx)];
        end

        % finalize the track setup
        interpolate_positions(layout.rx_track, s.samples_per_meter); % interpolate
        calc_orientation(layout.rx_track); % align antenna motion_direction with track

        % generate the channel
        parms = layout.init_builder; % create channel builders
        gen_parameters(parms); % generate small-scale fading
        channel = get_channels(parms); % generate channel coefficients
        ch_merged = merge(channel); % merge segments of different senarios

        if pol == 6
            nbr_bs_pol = 2;
        else
            nbr_bs_pol = 1;
        end

        if strcmp(ue_ant, 'xpol4')
            nbr_ue_pol = 4;
        else
            nbr_ue_pol = 1;
        end

        subc_freq = 3e4; % half of subcarrier frequency: 30KHz
        rb_subc = 12;
        nbr_tx_ant = Mg * Ng * nbr_bs_pol;
        subc_num = nbr_of_RB * rb_subc; % number of subcarriers

        %%%%% prepare for waveform selection
        nbr_horizon = Ng;
        nbr_vertical = Mg;

        % get H
        H = zeros(nbr_tx_ant, layout.no_rx, subc_num, nbr_ue_pol);

        for rx = 1:layout.no_rx
            ch = ch_merged(1, rx).fr(subc_freq * subc_num, subc_num);
            % convert to `H` dimension: #tx_antenna, #ue, #subcarrier, #ue_antenna
            H(:, rx, :, :) = permute(ch(:, :, :, 2), [2, 4, 3, 1]); % using 2nd sample
        end

        % H's normalization
        for u = 1:layout.no_rx
            norm_fac = sqrt(mean(abs(H(:, u, :, :)).^2, 'all')); % normalization for per user's channel, to make tr(H_k H_k^H)=N_k*M

            for ue_ant = 1:nbr_ue_pol
                H(:, u, :, ue_ant) = H(:, u, :, ue_ant) / norm_fac;
            end

        end

        H_permuted = permute(H, [4, 1, 3, 2]); % H_ue dimension: #ue_antenna, #tx_antenna, #subcarrier, #ue
        H_ue = H_permuted(:, :, :, 1:nbr_of_ue);
        H_in = H_permuted(:, :, :, nbr_of_ue + 1:layout.no_rx); % no using in downlink

        if do_save
            mkdir(dir_name);
            res.H_ue = H_ue;
            res.H_in = H_in;
            save(full_path, 'res');
        end

    end

end
