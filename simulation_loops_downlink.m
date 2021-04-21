function [method_res] = simulation_loops_downlink(par, method_res, P_max_list, H_ue, H_ue_aggregation, precode_once)
    % disp(['runing simulation ... ' method_res.algname]);

    % loop for different SNR
    for SNR_idx = 1:length(par.SNRdB_list)
        % do precoder
        if par.use_aggregation == true
            P = precode_once(par, H_ue_aggregation, P_max_list(SNR_idx), 1);
        end

        for iter = 1:method_res.maxiter % at present, not consider the itertative function
            method_res.achievable_rate(iter, SNR_idx) = 0;

            for subc = 1:par.nbr_of_subc

                if par.use_aggregation == false
                    P = precode_once(par, squeeze(H_ue(:, :, subc, :)), P_max_list(SNR_idx), 1);
                end

                method_res.achievable_rate(iter, SNR_idx) = method_res.achievable_rate(iter, SNR_idx) + compute_obj(squeeze(H_ue(:, :, subc, :)), P, 1, 1);
            end

            method_res.achievable_rate(iter, SNR_idx) = method_res.achievable_rate(iter, SNR_idx) / par.nbr_of_subc;
        end

    end

end
