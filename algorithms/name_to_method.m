function [method, distr, iterative, ZF_est] = name_to_method(name)
    distr = false;
    iterative = false;
    ZF_est = false;

    switch (name)
        case 'ZF'
            method = @ZF;
            ZF_est = true;
        case 'MMSE'
            method = @MMSE;
        case 'DMMSE'
            method = @DMSE;
            distr = true;
        otherwise
            error('method type not defined.');
    end

end
