function [method, distr, iterative] = name_to_method_downlink(name)
    distr = false;
    iterative = false;

    switch (name)
        case 'EZF'
            method = @EZF;
        case 'ZF'
            method = @ZFP;
        case 'DZF'
            method = @ZFP;
        case 'cWMMSE'
            method = @WMMSE;
        case 'WMMSE'
            method = @WMMSE;

        case 'dEZF'
            method = @EZF;
            distr = true;
        case 'dZF'
            method = @ZFP;
            distr = true;
        case 'dWMMSE'
            method = @WMMSE;
            distr = true;
            iterative = true;
        case 'R-WMMSE'
            method = @R_WMMSE;
            distr = true;
            iterative = true;

        otherwise
            error('method type not defined.');
    end

end
