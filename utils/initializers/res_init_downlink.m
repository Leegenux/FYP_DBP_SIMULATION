function method_res = res_init_downlink(SNRdB_list, cur_method, maxiter_limit)
    [~, method_res.distr, method_res.iterative] = name_to_method_downlink(cur_method);

    if method_res.iterative
        method_res.maxiter = maxiter_limit;
    else
        method_res.maxiter = 1;
    end

    method_res.achievable_rate = zeros(method_res.maxiter, length(SNRdB_list)); % theoretical MSE
    method_res.algname = cur_method;
end
