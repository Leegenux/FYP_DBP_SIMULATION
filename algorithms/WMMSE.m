%in this code, X denote the digital transmit pecoder, i.e., Vbb
function [V] = WMMSE(par, H, P_max, sigma2)
% parameter setting
    rng(1); 
    maxIter = 50;
    tol = 1e-7;
    [Nr, Nt, K] = size(H);
    alpha = ones(K,1);

    % initialization
    if nargin < 6
        V0 = zeros(Nt, par.D_k, K);
        for k = 1:K
            V0(:, :, k) = randn(Nt, par.D_k);
        end

    end
    % initialize with EZF solution
    V0 = EZF(par, H, P_max);
    
    V = V0;

    obj = Inf;
    obj_vec = [];
    iter = 0;

    while (iter < maxIter)
        iter = iter + 1;
        obj_old = obj;

        VV_T = zeros(Nt, Nt);
        for k = 1:K
            V_k = V(:, :, k);
            VV_T = VV_T + V_k * V_k';
        end

            gamma = real(trace(VV_T))*sigma2/P_max;

        obj = 0;

        for k = 1:K
            % update U
            H_k = H(:, :, k);
            HkVVHk = H_k * VV_T * H_k'; 
            V_K = V(:, :, k);
            U_k = (gamma * eye(Nr) + HkVVHk) \ (H_k * V_K); %update Ubbk
            U(:, :, k) = U_k;

            % update W
            W_k = inv(eye(Nr) - U_k' * H_k * V_K); %eye(par.D_k) : nbr of data stream
            W(:, :, k) = 0.5 * (W_k + W_k');
            %         W(:,:,k) = W_k;

            obj = obj + alpha(k) * log(det(W_k));

        end

        obj = real(obj);
        obj_vec = [obj_vec obj];

        if abs(obj - obj_old) / abs(obj_old) <= tol
            break;
        end

        % update V
        A = zeros(Nt, Nt);
 
        for j = 1:K
            tmp_j = H(:, :, j)' * U(:, :, j);
                    A = A + alpha(j)*tmp_j*W(:,:,j)*tmp_j' + alpha(j) * sigma2/P_max*trace(U(:,:,j)*W(:,:,j)*U(:,:,j)')*eye(Nt); 
        end

        for k = 1:K
                   V(:,:,k) = A\(alpha(k)* H(:,:,k)'*U(:,:,k)*W(:,:,k));
        end

    end

%     p = 0;
% 
%     for k = 1:K
%         V_k = V(:, :, k);
%         p = p + norm(V_k, 'fro')^2;
%     end
% 
%     for k = 1:K
%         V(:, :, k) = sqrt(P_max / p) * V(:, :, k);
%     end

  
        V = sqrt(P_max/sumf2(V)) * V;

%     obj = compute_obj(H, V, sigma2, alpha);
end
