%% zero-forcing (ZF) detector
function [W] = ZF(par, res, H, ~,~)% H should be #atenna, #UE
    W = pinv(H);
end
