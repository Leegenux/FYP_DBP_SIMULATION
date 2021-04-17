%% timer_progress : put in the loop
function time_elapsed = timer_progress(time_elapsed, total_loop, cur_loop)
    if toc > 1
        time = toc;
        time_elapsed = time_elapsed + time;
        
        est_remain_sec = time_elapsed*(total_loop/cur_loop-1);
        est_remain_min = est_remain_sec / 60;
        if est_remain_sec > 60
            fprintf('progress: %d/%d\ntime remaining: %3.2f min.\n', cur_loop, total_loop, est_remain_min);
        else
            fprintf('progress: %d/%d\ntime remaining: %2.2f s.\n', cur_loop, total_loop, est_remain_sec);
        end
        
        tic;
    end
end