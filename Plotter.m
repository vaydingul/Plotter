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

            obj.check_xlabel();
            obj.check_ylabel();
            obj.check_subtitle();
            obj.check_title();
            obj.check_legend();
            obj.check_color();

            obj.axs = {};

        end

        function plot(obj)

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
                            skip_cnt = fix((cnt2 - 1) , obj.grouping_number) + 1;
                            
                            if strcmp(obj.linestyle_group , 'successive')

                                linestyle_cnt = successive_cnt;

                            elseif strcmp(obj.line_group , 'skip')

                                linestyle_cnt = skip_cnt;

                            else

                                error("Please assign proper grouping type!")
                            
                            end

                            if strcmp(obj.linewidth_group , 'successive')

                                linewidth_cnt = successive_cnt;

                            elseif strcmp(obj.linewidth_group , 'skip')

                                linewidth_cnt = skip_cnt;

                            else

                                error("Please assign proper grouping type!")
                            
                            end

                            if strcmp(obj.color_group , 'successive')

                                color_cnt = successive_cnt;

                            elseif strcmp(obj.color_group , 'skip')

                                color_cnt = skip_cnt;

                            else

                                error("Please assign proper grouping type!")
                            
                            end


                        end

                        obj.plot_handle(ax1, data_x, data_y,...
                            'LineStyle', obj.linestyles{linestyle_cnt}, ...
                            'Color', obj.colors{color_cnt, :}, ...
                            'LineWidth', obj.linewidths{linewidth_cnt});
						
						cnt2 = cnt2 + 1;
                    end

                    xlabel(ax1, obj.xlabel{i, j}, 'Interpreter', 'latex', 'FontSize', obj.label_fontsize);
                    ylabel(ax1, obj.ylabel{i, j}, 'Interpreter', 'latex', 'FontSize', obj.label_fontsize);
                    title(ax1, obj.subtitle{i, j}, 'Interpreter', 'latex', 'FontSize', obj.subtitle_fontsize);

                    if strcmp(obj.legend_type , 'each')
                        legend(ax1, obj.legend{i, j}, 'Location', obj.legend_location, 'Orientation', 'horizontal', 'Interpreter', 'latex', 'FontSize', obj.legend_fontsize);
                    end

                    hold(ax1, 'off')

                    cnt1 = cnt1 + 1;
                end

            end

            if strcmp(obj.legend_type , 'one-for-all')

                legend(obj.legend{1}, 'Location', 'bestoutside', 'Orientation', 'horizontal');

            end

            sgtitle(obj.title, 'Interpreter', 'latex', 'FontSize', obj.title_fontsize);

            if obj.xlim == 'auto'

                obj.check_xlim();

            end

            if obj.ylim == 'auto'

                obj.check_ylim();

            end

        end

    end

    methods (Access = private)

        function check_xlabel(obj)

            if obj.xlabel == 'auto';

                obj.xlabel = {};

                for i = 1:obj.num_rows

                    for j = 1:obj.num_cols

                        obj.xlabel{i, j} = ['$x$ Datapoint' num2str(i) num2str(j)];

                    end

                end

            elseif ischar(obj.xlabel)

                xlabel_ = obj.xlabel;
                obj.xlabel = {};

                for i = 1:obj.num_rows

                    for j = 1:obj.num_cols

                        obj.xlabel{i, j} = xlabel_;

                    end

                end

            elseif iscell(obj.xlabel) && size(obj.xlabel, 1) == num_rows

                xlabel_ = obj.xlabel;
                obj.xlabel = {};

                for j = 1:obj.num_cols

                    obj.xlabel{:, j} = xlabel_;

                end

            elseif iscell(obj.xlabel) && size(obj.xlabel, 2) == num_cols

                xlabel_ = obj.xlabel;
                obj.xlabel = {};

                for i = 1:obj.num_rows

                    obj.xlabel{i, :} = xlabel_;

                end

            elseif iscell(obj.xlabel) && size(obj.xlabel, 1) == num_rows && size(obj.xlabel, 2) == num_cols

                disp(['x-axis labels are good!']);

            else

                error("Please assign proper x-axis labels for the figure");

            end

        end

        function check_ylabel(obj)

            if obj.ylabel == 'auto';

                obj.ylabel = {};

                for i = 1:obj.num_rows

                    for j = 1:obj.num_cols

                        obj.ylabel{i, j} = ['$y$ Datapoint' num2str(i) num2str(j)];

                    end

                end

            elseif ischar(obj.ylabel)

                ylabel_ = obj.ylabel;
                obj.ylabel = {};

                for i = 1:obj.num_rows

                    for j = 1:obj.num_cols

                        obj.ylabel{i, j} = ylabel_;

                    end

                end

            elseif iscell(obj.ylabel) && size(obj.ylabel, 1) == num_rows

                ylabel_ = obj.ylabel;
                obj.ylabel = {};

                for j = 1:obj.num_cols

                    obj.ylabel{:, j} = ylabel_;

                end

            elseif iscell(obj.ylabel) && size(obj.ylabel, 2) == num_cols

                ylabel_ = obj.ylabel;
                obj.ylabel = {};

                for i = 1:obj.num_rows

                    obj.ylabel{i, :} = ylabel_;

                end

            elseif iscell(obj.ylabel) && size(obj.ylabel, 1) == num_rows && size(obj.ylabel, 2) == num_cols

                disp(['y-axis labels are good!']);

            else

                error("Please assign proper y-axis labels for the figure");

            end

        end

        function check_subtitle(obj)

            if obj.subtitle == 'auto';

                obj.subtitle = {};

                for i = 1:obj.num_rows

                    for j = 1:obj.num_cols

                        obj.subtitle{i, j} = ['Subtitle' num2str(i) num2str(j)];

                    end

                end

            elseif ischar(obj.subtitle)

                subtitle_ = obj.subtitle;
                obj.subtitle = {};

                for i = 1:obj.num_rows

                    for j = 1:obj.num_cols

                        obj.subtitle{i, j} = subtitle_;

                    end

                end

            elseif iscell(obj.subtitle) && size(obj.subtitle, 1) == num_rows

                subtitle_ = obj.subtitle;
                obj.subtitle = {};

                for j = 1:obj.num_cols

                    obj.subtitle{:, j} = subtitle_;

                end

            elseif iscell(obj.subtitle) && size(obj.subtitle, 2) == num_cols

                subtitle_ = obj.subtitle;
                obj.subtitle = {};

                for i = 1:obj.num_rows

                    obj.subtitle{i, :} = subtitle_;

                end

            elseif iscell(obj.subtitle) && size(obj.subtitle, 1) == num_rows && size(obj.subtitle, 2) == num_cols

                disp(['Subtitles are good!']);

            else

                error("Please assign proper subtitles for the figure");

            end

        end

        function check_title(obj)

            if obj.title == 'auto';

                obj.title = 'Main Title';

            end

        end

        function check_legend(obj)

            if obj.legend == 'auto';

                obj.legend = {};

                for i = 1:obj.num_rows

                    for j = 1:obj.num_cols

                        for k = 1:length(obj.dataset{i, j})

                            obj.legend{i, j}{k} = ['Legend' num2str(i) num2str(j) num2str(k)];

                        end

                    end

                end

            elseif ischar(obj.legend)

                legend_ = obj.legend;
                obj.legend = {};

                for i = 1:obj.num_rows

                    for j = 1:obj.num_cols

                        for k = 1:length(obj.dataset{i, j})

                            obj.legend{i, j}{k} = legend_;

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

            elseif iscell(obj.legend) && size(obj.legend, 1) == num_rows && size(obj.legend, 2) == num_cols

                disp(['Legends are good!']);

            else

                error("Please assign proper legends for the figure");

            end

        end

        function check_color(obj)

            if obj.colors == 'auto';

                obj.colors =  {};
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

    end

end