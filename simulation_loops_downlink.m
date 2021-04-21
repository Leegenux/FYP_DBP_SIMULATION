function method_res = simulation_loops_downlink(par, method_res, P_max_list, H_ue, precode_once)
    disp(['runing simulation ... ' method_res.algname]);

    time_elapsed = timer_start();
    % loop for different SNR
    for SNR_idx = 1:length(par.SNRdB_list)
        % do precoder
        for iter = 1:method_res.maxiter % at present, not consider the itertative function
            method_res.achievable_rate(iter, SNR_idx) = 0;

            for subc = 1:par.nbr_of_subc
                P = precode_once(par, squeeze(H_ue(:, :, subc, :)), P_max_list(SNR_idx), 1);
                method_res.achievable_rate(iter, SNR_idx) = method_res.achievable_rate(iter, SNR_idx) + compute_obj(squeeze(H_ue(:, :, subc, :)), P, 1, 1);
            end

            method_res.achievable_rate(iter, SNR_idx) = method_res.achievable_rate(iter, SNR_idx) / par.nbr_of_subc;

            time_elapsed = timer_progress(time_elapsed, length(par.SNRdB_list) * method_res.maxiter, (SNR_idx - 1) * method_res.maxiter + (iter - 1));
        end

    end

    timer_stop(time_elapsed);

end
