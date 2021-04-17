%% get the estimation: find nearest neighbors
function [idxhat, bithat] = getEstimate_ZF(U, xhat, symbols, bits)
    [~, idxhat] = min(abs(xhat * ones(1, length(symbols)) - ones(U, 1) * symbols).^2, [], 2);
    bithat = bits(idxhat, :);
end
