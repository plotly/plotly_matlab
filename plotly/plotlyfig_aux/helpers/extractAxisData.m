function [axis, exponentFormat] = extractAxisData(obj,axisData,axisName)
    % extract information related to each axis
    %   axisData is the data extrated from the figure, axisName take the
    %   values "x" "y" or "z"

    %=====================================================================%
    %
    % AXIS INITIALIZATION
    %
    %=====================================================================%

    %-general axis settings-%
    axisColor = 255 * axisData.(axisName + "Color");
    axisColor = sprintf("rgb(%f,%f,%f)", axisColor);
    lineWidth = max(1, ...
            axisData.LineWidth*obj.PlotlyDefaults.AxisLineIncreaseFactor);

    try
        exponentFormat = axisData.(axisName + "Axis").Exponent;
    catch
        exponentFormat = 0;
    end

    axis.side = axisData.(axisName + "AxisLocation");
    axis.zeroline = false;
    axis.autorange = false;
    axis.linecolor = axisColor;
    axis.linewidth = lineWidth;
    axis.exponentformat = obj.PlotlyDefaults.ExponentFormat;

    %---------------------------------------------------------------------%

    %-general tick settings-%
    tickRotation = axisData.(axisName + "TickLabelRotation");
    tickLength = min(obj.PlotlyDefaults.MaxTickLength,...
        max(axisData.TickLength(1)*axisData.Position(3)*obj.layout.width,...
        axisData.TickLength(1)*axisData.Position(4)*obj.layout.height));

    axis.tickfont.size = axisData.FontSize;
    axis.tickfont.family = matlab2plotlyfont(axisData.FontName);
    axis.tickfont.color = axisColor;

    axis.ticklen = tickLength;
    axis.tickcolor = axisColor;
    axis.tickwidth = lineWidth;
    axis.tickangle = -tickRotation;

    switch axisData.TickDir
        case "in"
            axis.ticks = "inside";
        case "out"
            axis.ticks = "outside";
    end

    %---------------------------------------------------------------------%

    %-set axis grid-%
    isGrid = axisData.(axisName + "Grid");
    isMinorGrid = axisData.(axisName + "MinorGrid");

    if strcmp(isGrid, "on") || strcmp(isMinorGrid, "on")
        axis.showgrid = true;
        axis.gridwidth = lineWidth;
    else
        axis.showgrid = false;
    end

    %---------------------------------------------------------------------%

    %-axis grid color-%
    try
        gridColor = 255*axisData.GridColor;
        gridAlpha = axisData.GridAlpha;
        axis.gridcolor = sprintf("rgba(%f,%f,%f,%f)", gridColor, gridAlpha);
    catch
        axis.gridcolor = axisColor;
    end

    %---------------------------------------------------------------------%

    %-axis type-%
    axis.type = axisData.(axisName + "Scale");

    %=====================================================================%
    %
    % SET TICK LABELS
    %
    %=====================================================================%

    %-get tick label data-%
    tickLabels = axisData.(axisName + "TickLabel");
    tickValues = axisData.(axisName + "Tick");

    %---------------------------------------------------------------------%

    %-there is not tick label case-%
    if isempty(tickValues)
        axis.ticks = "";
        axis.showticklabels = false;
        axis.autorange = true; 

        switch axisData.Box
            case "on"
                axis.mirror = true;
            case "off"
                axis.mirror = false;
        end
    else %-there is tick labels case-%
        %-set tick values-%
        axis.showticklabels = true;
        axis.tickmode = "array";

        if ~iscategorical(tickValues)
            axis.tickvals = tickValues;
        end

        %-set axis limits-%
        axisLim = axisData.(axisName + "Lim");

        if isnumeric(axisLim)
            if any(~isfinite(axisLim))
                axis.range = shrinkInfLimits(axisData, axisLim, axisName);
            elseif strcmp(axis.type, "linear")
                axis.range = axisLim;
            elseif strcmp(axis.type, "log")
                axis.range = log10(axisLim);
            end
        elseif isduration(axisLim)
            [temp,type] = convertDuration(axisLim);
            if (~isduration(temp)) % duration class has specified .Format
                axis.range = temp;
                axis.type = "duration";
                axis.title = type;
                axis.tickvals = convertDuration(axis.tickvals);
            else
                nticks = length(axisData.(axisName + "Tick"))-1;
                delta = 0.1;
                axis.range = [-delta nticks+delta];
                axis.type = "duration - specified format";
            end
        elseif isdatetime(axisLim)
            axis.range = axisLim;
            axis.type = "date";
        elseif iscategorical(axisLim)
            axis.autorange = true;
            axis.type = "category";
        else
            axis.autorange = true;
        end

        %-box setting-%
        switch axisData.Box
            case "on"
                axis.mirror = "ticks";
            case "off"
                axis.mirror = false;
        end

        %-set tick labels by using tick texts-%
        if ~isempty(tickLabels)
            axis.ticktext = tickLabels;
        end
    end

    %---------------------------------------------------------------------%

    %-axis direction-%
    axisDirection = axisData.(axisName + "Dir");

    if strcmp(axisDirection, "reverse")
        axis.range = [axis.range(2) axis.range(1)];
    end

    %=====================================================================%
    %
    % SET AXIS LABEL
    %
    %=====================================================================%

    %-get label data-%
    label = axisData.(axisName + "Label");
    labelData = label;

    %---------------------------------------------------------------------%

    %-STANDARDIZE UNITS-%
    fontunits = label.FontUnits;
    label.FontUnits = "points";

    %---------------------------------------------------------------------%

    %-title label settings-%
    if ~isempty(labelData.String)
        axis.title = parseString(labelData.String,labelData.Interpreter);
    end

    axis.titlefont.color = sprintf("rgb(%f,%f,%f)", 255*labelData.Color);
    axis.titlefont.size = labelData.FontSize;
    axis.titlefont.family = matlab2plotlyfont(labelData.FontName);

    %---------------------------------------------------------------------%

    %-REVERT UNITS-%
    label.FontUnits = fontunits;

    %---------------------------------------------------------------------%

    %-set visibility conditions-%
    if strcmp(axisData.Visible, "on")
        axis.showline = true;
    else
        axis.showticklabels = false;
        axis.showline = false;
        axis.ticks = "";
    end
end

function lim = shrinkInfLimits(axis, lim, axisName)
    arguments
        axis
        lim
        axisName (1,1) string {mustBeMember(axisName,["Y" "X"])}
    end
    plots = axis.Children;
    plots = plots(~arrayfun( ...
            @(x) isa(x,"matlab.graphics.chart.decoration.ConstantLine"), ...
            plots));
    if ~isempty(plots)
        dataRange = [Inf -Inf];
        for i = 1:numel(plots)
            dataRange(1) = min(dataRange(1),min(plots(i).(axisName+"Data")));
            dataRange(2) = max(dataRange(2),max(plots(i).(axisName+"Data")));
        end
        dataRange = dataRange + [-1 1]*diff(dataRange)/8; % add some margin
    else
        dataRange = [0 1]; % matches default y-axis from `figure; xline(1)`
    end
    toShrink = ~isfinite(lim);
    lim(toShrink) = dataRange(toShrink);
end
