% timer_stop : put after the loop
function time_elapsed = timer_stop(time_elapsed)
    time_elapsed = time_elapsed + toc;
end