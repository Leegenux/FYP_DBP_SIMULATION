%% Zero-Forcing (ZF) precoding
function [P] = ZFP(par, H, P_max, ~)% H should be  #nbr_of_UE_antennas, #bs_atenna, #nbr_of_UE
    % par.nbr_of_ue = 8;
    % par.B = 128;
    % par.D_k = 4;
    % par.D = 32;
    % H =  rand(4,par.B,par.nbr_of_ue);
    [Nr, Nt, K] = size(H);
    par.D = par.D_k * K;
    H_reshape = reshape(permute(H,[1,3,2]), [Nr * K, Nt]);
    P_tilt = pinv(H_reshape);
    P_normal = zeros(Nt, par.D);
    
    % normalize P_tilt by column and allocate power s.t. each straem has
    % equal power
    scale_factor = sqrt(P_max/(K * Nr));
    for k = 1:size(P_tilt,2)
        norm_factor = norm(P_tilt(:,k),'fro');
        P_normal(:,k) = P_tilt(:,k)/norm_factor * scale_factor;
    end
    P = zeros(Nt, par.D_k, K);

    for u = 1:K
        P(:, :, u) = P_normal(:, (u - 1) * par.D_k + 1:u * par.D_k);
    end   
    
end
