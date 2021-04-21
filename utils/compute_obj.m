% calculate obj
function obj = compute_obj(H, V, sigma2, ~)
    % % simple example to verfiy the function work well
    % H=ones(2,2,1);
    % V=ones(2,2,1);
    % sigma2=1;
    [Nr, Nt, K] = size(H);
    % d = size(V, 2);
    d = Nr;
    obj = 0;
    VV = zeros(Nt, Nt);

    if length(size(V)) > 2

        for k = 1:K
            VV = VV + V(:, :, k) * V(:, :, k)';
        end

        for k = 1:K
            Hk = H(:, :, k);
            Vk = V(:, :, k);
            Jk = sigma2 * eye(Nr) + Hk * (VV - Vk * Vk') * Hk';
            HVk = Hk * Vk;
            obj = obj + log2(det(eye(d) + HVk * HVk' * inv(Jk)));
        end

        obj = real(obj);
    else

        for k = 1:K
            VV = VV + V(:, k) * V(:, k)';
        end

        for k = 1:K
            Hk = H(:, :, k);
            Vk = V(:, k);
            Jk = sigma2 * eye(Nr) + Hk * (VV - Vk * Vk') * Hk';
            HVk = Hk * Vk;
            obj = obj + log2(det(eye(d) + HVk * HVk' / Jk));

        end

        obj = real(obj);
    end

end
