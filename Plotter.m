classdef Plotter < handle
    %PLOTTER General class that handles the generic plotting

    properties

        dataset
        figure_position
        plot_type;

        colors
        linestyles
        linewidths

        plot_handle

        visibility
        indexes

        xlim
        ylim

        xlabel
        ylabel

        subtitle

        title

        legend
        legend_type
        legend_location

        inset
        inset_type;
        inset_position
        inset_indexes

        grouping
        grouping_number
        line_group
        linestyle_group
        linewidth_group
        color_group

        label_fontsize
        legend_fontsize
        subtitle_fontsize
        title_fontsize

        save_filename
    end

    properties (Access = private)

        fig;
        axs;
        axs_inset;
        num_rows;
        num_cols;

    end

    methods

        function obj = Plotter(dataset, varargin)

            obj.dataset = dataset;
            obj.num_rows = size(obj.dataset, 1);
            obj.num_cols = size(obj.dataset, 2);

            obj.plot_type = 1;
            obj.figure_position = [0 0 2000 2000];

            obj.colors = 'auto';
            obj.linestyles = {'-', ':', '-.'};
            obj.linewidths = {1, 3, 5};

            obj.plot_handle = @plot;

            obj.visibility = true;
            obj.indexes = 'all';

            obj.xlim = 'auto';
            obj.ylim = 'auto';

            obj.xlabel = 'auto';
            obj.ylabel = 'auto';

            obj.subtitle = 'auto';

            obj.title = 'auto';

            obj.legend = 'auto';
            obj.legend_type = 'one-for-all';
            obj.legend_location = 'best';

            obj.inset = false;
            obj.inset_type = 'std-mean';
            obj.inset_position = [0.6 0.6 0.3 0.3];
            obj.inset_indexes = 'all';

            obj.grouping = false;
            obj.grouping_number = 3;
            obj.linestyle_group = 'successive';
            obj.linewidth_group = 'successive';
            obj.color_group = 'successive';

            obj.label_fontsize = 15;
            obj.legend_fontsize = 10;
            obj.subtitle_fontsize = 10;
            obj.title_fontsize = 20;

            obj.save_filename = "Plotter_Figure";

            nvarargin = length(varargin)

            if ~isempty(varargin) && mod(nvarargin, 2) == 0

                for k = 1:2:nvarargin

                    obj.(varargin{k}) = varargin{k + 1};

                end

            end

            if obj.visibility

                obj.visibility = 'on';

            else

                obj.visibility = 'off';

            end

            obj.check_xdata();
            obj.check_xlabel();
            obj.check_ylabel();
            obj.check_subtitle();
            obj.check_title();
            obj.check_legend();
            obj.check_color();

            obj.axs = {};
            obj.axs_inset = {};

        end

        function plot(obj)

            if obj.plot_type == 1

                obj.plot_1();

            elseif obj.plot_type == 2

                obj.plot_2();

            end

        end

        function save(obj)

            if obj.plot_type == 1

                fname = obj.save_filename;
                
            elseif obj.plot_type == 2

                fname = [obj.save_filename '_errorbar'];

            end

            exportgraphics(obj.fig, strcat(fname, '.png'));
            savefig(obj.fig, fname);

        end

    end

    methods (Access = private)

        function plot_1(obj)

            obj.fig = figure('Position', obj.figure_position, 'Units', 'pixels', 'visible', obj.visibility)

            cnt1 = 1

            for i = 1:obj.num_rows

                for j = 1:obj.num_cols

                    ax1 = subplot(obj.num_rows, obj.num_cols, cnt1);
                    obj.axs{end + 1} = ax1;

                    hold(ax1, 'on');

                    cnt2 = 1;

                    for k = 1:length(obj.dataset{i, j})

                        data_x = obj.dataset{i, j}{k}{1};
                        data_y = obj.dataset{i, j}{k}{2};

                        if ~isnumeric(obj.indexes)

                            ixs_ = 1:length(data_x);

                        else

                            ixs_ = obj.indexes;

                        end

                        data_x = data_x(ixs_);
                        data_y = data_y(ixs_);

                        linestyle_cnt = mod(cnt2 - 1, length(obj.dataset{i, j})) + 1;
                        linewidth_cnt = mod(cnt2 - 1, length(obj.dataset{i, j})) + 1;
                        color_cnt = mod(cnt2 - 1, length(obj.dataset{i, j})) + 1;

                        if obj.grouping

                            successive_cnt = fix((cnt2 - 1) / obj.grouping_number) + 1;
                            skip_cnt = fix((cnt2 - 1), obj.grouping_number) + 1;

                            if strcmp(obj.linestyle_group, 'successive')

                                linestyle_cnt = successive_cnt;

                            elseif strcmp(obj.line_group, 'skip')

                                linestyle_cnt = skip_cnt;

                            else

                                error("Please assign proper grouping type!")

                            end

                            if strcmp(obj.linewidth_group, 'successive')

                                linewidth_cnt = successive_cnt;

                            elseif strcmp(obj.linewidth_group, 'skip')

                                linewidth_cnt = skip_cnt;

                            else

                                error("Please assign proper grouping type!")

                            end

                            if strcmp(obj.color_group, 'successive')

                                color_cnt = successive_cnt;

                            elseif strcmp(obj.color_group, 'skip')

                                color_cnt = skip_cnt;

                            else

                                error("Please assign proper grouping type!")

                            end

                        end

                        obj.plot_handle(ax1, data_x, data_y, ...
                            'LineStyle', obj.linestyles{linestyle_cnt}, ...
                            'Color', obj.colors{i, j}(color_cnt, :), ...
                            'LineWidth', obj.linewidths{linewidth_cnt});

                        cnt2 = cnt2 + 1;
                    end

                    xlabel(ax1, obj.xlabel{i, j}, 'Interpreter', 'latex', 'FontSize', obj.label_fontsize);
                    ylabel(ax1, obj.ylabel{i, j}, 'Interpreter', 'latex', 'FontSize', obj.label_fontsize);
                    title(ax1, obj.subtitle{i, j}, 'Interpreter', 'latex', 'FontSize', obj.subtitle_fontsize);

                    if strcmp(obj.legend_type, 'each')
                        legend(ax1, obj.legend{i, j}, 'Location', obj.legend_location, 'Orientation', 'horizontal', 'Interpreter', 'latex', 'FontSize', obj.legend_fontsize);
                    end

                    hold(ax1, 'off')

                    cnt1 = cnt1 + 1;
                end

            end

            if strcmp(obj.legend_type, 'one-for-all')

                legend(obj.legend{end, end}, 'Location', 'bestoutside', 'Orientation', 'horizontal');

            end

            sgtitle(obj.title, 'Interpreter', 'latex', 'FontSize', obj.title_fontsize);

            if strcmp(obj.xlim, 'auto')

                obj.check_xlim();

            end

            if strcmp(obj.ylim, 'auto')

                obj.check_ylim();

            end

        end

        function plot_2(obj)

            obj.fig = figure('Position', obj.figure_position, 'Units', 'pixels', 'visible', obj.visibility)

            cnt1 = 1

            for i = 1:obj.num_rows

                for j = 1:obj.num_cols

                    ax1 = subplot(obj.num_rows, obj.num_cols, cnt1);
                    ax1_position = ax1.Position;
                    ax2 = axes('Position', [ax1_position(1) + obj.inset_position(1) * ax1_position(3), ...
                                    ax1_position(2) + obj.inset_position(2) * ax1_position(4), ...
                                    (obj.inset_position(3)) * ax1_position(3), ...
                                    (obj.inset_position(4)) * ax1_position(4)]);

                    obj.axs{end + 1} = ax1;
                    obj.axs_inset{end + 1} = ax2;

                    hold(ax1, 'on');
                    hold(ax2, 'on');

                    cnt2 = 1;

                    for k = 1:length(obj.dataset{i, j})

                        data_x = obj.dataset{i, j}{k}{1};
                        data_y = obj.dataset{i, j}{k}{2};

                        if ~isnumeric(obj.indexes)

                            ixs_ = 1:length(data_x);

                        elseif isvector(obj.indexes)

                            ixs_ = obj.indexes;

                        else

                            ixs_ = obj.indexes:length(data_x)

                        end

                        if ~isnumeric(obj.inset_indexes)

                            ixs_inset = 1:length(data_x);

                        elseif isvector(obj.inset_indexes)

                            ixs_inset = obj.inset_indexes

                        else

                            ixs_inset = obj.inset_indexes:length(data_x)

                        end

                        data_x = data_x(ixs_);
                        data_y = data_y(ixs_);

                        linestyle_cnt = mod(cnt2 - 1, length(obj.dataset{i, j})) + 1;
                        linewidth_cnt = mod(cnt2 - 1, length(obj.dataset{i, j})) + 1;
                        color_cnt = mod(cnt2 - 1, length(obj.dataset{i, j})) + 1;

                        if obj.grouping

                            successive_cnt = fix((cnt2 - 1) / obj.grouping_number) + 1;
                            skip_cnt = fix((cnt2 - 1), obj.grouping_number) + 1;

                            if strcmp(obj.linestyle_group, 'successive')

                                linestyle_cnt = successive_cnt;

                            elseif strcmp(obj.line_group, 'skip')

                                linestyle_cnt = skip_cnt;

                            else

                                error("Please assign proper grouping type!")

                            end

                            if strcmp(obj.linewidth_group, 'successive')

                                linewidth_cnt = successive_cnt;

                            elseif strcmp(obj.linewidth_group, 'skip')

                                linewidth_cnt = skip_cnt;

                            else

                                error("Please assign proper grouping type!")

                            end

                            if strcmp(obj.color_group, 'successive')

                                color_cnt = successive_cnt;

                            elseif strcmp(obj.color_group, 'skip')

                                color_cnt = skip_cnt;

                            else

                                error("Please assign proper grouping type!")

                            end

                        end

                        obj.plot_handle(ax1, data_x, data_y, ...
                            'LineStyle', obj.linestyles{linestyle_cnt}, ...
                            'Color', obj.colors{i, j}(color_cnt, :), ...
                            'LineWidth', obj.linewidths{linewidth_cnt});

                        bar(ax2, cnt2, mean(data_y(ixs_inset)), ...
                            'FaceColor', obj.colors{i, j}(color_cnt, :));

                        errorbar(ax2, cnt2, mean(data_y(ixs_inset)), std(data_y(ixs_inset)));

                        cnt2 = cnt2 + 1;

                    end

                    xlabel(ax1, obj.xlabel{i, j}, 'Interpreter', 'latex', 'FontSize', obj.label_fontsize);
                    ylabel(ax1, obj.ylabel{i, j}, 'Interpreter', 'latex', 'FontSize', obj.label_fontsize);
                    title(ax1, obj.subtitle{i, j}, 'Interpreter', 'latex', 'FontSize', obj.subtitle_fontsize);

                    if strcmp(obj.legend_type, 'each')
                        legend(ax1, obj.legend{i, j}, 'Location', obj.legend_location, 'Orientation', 'horizontal', 'Interpreter', 'latex', 'FontSize', obj.legend_fontsize);
                    end

                    hold(ax1, 'off')

                    cnt1 = cnt1 + 1;
                end

            end

            if strcmp(obj.legend_type, 'one-for-all')

                legend(obj.axs{end}, obj.legend{end, end}, 'Location', 'bestoutside', 'Orientation', 'horizontal');

            end

            sgtitle(obj.title, 'Interpreter', 'latex', 'FontSize', obj.title_fontsize);

            if strcmp(obj.xlim, 'auto')

                obj.check_xlim();

            end

            if strcmp(obj.ylim, 'auto')

                obj.check_ylim();

            end

        end

        function check_xlabel(obj)

            if ischar(obj.xlabel)

                if strcmp(obj.xlabel, 'auto')
                    obj.xlabel = {};

                    for i = 1:obj.num_rows

                        for j = 1:obj.num_cols

                            obj.xlabel{i, j} = ['$x$ Datapoint' num2str(i) num2str(j)];

                        end

                    end

                else

                    xlabel_ = obj.xlabel;
                    obj.xlabel = {};

                    for i = 1:obj.num_rows

                        for j = 1:obj.num_cols

                            obj.xlabel{i, j} = xlabel_;

                        end

                    end

                end

            elseif iscell(obj.xlabel) && size(obj.xlabel, 1) == obj.num_rows

                xlabel_ = obj.xlabel;
                obj.xlabel = {};

                for j = 1:obj.num_cols

                    for k = 1:length(xlabel_)

                        obj.xlabel{k, j} = xlabel_{k};

                    end

                end

            elseif iscell(obj.xlabel) && size(obj.xlabel, 2) == obj.num_cols

                xlabel_ = obj.xlabel;
                obj.xlabel = {};

                for i = 1:obj.num_rows

                    for k = 1:length(xlabel_)

                        obj.xlabel{i, k} = xlabel_{k};

                    end

                end

            elseif iscell(obj.xlabel) && size(obj.xlabel, 1) == obj.num_rows && size(obj.xlabel, 2) == obj.num_cols

                disp(['x-axis labels are good!']);

            else

                error("Please assign proper x-axis labels for the figure");

            end

        end

        function check_ylabel(obj)

            if ischar(obj.ylabel)

                if strcmp(obj.ylabel, 'auto');

                    obj.ylabel = {};

                    for i = 1:obj.num_rows

                        for j = 1:obj.num_cols

                            obj.ylabel{i, j} = ['$y$ Datapoint' num2str(i) num2str(j)];

                        end

                    end

                else

                    ylabel_ = obj.ylabel;
                    obj.ylabel = {};

                    for i = 1:obj.num_rows

                        for j = 1:obj.num_cols

                            obj.ylabel{i, j} = ylabel_;

                        end

                    end

                end

            elseif iscell(obj.ylabel) && size(obj.ylabel, 1) == obj.num_rows

                ylabel_ = obj.ylabel;
                obj.ylabel = {};

                for j = 1:obj.num_cols

                    for k = 1:length(ylabel_)

                        obj.ylabel{k, j} = ylabel_{k};

                    end

                end

            elseif iscell(obj.ylabel) && size(obj.ylabel, 2) == obj.num_cols

                ylabel_ = obj.ylabel;
                obj.ylabel = {};

                for i = 1:obj.num_rows

                    for k = 1:length(ylabel_)

                        obj.ylabel{i, k} = ylabel_{k};

                    end

                end

            elseif iscell(obj.ylabel) && size(obj.ylabel, 1) == obj.num_rows && size(obj.ylabel, 2) == obj.num_cols

                disp(['y-axis labels are good!']);

            else

                error("Please assign proper y-axis labels for the figure");

            end

        end

        function check_subtitle(obj)

            if ischar(obj.subtitle)

                if strcmp(obj.subtitle, 'auto');

                    obj.subtitle = {};

                    for i = 1:obj.num_rows

                        for j = 1:obj.num_cols

                            obj.subtitle{i, j} = ['Subtitle' num2str(i) num2str(j)];

                        end

                    end

                else

                    subtitle_ = obj.subtitle;
                    obj.subtitle = {};

                    for i = 1:obj.num_rows

                        for j = 1:obj.num_cols

                            obj.subtitle{i, j} = subtitle_;

                        end

                    end

                end

            elseif iscell(obj.subtitle) && size(obj.subtitle, 1) == obj.num_rows

                subtitle_ = obj.subtitle;
                obj.subtitle = {};

                for j = 1:obj.num_cols

                    for k = 1:length(subtitle_)

                        obj.subtitle{k, j} = subtitle_{k};

                    end

                end

            elseif iscell(obj.subtitle) && size(obj.subtitle, 2) == obj.num_cols

                subtitle_ = obj.subtitle;
                obj.subtitle = {};

                for i = 1:obj.num_rows

                    for k = 1:length(subtitle_)

                        obj.subtitle{i, k} = subtitle_{k};

                    end

                end

            elseif iscell(obj.subtitle) && size(obj.subtitle, 1) == obj.num_rows && size(obj.subtitle, 2) == obj.num_cols

                disp(['Subtitles are good!']);

            else

                error("Please assign proper subtitles for the figure");

            end

        end

        function check_title(obj)

            if strcmp(obj.title, 'auto');

                obj.title = 'Main Title';

            end

        end

        function check_legend(obj)

            if ischar(obj.legend)

                if strcmp(obj.legend, 'auto');

                    obj.legend = {};

                    for i = 1:obj.num_rows

                        for j = 1:obj.num_cols

                            for k = 1:length(obj.dataset{i, j})

                                obj.legend{i, j}{k} = ['Legend' num2str(i) num2str(j) num2str(k)];

                            end

                        end

                    end

                else

                    legend_ = obj.legend;
                    obj.legend = {};

                    for i = 1:obj.num_rows

                        for j = 1:obj.num_cols

                            for k = 1:length(obj.dataset{i, j})

                                obj.legend{i, j}{k} = legend_;

                            end

                        end

                    end

                end

            elseif iscell(obj.legend)

                legend_ = obj.legend;
                obj.legend = {};

                for i = 1:obj.num_rows

                    for j = 1:obj.num_cols

                        obj.legend{i, j} = legend_;

                    end

                end

            elseif iscell(obj.legend) && size(obj.legend, 1) == obj.num_rows && size(obj.legend, 2) == obj.num_cols

                disp(['Legends are good!']);

            else

                error("Please assign proper legends for the figure");

            end

        end

        function check_color(obj)

            if strcmp(obj.colors, 'auto');

                obj.colors = {};

                for i = 1:obj.num_rows

                    for j = 1:obj.num_cols

                        if ~obj.grouping

                            obj.grouping_number = 1;

                        end

                        obj.colors{i, j} = distinguishable_colors(length(obj.dataset{i, j}) / obj.grouping_number);

                    end

                end

            end

        end

        function check_xlim(obj)

            for k = 1:obj.num_rows * obj.num_cols

                axes_xlims_(k, :) = obj.axs{k}.XLim;

            end

            min_axes_xlim_ = min(axes_xlims_, [], 1);
            max_axes_xlim_ = max(axes_xlims_, [], 1);

            for k = 1:length(obj.axs)

                obj.axs{k}.XLim(1) = min_axes_xlim_(1);
                obj.axs{k}.XLim(2) = max_axes_xlim_(2);

            end

        end

        function check_ylim(obj)

            for k = 1:obj.num_rows * obj.num_cols

                axes_ylims_(k, :) = obj.axs{k}.YLim;

            end

            min_axes_ylim_ = min(axes_ylims_, [], 1);
            max_axes_ylim_ = max(axes_ylims_, [], 1);

            for k = 1:length(obj.axs)

                obj.axs{k}.YLim(1) = min_axes_ylim_(1);
                obj.axs{k}.YLim(2) = max_axes_ylim_(2);

            end

        end

        function check_xdata(obj)

            for i = 1:obj.num_rows

                for j = 1:obj.num_cols

                    for k = 1:length(obj.dataset{i, j})

                        if length(obj.dataset{i, j}{k}) == 1

                            warning(['You did not include the x-data! It is being created by default'])
                            obj.dataset{i, j}{k} = {1:length(obj.dataset{i, j}{k}{:}), obj.dataset{i, j}{k}{:}}

                        end

                    end

                end

            end

        end

    end

end
