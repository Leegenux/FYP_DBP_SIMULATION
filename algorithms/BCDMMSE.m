%% BCDMMSE
function [W] = BCDMMSE(par, res, H, Ruu, ~)
    W = zeros(par.nbr_of_ue, par.B, res.maxiter);
    % number of antennas in each group
    Bc = par.B / par.C;
    %initialization
    QcH = cell(par.C, 1);
    Hs = cell(par.C, 1);
    inits = QQMMSE(par, res, H, Ruu, 1);

    % assign the point to QcH
    for c = 1:par.C
        c_range = (c - 1) * Bc + 1:c * Bc;
        Hc = H(c_range, :);
        Hs{c} = Hc;
        QcH{c} = inits(:, c_range);
    end

    % iterations
    for t = 1:res.maxiter

        for c = 1:par.C
            % left factor
            c_range = (c - 1) * Bc + 1:c * Bc;
            est_ncnc = Ruu(c_range, c_range);
            left_factor = pinv(par.Es * Hs{c} * Hs{c}' + est_ncnc);
            % right factor
            QlHl = 0;
            ls = 1:par.C;
            ls(c) = [];

            for l = ls
                QlHl = QlHl + QcH{l} * Hs{l};
            end

            Hc_HcQlHl = par.Es * (Hs{c} - Hs{c} * QlHl');

            nQn = 0;

            for l = ls
                l_range = (l - 1) * Bc + 1:l * Bc;
                nQn = nQn + Ruu(c_range, l_range) * QcH{l}';
            end

            right_factor = Hc_HcQlHl - nQn;
            QcH{c} = (left_factor * right_factor)';
        end

        % get Q_H
        Q_H = [];

        for c = 1:par.C
            Q_H = [Q_H QcH{c}];
        end

        W(:, :, t) = Q_H;
    end

end
