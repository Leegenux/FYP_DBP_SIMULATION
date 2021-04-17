function [par, res_list] = DBP_detector_sim(varargin)
    % -- set up default/custom parameters
    if isempty(varargin)
        disp('using default simulation settings and parameters...')
        % set default simulation parameters
        par = config();
    else
        disp('use custom simulation settings and parameters...');
        par = varargin{1}; % the only argument is par structure
    end

    %%%%% SIMULATION INITIALIZATION
    par = simulation_init(par);
    ber_plot_data = plot_data_init(1);
    ber_plot_data.title = ['BER, ', num2str(par.B) ' antennas, ' num2str(par.C) ' clusters, ' num2str(par.U) ' users'];
    emse_plot_data = plot_data_init(2);
    emse_plot_data.title = ['Empirical MSE, ', num2str(par.B) ' antennas, ' num2str(par.C) ' clusters, ' num2str(par.U) ' users'];
    tmse_plot_data = plot_data_init(3);
    tmse_plot_data.title = ['Theoretical MSE, ', num2str(par.B) ' antennas, ' num2str(par.C) ' clusters, ' num2str(par.U) ' users'];

    % dimensions: #bs_antenna, #UE, #sub_c
    res_list = cell(length(par.detector), 1);

    for method_idx = 1:length(par.detector)
        cur_method = par.detector{method_idx};
        res_list{method_idx} = res_init(par.SNRdB_list, cur_method, par.maxiter_limit);
    end

    time_elapsed = timer_start();

    for trial = 1:par.CH_trials

        if par.quadriga
            ch_fname = ['uplink_runID_' num2str(par.runID) ...
                        '_B_' num2str(par.B) ...
                        '_ue_' num2str(par.nbr_of_ue) ...
                        '_in_' num2str(par.nbr_of_in) ...
                        '_CH_trial_' num2str(trial) ...
                        '.mat'];
            % generate channel for 4RB
            [H_up_ue, H_up_in] = gen_quadriga_channel_file(par.B, par.nbr_of_RB, par.nbr_of_ue, par.nbr_of_in, ch_fname, par.new_generate);
            % layout.visualize;
        else
            H_up_ue = sqrt(0.5) * (randn(par.B, par.nbr_of_ue, par.nbr_of_subc) + 1j * randn(par.B, par.nbr_of_ue, par.nbr_of_subc));
            H_up_in = sqrt(0.5) * (randn(par.B, par.nbr_of_ue, par.nbr_of_subc) + 1j * randn(par.B, par.nbr_of_ue, par.nbr_of_subc));
        end

        % random loop under same channel for different 4RB
        for RB_trial = 1:par.RB_trials
            % primary user transmits
            % `ue_symbols` dimensions: #UE, #symbol, #sub_c
            [ue_bits, ~, ue_symbols] = random_transmits(par.nbr_of_ue, par.Q, par.nbr_of_subc, par.nbr_of_sym, par.symbols);
            % mask out those UE symbols during Reference Signal symbols
            ue_symbols(:, par.rs_syms, :) = 0;

            % `ue_transmits` dimensions: #sub_c, #bs_antenna, #symbol
            ue_transmits = zeros(par.nbr_of_subc, par.B, par.nbr_of_sym);

            for subc = 1:par.nbr_of_subc
                ue_transmits(subc, :, :) = H_up_ue(:, :, subc) * ue_symbols(:, :, subc);
            end

            % primary interference whose modulus are equal to 1
            % `in_transmits` dimensions: #sub_c, #bs_antenna, #symbol
            [~, ~, in_symbols] = random_transmits(par.nbr_of_in, par.Q, par.nbr_of_subc, par.nbr_of_sym, par.symbols);

            in_transmits = zeros(par.nbr_of_subc, par.B, par.nbr_of_sym);

            for subc = 1:par.nbr_of_subc
                in_transmits(subc, :, :) = H_up_in(:, :, subc) * in_symbols(:, :, subc);
            end

            % background noise: Gaussian white noise with power of 1
            noise = sqrt(0.5) * (randn(par.nbr_of_subc, par.B, par.nbr_of_sym) + 1j * randn(par.nbr_of_subc, par.B, par.nbr_of_sym));

            %%%%% ESTIMATION OF Ruu
            % estimate Ruu and transmit UE symbol under different SNR
            ue_sym_power = par.Es; % average signal power per receive antenna
            in_sym_power = par.Ei; % average interference power per receive antenna
            no_power = 1;

            len_SNR_list = length(par.SNRdB_list);
            bs_receive = cell(len_SNR_list, 1);
            ue_factor_list = cell(len_SNR_list, 1);
            Ruu_list = cell(len_SNR_list, 1);
            Ruu_real_list = cell(len_SNR_list);

            for m = 1:len_SNR_list
                % FORMULA 1: par.IoT = 10 lg((in + noise) / noise);
                total_EiN0_ratio = 10^(par.IoT / 10) - 1;
                sub_EiN0_ratio = total_EiN0_ratio / par.nbr_of_in;
                in_factor = sqrt(sub_EiN0_ratio * no_power / in_sym_power);
                % FORMULA 2: SNR (Es/N0) = 10 lg(ue / noise)
                EsN0_ratio = 10^(par.SNRdB_list(m) / 10);
                ue_factor_list{m} = sqrt(EsN0_ratio * no_power / ue_sym_power);

                % `bs_receive{m}` dimensions: #subc, #bs_antenna, #symbol
                bs_receive{m} = ue_transmits * ue_factor_list{m} + in_transmits * in_factor + noise;

                Ruu = zeros(par.B);

                if par.estimate_Ruu
                    % estimate Ruu using 4*48 U
                    for t = par.rs_syms
                        Ruu = Ruu + transpose(squeeze(bs_receive{m}(:, :, t))) * conj(squeeze(bs_receive{m}(:, :, t)));
                    end

                    Ruu_list{m} = Ruu / (par.nbr_of_subc * length(par.rs_syms));

                    if par.diag_load
                        Ruu_list{m} = Ruu_list{m} + no_power * eye(par.B);
                    end

                    % calculate real Ruu
                    for subc = 1:par.nbr_of_subc
                        Ruu = Ruu + in_factor^2 * squeeze(H_up_in(:, :, subc)) * squeeze(H_up_in(:, :, subc))';
                    end

                    Ruu_real_list{m} = Ruu / par.nbr_of_subc + no_power * eye(par.B);
                else
                    % quadriga channel when Ruu accurate(eatimate by 48 HH' average and noise)
                    for subc = 1:par.nbr_of_subc
                        Ruu = Ruu + in_factor^2 * squeeze(H_up_in(:, :, subc)) * squeeze(H_up_in(:, :, subc))';
                    end

                    Ruu_list{m} = Ruu / par.nbr_of_subc + no_power * eye(par.B);
                    Ruu_real_list = Ruu_list;
                end

            end

            %%%%% EQUALIZATION OF METHODS
            % method loops
            for method_idx = 1:length(par.detector)
                cur_method = par.detector{method_idx};

                % initialize per-vector, per symbol and per-bit error rate results
                method_res = res_init(par.SNRdB_list, cur_method, par.maxiter_limit);
                [method, ~, ~] = name_to_method(cur_method);

                method_res = simulation_loops(par, method_res, Ruu_list, Ruu_real_list, ue_factor_list, bs_receive, H_up_ue, ue_symbols, ue_bits, method);
                method_res.BER = res_list{method_idx}.BER + method_res.BER;
                method_res.EMSE = res_list{method_idx}.EMSE + method_res.EMSE;
                method_res.TMSE = res_list{method_idx}.TMSE + method_res.TMSE;

                % gather results
                res_list{method_idx} = method_res;
            end

            time_elapsed = timer_progress(time_elapsed, par.CH_trials * par.RB_trials, ...
                (trial - 1) * par.RB_trials + RB_trial);

        end

    end

    timer_stop(time_elapsed);

    for method_idx = 1:length(par.detector)
        res_list{method_idx}.BER = res_list{method_idx}.BER / (par.RB_trials * par.CH_trials);
        res_list{method_idx}.EMSE = res_list{method_idx}.EMSE / (par.RB_trials * par.CH_trials);
        res_list{method_idx}.TMSE = res_list{method_idx}.TMSE / (par.RB_trials * par.CH_trials);
    end

    %%%%% RESULTS HANDLING
    % generate fairly good plots
    if strcmp(par.plot, 'on')

        for method_idx = 1:length(par.detector)
            ber_plot_data = plot_result_ber(par, res_list{method_idx}, ber_plot_data);
            emse_plot_data = plot_result_emse(par, res_list{method_idx}, emse_plot_data);
            tmse_plot_data = plot_result_tmse(par, res_list{method_idx}, tmse_plot_data);
        end

        save_fig(par, ber_plot_data.figure_num, '_BER');
        save_fig(par, emse_plot_data.figure_num, '_EMSE');
        save_fig(par, tmse_plot_data.figure_num, '_TMSE');

    end

    % save final results (par and res structure) TODO save all the
    if strcmp(par.save, 'on')
        save_res(par, res_list); % save the result with filename: `par.simName`
    end

end
