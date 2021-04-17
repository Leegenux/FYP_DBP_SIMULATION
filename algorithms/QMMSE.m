%% Q-compressed MMSE detector (QMMSE)
function [W] = QMMSE(par, res, H, Ruu,~)
    % number of antennas in each group
    Bc = par.B / par.C;
    % get Rb
    R = Ruu;
    Rb = R(1:Bc, 1:Bc);

    for c = 1:(par.C - 1)
        Rc = R((c * Bc + 1):(c + 1) * Bc, (c * Bc + 1):(c + 1) * Bc);
        Rb = blkdiag(Rb, Rc);
    end

    % equation 3.8
    pRb = pinv(Rb);
    RRR = pRb * R * pRb;
    pHRRRH = pinv((H' * RRR * H));
    HRb = H' * pRb;
    HRbH = (HRb * H)';
    HRbHHRRRH = HRbH * pHRRRH;
    W = pinv(HRbHHRRRH * HRbH' + eye(par.U) / par.Es) * HRbHHRRRH * HRb;
end

%     [idxhat, bithat] = getEstimate(par.U, xhat, par.symbols, par.bits);
