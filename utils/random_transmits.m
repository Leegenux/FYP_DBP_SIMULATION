function [bits, idxs, s] = random_transmits(U, Q, nbr_of_subc, nbr_of_sym, symbols)
    % This function generates symbol of each RE, for U users.
    % dimensions: #UE, #symbol, #subc

    % generate bitstream
    bits = randi([0, 1], U, Q, nbr_of_sym, nbr_of_subc);
    % turn bitstream into indexs of symbol on alphabet
    idxs = zeros(U, nbr_of_sym, nbr_of_subc);

    for idx = 1:nbr_of_subc

        for jdx = 1:nbr_of_sym
            idxs(:, jdx, idx) = bi2de(bits(:, :, jdx, idx), 'left-msb') + 1; % this function turn each row vector into decimals
        end

    end

    % get symbols, too
    s = zeros(U, nbr_of_sym, nbr_of_subc);

    for idx = 1:nbr_of_subc

        for jdx = 1:nbr_of_sym
            s(:, jdx, idx) = symbols(idxs(:, jdx, idx));
        end

    end

end
