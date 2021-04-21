function [par, res_list] = DBP_precoder_sim(varargin)
    % -- set up default/custom parameters
    if isempty(varargin)
        disp('using default simulation settings and parameters...')
        % set default simulation parameters
        par = config_downlink();
    else
        disp('use custom simulation settings and parameters...');
        par = varargin{1}; % the only argument is par structure
    end

    %%%%% SIMULATION INITIALIZATION
    par = simulation_init_downlink(par);
    achievable_rate_plot_data = plot_data_init_downlink(1);
    achievable_rate_plot_data.title = ['Achievable Rate, ', num2str(par.B) ' antennas, ' num2str(par.C) ' clusters, ' num2str(par.U) ' users'];

    % dimensions: #bs_antenna, #UE, #sub_c
    res_list = cell(length(par.precoder), 1);

    for method_idx = 1:length(par.precoder)
        cur_method = par.precoder{method_idx};
        res_list{method_idx} = res_init_downlink(par.SNRdB_list, cur_method, par.maxiter_limit);
    end

    for trial = 1:par.CH_trials

        if par.quadriga
            ch_fname = ['runID_' num2str(par.runID) '_ue_' num2str(par.nbr_of_ue) '_CH_trial_' num2str(trial) '.mat'];
            % generate channel for 4RB
            [H_ue_aggregation_central, H_ue_aggregation_decentral, H_ue, ~, ] = gen_quadriga_channel_file_downlink(par, par.nbr_of_RB, par.nbr_of_ue, par.nbr_of_in, par.C, ch_fname, par.new_generate);
            % layout.visualize;
        else
            H_ue = sqrt(0.5) * (randn(par.nbr_ue_pol, par.B, par.nbr_of_subc, par.nbr_of_ue) + 1j * randn(par.nbr_ue_pol, par.B, par.nbr_of_subc, par.nbr_of_ue));
            H_ue_aggregation_central = nan;
            H_ue_aggregation_decentral = nan;
            %         H_in = sqrt(0.5) * (randn(par.nbr_ue_pol, par.B, par.nbr_of_ue) + 1j * randn(par.nbr_ue_pol, par.B, par.nbr_of_ue));
        end

        P_max_list = zeros(length(par.SNRdB_list), 1);

        for m = 1:length(par.SNRdB_list)
            % FORMULA 1: SNR (Es/N0) = 10 lg(P_max / noise )
            P_max_list(m) = 10^(par.SNRdB_list(m) / 10);
        end

        %%%%% PRECODER OF METHODS
        % method loops
        for method_idx = 1:length(par.precoder)
            cur_method = par.precoder{method_idx};

            % initialize per-vector, per symbol and per-bit error rate results
            method_res = res_init_downlink(par.SNRdB_list, cur_method, par.maxiter_limit);
            [method, ~, ~] = name_to_method_downlink(cur_method);

            if method_res.distr == true
                H_ue_aggregation = H_ue_aggregation_decentral;
            else
                H_ue_aggregation = H_ue_aggregation_central;
            end

            method_res = simulation_loops_downlink(par, method_res, P_max_list, H_ue, H_ue_aggregation, method);
            method_res.achievable_rate = res_list{method_idx}.achievable_rate + method_res.achievable_rate;

            % gather results
            res_list{method_idx} = method_res;
        end

    end

    for method_idx = 1:length(par.precoder)
        res_list{method_idx}.achievable_rate = res_list{method_idx}.achievable_rate / par.CH_trials;
    end

    %%%%% RESULTS HANDLING
    % generate fairly good plots
    if strcmp(par.plot, 'on')

        for method_idx = 1:length(par.precoder)
            achievable_rate_plot_data = plot_result_achievable_rate(par, res_list{method_idx}, achievable_rate_plot_data);
        end

        save_fig(par, achievable_rate_plot_data.figure_num, '_AR')

    end

    % save final results (par and res structure) TODO save all the
    if strcmp(par.save, 'on')
        save_res(par, res_list); % save the result with filename: `par.simName`
    end

end
