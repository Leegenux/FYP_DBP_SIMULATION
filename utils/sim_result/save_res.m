%% save the results
function save_res(par, res_list)
    dir_name = 'results';
    mkdir(dir_name);

    save([dir_name, filesep, par.simName], 'res_list'); % save the res to the file
end
