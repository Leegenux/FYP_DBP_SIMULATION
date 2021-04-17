function par = config()
    %%%% constants (DO NOT TOUCH)
    par.rb_subc = 12; % each RB has always 12 subcarriers
    par.nbr_of_RB = 4; % Number of RB
    par.nbr_of_sym = 14; % Number of symbols in a slot

    %%%% QuaDRiGa related
    par.B = 128; % receive antennas
    par.nbr_of_ue = 8; % Number of UE
    par.nbr_of_in = 8; % Number of interference user
    par.nbr_of_RE = par.nbr_of_RB * par.nbr_of_sym * par.rb_subc; % Number of RE in 4RB
    par.nbr_of_subc = par.nbr_of_RB * par.rb_subc; % Number of subcarriers in 4RB
    par.rs_syms = [11, 12, 13, 14]; % symbols used as Reference Signals
    par.equa_subc = [3, 7, 11]; % subcarrier indexes for equalization
    par.dt_syms = [];

    for t = 1:par.nbr_of_sym

        if ismember(t, par.rs_syms) == false
            par.dt_syms(end + 1) = t;
        end

    end

    %%%% settings about channel files
    par.new_generate = false; % Whether use new quadriga channel or use already generated quadriga channel
    par.quadriga = true; % whether use quadriga (true) or reyleigh channel (false)
    par.estimate_Ruu = true; % whether eatiamte Ruu by 196 RE (true) or use accurate Ruu (false)

    %%%% set default simulation parameters
    par.runID = 1; % simulation ID (used to reproduce results)
    par.U = par.nbr_of_ue; % number of users
    par.mod = '16QAM'; % modulation type: 'BPSK', 'QPSK', '16QAM', '64QAM'
    par.RB_trials = 1; % number of Monte-Carlo trials (RB under same channel)
    par.CH_trials = 16; % number of Monte-Carlo trials (channel)
    par.SNRdB_list = -25:2:15; % list of SNR [dB] values to be simulated
    par.diag_load = true;
    % select data detector to be used
    %   centralized   : 'ZF', 'MMSE'
    %   decentralized : 'BCDMMSE', 'QMMSE', 'QQMMSE'
    par.detector = {'ZF', 'MMSE', 'DMMSE'};
    par.plot = 'on'; % plot results? 'on' or 'off'
    par.save = 'on'; % save results? 'on' or 'off'

    %%%% parameters for DBP
    par.C = 8; % number of clusters, available values are (2, 4, 8, 16)
    par.maxiter_limit = 1; % maximum algorithm iterations (for BCDMMSE)
    par.IoT = 10; % unit: dB
    par.Es = nan; % average power of UE symbols
    par.Ei = nan; % average power of IN symbols
    par.Q = nan; % number of bits in each symbol
    par.bits = nan;
    par.simName = nan;

    %%%% parameters for plot
    par.title = false;
    par.plot_shape = true;
end
