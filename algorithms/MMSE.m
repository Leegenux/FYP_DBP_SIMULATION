%% unbiased MMSE detector (MMSE)
function [W] = MMSE(par, ~, H, Ruu,~)
    HR = H' * pinv(Ruu);
    W = pinv(HR * H + 1 / par.Es * eye(par.U)) * HR;
end

% function [idxhat, bithat, xhat] = MMSE(par, ~, H, y, N0)
%     HR = H'*pinv(N0*par.ncovmat);
%     W = pinv(HR*H + 1/par.Es*eye(par.U))*HR;
%     xhat = W*y;
%
%     % biased est
%     [idxhat, bithat] = getEstimate(par.U, xhat, par.symbols, par.bits);
%
%     % unbiased est
%     % G = real(diag(W*H));
%     % [~, idxhat] = min(abs(xhat*ones(1, length(par.symbols)) - G*par.symbols).^2, [], 2);
%     % bithat = par.bits(idxhat, :);
% end
