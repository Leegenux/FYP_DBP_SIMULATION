%% get error
function [VER, SER, BER] = getError(U, Q, idxhat, bithat, idx, bits)
    err = (idx ~= idxhat);
    VER = any(err);
    SER = sum(err) / U;
    BER = sum(sum(bits ~= bithat)) / (U * Q);
end
