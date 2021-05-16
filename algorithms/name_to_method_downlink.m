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
        otherwise
            error('method type not defined.');
    end

end
