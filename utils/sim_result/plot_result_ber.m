% this function draws all the results on an existing figure
function [plot_param] = plot_result_ber(par, res, plot_param)
    %   marker_style = {'ro-', 'rs--', 'mv-.', 'kp:', 'g*-', 'c>--', 'yx:'};
    %                    red            pink   black  green   cyan   yellow
    % for one iteration
    % marker_style = {'ro-', 'ms--', 'gp:', 'b>--', 'c*-', 'kx:', 'yh:'};
    if par.plot_shape
        marker_style = {'ro:', 'ms:', 'gv-', 'bp-', 'c*-', 'k>-', 'yx-'};
        marker_size = 8;
    else
        marker_style = {'r.:', 'm.:', 'g.-', 'b.-', 'c.-', 'k.-', 'y.-'};
        marker_size = 12;
    end

    % add lines
    figure(plot_param.figure_num)
    tag_str = cell(0);

    for d = 1:res.maxiter
        marker_ind = plot_param.next_marker + d - 1;
        marker_ind = mod(marker_ind - 1, length(marker_style)) + 1;

        if d + plot_param.next_marker - 1 == 1 % set up the attributes and things
            hold off
            % set figure attributes
            semilogy(par.SNRdB_list, res.BER(d, :), marker_style{marker_ind}, 'LineWidth', 2, 'MarkerSize', marker_size)

            grid on % enable grid
            xlabel('Es/N0 (dB)', 'FontSize', 12)
            ylabel('BER', 'FontSize', 12)
            axis([min(par.SNRdB_list) max(par.SNRdB_list) 1e-5 1e0])

            if par.title == true
                title(plot_param.title);
            end

        else
            hold on
            semilogy(par.SNRdB_list, res.BER(d, :), marker_style{marker_ind}, 'LineWidth', 2, 'MarkerSize', marker_size)
            hold off
        end

        [tx, ty] = linear_intersections(par.SNRdB_list, log(res.BER(d, :)) / log(10), log(par.target_BER) / log(10), 'y');

        if ~isempty(ty) && par.do_tag

            % for idx = 1:length(ty)
            %     x_val = tx(idx);
            %     y_val = power(10, ty(idx));
            %     text(x_val, y_val, '\otimes', 'FontSize', marker_size + 10, 'Color', 'k', 'HorizontalAlignment', 'center');
            % end

            tag_str{d} = ['  (' num2str(tx(1), '%2.4f dB)')];
        else
            tag_str{d} = '';
        end

    end

    plot_param.next_marker = plot_param.next_marker + res.maxiter;

    % gather legeneds
    if res.iterative
        l = cell(1, res.maxiter);

        for i = 1:res.maxiter
            l{i} = [ res.algname ':Iter ' num2str(i) tag_str{i}];
        end

        plot_param.legends = cat(2, plot_param.legends, l);
    else
        plot_param.legends{end + 1} = [ res.algname tag_str{1}];
    end

    % set up legends and gca
    legend(plot_param.legends, 'Fontsize', 10, 'Location', 'southwest');
    set(gca, 'FontSize', 12)
end
