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
        case 'QMMSE'
            method = @QMMSE;
            distr = true;
        case 'BDAC-MMSE'
            method = @QQMMSE;
            distr = true;
        case 'DMMSE'
            method = @DMSE;
            distr = true;
        case 'BCD-MMSE'
            method = @BCDMMSE;
            distr = true;
            iterative = true;

        otherwise
            error('method type not defined.');
    end

end
