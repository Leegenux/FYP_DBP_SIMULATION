%% get the estimation: find nearest neighbors
function [idxhat, bithat] = getEstimate_MMSE(xhat, W, H, symbols, bits)
    G = real(diag(W * H));
    [~, idxhat] = min(abs(xhat * ones(1, length(symbols)) - G * symbols).^2, [], 2);
    bithat = bits(idxhat, :);
end
