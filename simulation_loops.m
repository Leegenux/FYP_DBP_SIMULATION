function [method_res] = simulation_loops(par, method_res, Ruu_list, Ruu_real_list, ue_factor_list, bs_receive, H_up, ue_symbols, ue_bits, detect_once)
    % start simulation
    W = zeros(par.nbr_of_subc, par.nbr_of_ue, par.B, method_res.maxiter); % each is an equalization matrix: #antenna, #UE

    % loop for different SNR
    for SNR_idx = 1:length(par.SNRdB_list)
        % compute equalization matrix coefficientS
        H_up_of_SNR = H_up * ue_factor_list{SNR_idx};

        for subc = 1:par.nbr_of_subc % do equalization in all the 48 REs
            H = squeeze(H_up_of_SNR(:, :, subc));
            W(subc, :, :, :) = detect_once(par, method_res, H, Ruu_list{SNR_idx}, bs_receive{SNR_idx}); % dimensions of W: #subc #UE, #antenna, #iterations
        end

        % compute equalization result and symbol detection for each symbol
        for t = par.dt_syms
            % iterate over subc
            for subc = 1:par.nbr_of_subc
                % iterate over iterations
                for iter = 1:method_res.maxiter
                    W_subc_iter = squeeze(W(subc, :, :, iter));
                    xhat = W_subc_iter * transpose(squeeze(bs_receive{SNR_idx}(subc, :, t)));
                    H_subc = squeeze(H_up_of_SNR(:, :, subc));

                    if method_res.ZF_est
                        [~, bithat] = getEstimate_ZF(par.nbr_of_ue, xhat, par.symbols, par.bits);
                    else
                        [~, bithat] = getEstimate_MMSE(xhat, squeeze(W(subc, :, :, iter)), squeeze(H_up_of_SNR(:, :, subc)), par.symbols, par.bits);
                    end

                    method_res.BER(iter, SNR_idx) = method_res.BER(iter, SNR_idx) + sum(squeeze(ue_bits(:, :, t, subc)) ~= bithat, 'all'); % total bit error number
                    method_res.EMSE(iter, SNR_idx) = method_res.EMSE(iter, SNR_idx) + norm(xhat - squeeze(ue_symbols(:, t, subc)), 2)^2; % total empirical mean square error
                    method_res.TMSE(iter, SNR_idx) = method_res.TMSE(iter, SNR_idx) + par.Es * real(trace((W_subc_iter * H_subc - eye(par.U)) * (W_subc_iter * H_subc - eye(par.U))')) ...
                        + real(trace(W_subc_iter * Ruu_real_list{SNR_idx} * W_subc_iter')); % total theoretical mean square error
                end

            end

        end

    end

    % normalize results
    method_res.BER = method_res.BER / (par.Q * par.U * par.nbr_of_subc * length(par.dt_syms));
    method_res.EMSE = method_res.EMSE / (par.Es * par.nbr_of_subc * length(par.dt_syms)); % empirical average normalized MSE in one RE
    method_res.TMSE = method_res.TMSE / (par.Es * par.nbr_of_subc * length(par.dt_syms)); % theoretical average normalized MSE in one RE
end
