%% save the figures
function save_fig(par, handle, plot_name)
    dir_name = 'figures';
    mkdir(dir_name);

    savefig(handle, [dir_name, filesep, par.simName, plot_name]); % save the res to the file
end
