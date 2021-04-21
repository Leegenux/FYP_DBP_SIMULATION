% this function draws all the results on an existing figure
function [plot_param] = plot_result_achievable_rate(par, res, plot_param)
    %   marker_style = {'ro-', 'rs--', 'mv-.', 'kp:', 'g*-', 'c>--', 'yx:'};
    %                    red            pink   black  green   cyan   yellow
    marker_style = {'r.-', 'm.--', 'g.:', 'b.--', 'c.-', 'k.:', 'y.:'};

    % add lines
    figure(plot_param.figure_num)

    for d = 1:res.maxiter
        marker_ind = plot_param.next_marker + d - 1;
        marker_ind = mod(marker_ind - 1, length(marker_style)) + 1;

        if d + plot_param.next_marker - 1 == 1 % set up the attributes and things
            hold off
            % set figure attributes
            plot(par.SNRdB_list, res.achievable_rate(d, :), marker_style{marker_ind}, 'LineWidth', 2, 'MarkerSize', 13)

            grid on % enable grid
            xlabel('Average Transmit SNR (dB)', 'FontSize', 12)
            ylabel('Achievable Rate (bpcu) ', 'FontSize', 12)
            axis([min(par.SNRdB_list) max(par.SNRdB_list) 0 720])
            title(plot_param.title);
        else
            hold on
            plot(par.SNRdB_list, res.achievable_rate(d, :), marker_style{marker_ind}, 'LineWidth', 2, 'MarkerSize', 13)
            hold off
        end

    end

    plot_param.next_marker = plot_param.next_marker + res.maxiter;

    % gether legeneds
    if res.distr
        l = cell(1, res.maxiter);

        for i = 1:res.maxiter
            l{i} = [res.algname ' Iteration ' num2str(i)];
            l{i} = [res.algname];
        end

        plot_param.legends = cat(2, plot_param.legends, l);
    else
        plot_param.legends{end + 1} = [res.algname];
    end

    % set up legends and gca
    legend(plot_param.legends, 'Fontsize', 10, 'Location', 'northwest');
    set(gca, 'FontSize', 12)
end
