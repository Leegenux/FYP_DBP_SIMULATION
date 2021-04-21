% simfile_name
function [simName] = simfile_name_downlink(par)
    % get current time
    time = datetime('now', 'Format', 'yyyyMMdd-HH_mm_ss');

    % join all the algorithm names
    joint_precoders = par.precoder{1};

    for ind = 2:length(par.precoder)
        joint_precoders = [joint_precoders, '-', par.precoder{ind}];
    end

    % concatenate all the parts
    simName = [...
        char(time), ...
        '_runID_', int2str(par.runID), ...
        '_C_', int2str(par.C), ...
        '_ue_', int2str(par.nbr_of_ue), ...
        '_D_k_', int2str(par.D_k), ...
        '_CH_trials_', int2str(par.CH_trials), ...
        '_', joint_precoders ...
        ]; % simulation name (used for saving result data and figures)

    % get code version information
    git_branch_cmd = 'git branch --show-current';
    git_rev_cmd = 'git rev-parse --short HEAD';

    [cmd_status, branch] = system(git_branch_cmd);

    if cmd_status == 0
        simName = [simName, '_branch_', branch(1:end - 1)];
    end

    [cmd_status, rev] = system(git_rev_cmd);

    if cmd_status == 0
        simName = [simName, '_rev_', rev(1:end - 1)];
    end

end
