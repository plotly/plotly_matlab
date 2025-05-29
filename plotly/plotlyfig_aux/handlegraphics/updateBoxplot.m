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
    box_child = box_data.Children;

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
    obj.data{boxIndex}.name = box_data.DisplayName;

    % iterate through box plot children in reverse order
    for bp = bpnum:-1:1
        %-CHECK FOR MULTIPLE AXES-%
        [xsource, ysource] = findSourceAxis(obj,axIndex);

        %-AXIS DATA-%
        xaxis = obj.layout.("xaxis" + xsource);
        obj.data{boxIndex}.xaxis = "x" + xsource;
        obj.data{boxIndex}.yaxis = "y" + ysource;
        obj.data{boxIndex}.type = 'box';
        obj.data{boxIndex}.visible = strcmp(box_data.Visible,'on');
        obj.data{boxIndex}.fillcolor = 'rgba(0, 0, 0, 0)';

        switch box_data.Annotation.LegendInformation.IconDisplayStyle
            case "on"
                obj.data{boxIndex}.showlegend = true;
            case "off"
                obj.data{boxIndex}.showlegend = false;
        end

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
            if strcmp(box_child_data.Type,'text')
                if iscell(box_child_data.String)
                    boxname =  box_child_data.String{1};
                else
                    boxname =  box_child_data.String;
                end
            end

            % parse boxplot tags
            switch box_child_data.Tag
                case 'Median'
                    median =  box_child_data.YData(1);
                case 'Upper Whisker'
                    uwhisker = box_child_data.YData(2);

                    %-boxplot whisker width-%
                    obj.data{boxIndex}.whiskerwidth = 1;
                case 'Lower Whisker'
                    lwhisker = box_child_data.YData(1);
                case 'Box'
                    Q1 = min(box_child_data.YData);
                    Q3 = max(box_child_data.YData);

                    %-boxplot line style-%
                    if isCompact
                        col = round(255*box_child_data.Color);
                        obj.data{boxIndex}.fillcolor = getStringColor(col);
                    else
                        obj.data{boxIndex}.line = ...
                                extractLineLine(box_child_data);
                    end
                case 'Outliers'
                    if ~isnan(box_child_data.YData)
                        %-outlier marker data-%

                        outliers = box_child_data.YData;
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
                    uwhisker = box_child_data.YData(2);
                    lwhisker = box_child_data.YData(1);
                case 'MedianInner'
                    median = box_child_data.YData(1);
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
    fontunits = text_child(1).FontUnits;
    text_child(1).FontUnits = 'points';

    text_data = text_child(1);
    xaxis.tickfont.size = text_data.FontSize;
    xaxis.tickfont.family = matlab2plotlyfont(text_data.FontName);
    xaxis.tickfont.color = text_data.Color;
    xaxis.type = 'category';
    xaxis.showticklabels = true;
    xaxis.autorange = true;

    obj.layout.("xaxis" + xsource) = xaxis;

    %-REVERT UNITS-%
    text_child(1).FontUnits = fontunits;
end
