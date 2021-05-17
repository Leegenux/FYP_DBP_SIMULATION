function [t_xs, t_ys] = linear_intersections(xs, ys, targ_val, targ_axis)
    %LINEAR_INTERSECTIONS Summary of this function goes here
    %   Detailed explanation goes here
    t_xs = [];
    t_ys = [];

    data = ys;
    data2 = xs;

    if targ_axis == 'x'
        data = xs;
        data2 = ys;
    end

    % iterate over the data, find out the target data
    for idx = 1:length(data) - 1
        diff1 = targ_val - data(idx);

        if diff1 * (targ_val - data(idx + 1)) < 0
            ratio = diff1 / (data(idx + 1) - data(idx));

            if targ_axis == 'x'
                t_xs(end + 1) = targ_val;
                t_ys(end + 1) = (data2(idx + 1) - data2(idx)) * ratio + data2(idx);
            else
                t_ys(end + 1) = targ_val;
                t_xs(end + 1) = (data2(idx + 1) - data2(idx)) * ratio + data2(idx);
            end

        end

    end

end
