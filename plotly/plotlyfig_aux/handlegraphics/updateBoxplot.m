function obj = updateBoxplot(obj, boxIndex)
    % y: ...[DONE]
    % x0: ...[DONE]
    % x: ...[DONE]
    % name: ...[DONE]
    % boxmean: ...[NOT SUPPORTED IN MATLAB]
    % boxpoints: ...[NOT SUPPORTED IN MATLAB]
    % jitter: ...[NOT SUPPORTED IN MATLAB]
    % pointpos: ...[NOT SUPPORTED IN MATLAB]
    % whiskerwidth: ........................[TODO]
    % fillcolor: ...[DONE]
    % opacity: ---[TODO]
    % xaxis: ...[DONE]
    % yaxis: ...[DONE]
    % showlegend: ...[DONE]
    % stream: ...[HANDLED BY PLOTLY STREAM]
    % visible: ...[DONE]
    % type: ...[DONE]

    % MARKER
    % color: ...[NA]
    % width: ...[NA]
    % dash: ...[NA]
    % opacity: ...[NA]
    % shape: ...[NA]
    % smoothing: ...[NA]
    % outliercolor: ...[NOT SUPPORTED IN MATLAB]
    % outlierwidth: ...[NOT SUPPORTED IN MATLAB]

    % LINE
    % color: ...[DONE]
    % width: ...[DONE]
    % dash: ...[DONE]
    % opacity: ---[TODO]
    % shape: ...[DONE]
    % smoothing: ...[NOT SUPPORTED IN MATLAB]

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(boxIndex).AssociatedAxis);

    %-BOX DATA STRUCTURE-%
    box_data = obj.State.Plot(boxIndex).Handle;

    %-BOX CHILDREN-%
    box_child = get(box_data, 'Children');

    %-CONFIRM PROPER BOXPLOT STRUCTURE-%

    % check for compact boxplot
    isCompact = ~isempty(findobj(obj.State.Plot(boxIndex).Handle, ...
            'Tag','Whisker'));

    % number of boxplots
    if isCompact
        bpcompnum = 6;
        bpnum = length(box_child)/bpcompnum;
        % check for assumed box structure
        if mod(length(box_child), bpcompnum) ~= 0
            updateAlternativeBoxplot(obj, boxIndex);
            return
        end
    else
        bpcompnum = 8;
        bpnum = length(box_child)/bpcompnum;
        % check for assumed box structure
        if mod(length(box_child),bpcompnum) ~= 0
            updateAlternativeBoxplot(obj, boxIndex);
            return
        end
    end

    ydata = [];
    obj.layout.bargroupgap = 1/bpnum;
    obj.data{boxIndex}.name = get(box_data, 'DisplayName');

    % iterate through box plot children in reverse order
    for bp = bpnum:-1:1
        %-CHECK FOR MULTIPLE AXES-%
        [xsource, ysource] = findSourceAxis(obj,axIndex);

        %-AXIS DATA-%
        xaxis = obj.layout.(sprintf("xaxis%d", xsource));
        obj.data{boxIndex}.xaxis = sprintf("x%d", xsource);
        obj.data{boxIndex}.yaxis = sprintf("y%d", ysource);
        obj.data{boxIndex}.type = 'box';
        obj.data{boxIndex}.visible = strcmp(get(box_data, 'Visible'),'on');
        obj.data{boxIndex}.fillcolor = 'rgba(0, 0, 0, 0)';

        obj.data{boxIndex}.showlegend = getShowLegend(box_data);

        %-boxplot components-%
        Q1 = [];
        Q3 = [];
        median = [];
        outliers = [];
        uwhisker = [];
        lwhisker = [];

        % iterate through boxplot components
        for bpc = 1:bpcompnum
            %get box child data
            box_child_data = box_child(bp+bpnum*(bpc-1));

            %box name
            if strcmp(get(box_child_data, 'Type'),'text')
                if iscell(get(box_child_data, 'String'))
                    boxString = get(box_child_data, 'String');
                    boxname = boxString{1};
                else
                    boxname = get(box_child_data, 'String');
                end
            end

            % parse boxplot tags
            switch get(box_child_data, 'Tag')
                case 'Median'
                    tmpYData = get(box_child_data, 'YData');
                    median =  tmpYData(1);
                case 'Upper Whisker'
                    uwhisker = tmpYData(2);

                    %-boxplot whisker width-%
                    obj.data{boxIndex}.whiskerwidth = 1;
                case 'Lower Whisker'
                    lwhisker = tmpYData(1);
                case 'Box'
                    Q1 = min(get(box_child_data, 'YData'));
                    Q3 = max(get(box_child_data, 'YData'));

                    %-boxplot line style-%
                    if isCompact
                        col = round(255*get(box_child_data, 'Color'));
                        obj.data{boxIndex}.fillcolor = getStringColor(col);
                    else
                        obj.data{boxIndex}.line = ...
                                extractLineLine(box_child_data);
                    end
                case 'Outliers'
                    if ~isnan(get(box_child_data, 'YData'))
                        %-outlier marker data-%

                        outliers = get(box_child_data, 'YData');
                        %-outlier marker style-%
                        obj.data{boxIndex}.marker = ...
                                extractLineMarker(box_child_data);
                    end
                case 'Whisker'
                    %-boxplot line style-%
                    obj.data{boxIndex}.line = ...
                            extractLineLine(box_child_data);

                    %-boxplot whisker width-%
                    obj.data{boxIndex}.whiskerwidth = 0;

                    %-whisker data-%
                    uwhisker = tmpYData(2);
                    lwhisker = tmpYData(1);
                case 'MedianInner'
                    median = tmpYData(1);
            end
        end

        %-generate boxplot data-%
        gendata = generateBoxData(outliers, lwhisker, Q1, median, Q3, ...
                uwhisker);

        %-boxplot y-data-%
        obj.data{boxIndex}.y(length(ydata)+1:length(ydata)+length(gendata)) = ...
                generateBoxData(outliers, lwhisker, Q1, median, Q3, uwhisker);

        %-boxplot x-data-%
        if (bpnum > 1)
            for n = (length(ydata)+1):(length(ydata)+length(gendata))
                obj.data{boxIndex}.x{n} = boxname;
            end
        end

        %-update ydata-%
        ydata = obj.data{boxIndex}.y;
    end

    % take first text object as prototype for axis tick style/layout
    text_child = findobj(obj.State.Plot(boxIndex).Handle, 'Type', 'text');

    %-STANDARDIZE UNITS-%
    fontunits = get(text_child(1), 'FontUnits');
    set(text_child(1), 'FontUnits', 'points');

    text_data = text_child(1);
    xaxis.tickfont.size = get(text_data, 'FontSize');
    xaxis.tickfont.family = matlab2plotlyfont(get(text_data, 'FontName'));
    xaxis.tickfont.color = get(text_data, 'Color');
    xaxis.type = 'category';
    xaxis.showticklabels = true;
    xaxis.autorange = true;

    obj.layout.(sprintf("xaxis%d", xsource)) = xaxis;

    %-REVERT UNITS-%
    set(text_child(1), 'FontUnits', fontunits);
end
