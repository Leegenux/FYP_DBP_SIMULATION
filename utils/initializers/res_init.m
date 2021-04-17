function method_res = res_init(SNRdB_list, cur_method, maxiter_limit)
    [~, method_res.distr, method_res.iterative, method_res.ZF_est] = name_to_method(cur_method);

    if method_res.iterative
        method_res.maxiter = maxiter_limit;
    else
        method_res.maxiter = 1;
    end

    method_res.VER = zeros(method_res.maxiter, length(SNRdB_list)); % vector error rate
    method_res.SER = zeros(method_res.maxiter, length(SNRdB_list)); % symbol error rate
    method_res.BER = zeros(method_res.maxiter, length(SNRdB_list)); % bit error rate
    method_res.EMSE = zeros(method_res.maxiter, length(SNRdB_list)); % empirical MSE
    method_res.TMSE = zeros(method_res.maxiter, length(SNRdB_list)); % theoretical MSE
    method_res.algname = cur_method;
end
