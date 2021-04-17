%% unbiased distributed approximate MMSE detector (DMSE)
function [W] = DMSE(par, ~, H, Ruu)
    % number of antennas in each group
    Bc = par.B / par.C;

    % set initial point with D_LMMSE
    Gc = zeros(par.nbr_of_ue);
    yMRC = zeros(par.nbr_of_ue, par.B);

    for c = 1:par.C
        c_range = (c - 1) * Bc + 1:c * Bc;
        Rc = Ruu(c_range, c_range);
        Hc = H(c_range, :);

        % calc the sum
        pRC = pinv(Rc);
        Gc = Gc + Hc' * pRC * Hc;
        yMRC(:, c_range) = Hc' * pRC;
    end

    W = pinv(Gc + eye(par.nbr_of_ue) / par.Es) * yMRC;
end
