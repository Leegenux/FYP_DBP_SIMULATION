function par = config_downlink()
    %%%% constants (DO NOT TOUCH)
    par.rb_subc = 12; % each RB has always 12 subcarriers

    %%%% QuaDRiGa related
    par.nbr_of_RB = 4; % Number of RB
    par.nbr_of_ue = 32; % Number of UE
    par.nbr_of_in = 8; % Number of interference user
    par.nbr_of_sym = 14; % Number of symbol in a slot
    par.nbr_of_RE = par.nbr_of_RB * par.nbr_of_sym * par.rb_subc; % Number of RE in 4RB
    par.nbr_of_subc = par.nbr_of_RB * par.rb_subc; % Number of subcarriers in 4RB
    par.nbr_ue_pol = 4; % Number of UE antennas
    par.rs_syms = [11, 12, 13, 14]; % symbols used as Reference Signals
    % 11, 12, 13, 14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30
    par.equa_subc = [3, 7, 11]; % subcarrier indexes for equalization
    par.dt_syms = [];
    par.direction = 'downlink';

    for t = 1:par.nbr_of_sym

        if ismember(t, par.rs_syms) == 0
            par.dt_syms(end + 1) = t;
        end

    end

    %%%% settings about channel files
    par.new_generate = false; % Whether use new quadriga channel or use already generated quadriga channel
    par.quadriga = true; % whether use quadriga (true) or reyleigh channel (false)
    par.use_aggregation = true; % whether apply aggregation accross channels of different sub-band
    par.aggregate_svd = false; % whether use svd directly to aggregate the channel (true) or use PASTd (false)
    par.agg_norm_sv = false; % whether use singular value (true) or subcarrier amplifide (false) to normalize the aggregate channel

    %%%% set default simulation parameters
    par.runID = 9; % simulation ID (used to reproduce results)
    par.B = 128; % receive antennas always 128
    par.U = par.nbr_of_ue; % transmit antennas (not larger than MR!)
    par.D_k = 4; % data streams of per user
    par.D = par.D_k * par.nbr_of_ue; % data streams of per user
    par.mod = '16QAM'; % modulation type: 'BPSK', 'QPSK', '16QAM', '64QAM'
    par.RB_trials = 1; % number of Monte-Carlo trials (RB under same channel)
    par.SNRdB_list = -20:2:30; % list of SNR [dB] values to be simulated
    par.CH_trials = 1; % number of Monte-Carlo trials (channel)
    % select data detector to be used
    %   centralized   : 'EZF'
    %   decentralized : 'DEZF'
    par.precoder = {'ZF', 'DZF', 'WMMSE'};
    %     par.precoder = {'dZF', 'dEZF', 'dWMMSE'};
    %     par.precoder = { 'dZF','dEZF', 'dWMMSE'}; % 'DEZF', 'EZF', 'WMMSE', 'ZF', 'dWMMSE'
    par.plot = 'on'; % plot results? 'on' or 'off'
    par.save = 'on'; % save results? 'on' or 'off'

    %%%% parameters for DBP
    par.C = 8; % number of clusters
    par.maxiter_limit = 1; % maximum algorithm iterations (for BCDMMSE)
    par.IoT = 10; % unit: dB
    par.Es = nan; % average power of UE symbols
    par.Ei = nan; % average power of IN symbols
    par.Q = nan; % number of bits in each symbol
    par.bits = nan;
    par.simName = nan;

    % GPU acceleration. fall back to CPU when not available
    % not working yet
    par.GPUAccel = false;

end
