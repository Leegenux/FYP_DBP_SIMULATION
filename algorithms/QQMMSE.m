%% QQMMSE
function [W] = QQMMSE(par, res, H, Ruu, ~)
    % number of antennas in each group
    Bc = par.B / par.C;
    % covariance matrix
    R = Ruu;
    % HRy and HRH
    HR = zeros(par.U, par.B);
    HR(:, 1:Bc) = H(1:Bc, :)' * pinv(R(1:Bc, 1:Bc));
    HRH = H(1:Bc, :)' * pinv(R(1:Bc, 1:Bc)) * H(1:Bc, :);

    for c = 1:(par.C - 1)
        HR(:, c * Bc + 1:(c + 1) * Bc) = H(c * Bc + 1:(c + 1) * Bc, :)' * pinv(R(c * Bc + 1:(c + 1) * Bc, c * Bc + 1:(c + 1) * Bc));
        HRH = HRH + H(c * Bc + 1:(c + 1) * Bc, :)' * pinv(R(c * Bc + 1:(c + 1) * Bc, c * Bc + 1:(c + 1) * Bc)) * H(c * Bc + 1:(c + 1) * Bc, :);
    end

    % equation 3.5
    W = pinv((HRH +eye(par.U) / par.Es)) * HR;
end
