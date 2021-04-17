function par = simulation_init(par)
    % use runId random seed (enables reproducibility)
    rng(par.runID);

    % set up Gray-mapped constellation alphabet (according to IEEE 802.11)
    % Gray code ref: https://www.sciencedirect.com/topics/engineering/gray-mapping
    switch (par.mod)
        case 'BPSK'
            par.symbols = [-1 1];
        case 'QPSK'
            par.symbols = [-1 - 1i, -1 + 1i, ...
                            +1 - 1i, +1 + 1i];
        case '16QAM'
            par.symbols = [-3 - 3i, -3 - 1i, -3 + 3i, -3 + 1i, ...
                            -1 - 3i, -1 - 1i, -1 + 3i, -1 + 1i, ...
                            +3 - 3i, +3 - 1i, +3 + 3i, +3 + 1i, ...
                            +1 - 3i, +1 - 1i, +1 + 3i, +1 + 1i];
        case '64QAM'
            par.symbols = [-7 - 7i, -7 - 5i, -7 - 1i, -7 - 3i, -7 + 7i, -7 + 5i, -7 + 1i, -7 + 3i, ...
                            -5 - 7i, -5 - 5i, -5 - 1i, -5 - 3i, -5 + 7i, -5 + 5i, -5 + 1i, -5 + 3i, ...
                            -1 - 7i, -1 - 5i, -1 - 1i, -1 - 3i, -1 + 7i, -1 + 5i, -1 + 1i, -1 + 3i, ...
                            -3 - 7i, -3 - 5i, -3 - 1i, -3 - 3i, -1 + 7i, -3 + 5i, -3 + 1i, -3 + 3i, ...
                            +7 - 7i, +7 - 5i, +7 - 1i, +7 - 3i, +7 + 7i, +7 + 5i, +7 + 1i, +7 + 3i, ...
                            +5 - 7i, +5 - 5i, +5 - 1i, +5 - 3i, +5 + 7i, +5 + 5i, +5 + 1i, +5 + 3i, ...
                            +1 - 7i, +1 - 5i, +1 - 1i, +1 - 3i, +1 + 7i, +1 + 5i, +1 + 1i, +1 + 3i, ...
                            +3 - 7i, +3 - 5i, +3 - 1i, +3 - 3i, +3 + 7i, +3 + 5i, +3 + 1i, +3 + 3i];
    end

    % extract average symbol energy
    par.Es = mean(abs(par.symbols).^2);
    par.Ei = mean(abs(par.symbols).^2);

    % precompute bit labels
    par.Q = log2(length(par.symbols)); % number of bits per symbol
    par.bits = de2bi(0:length(par.symbols) - 1, par.Q, 'left-msb');

    % generate reasonable filename
    par.simName = simfile_name(par);
end
