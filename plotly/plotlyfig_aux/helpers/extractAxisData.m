function [axis, exponentFormat] = extractAxisData(obj,axisData,axisName)
    % extract information related to each axis
    %   axisData is the data extracted from the figure, axisName take the
    %   values "x" "y" or "z"

    axisColor = getStringColor(round(255 * axisData.(axisName + "Color")));
    lineWidth = max(1, ...
            axisData.LineWidth*obj.PlotlyDefaults.AxisLineIncreaseFactor);

    if isprop(axisData, axisName + "Axis") ...
            && isprop(axisData.(axisName + "Axis"), "Exponent")
        exponentFormat = axisData.(axisName + "Axis").Exponent;
    else
        exponentFormat = 0;
    end

    tickLength = min(obj.PlotlyDefaults.MaxTickLength, ...
        max(axisData.TickLength(1)*axisData.Position(3)*obj.layout.width, ...
        axisData.TickLength(1)*axisData.Position(4)*obj.layout.height));

    axis = struct(...
        "side", axisData.(axisName + "AxisLocation"), ...
        "zeroline", false, ...
        "autorange", false, ...
        "linecolor", axisColor, ...
        "linewidth", lineWidth, ...
        "exponentformat", obj.PlotlyDefaults.ExponentFormat, ...
        "tickfont", struct( ...
            "size", axisData.FontSize, ...
            "family", matlab2plotlyfont(axisData.FontName), ...
            "color", axisColor ...
        ), ...
        "ticklen", tickLength, ...
        "tickcolor", axisColor, ...
        "tickwidth", lineWidth, ...
        "tickangle", -axisData.(axisName + "TickLabelRotation"), ...
        "type", axisData.(axisName + "Scale") ...
    );

    switch axisData.TickDir
        case "in"
            axis.ticks = "inside";
        case "out"
            axis.ticks = "outside";
    end

    isGrid = axisData.(axisName + "Grid");
    isMinorGrid = axisData.(axisName + "MinorGrid");
    if strcmp(isGrid, "on") || strcmp(isMinorGrid, "on")
        axis.showgrid = true;
        axis.gridwidth = lineWidth;
    else
        axis.showgrid = false;
    end

    if isprop(axisData, "GridColor") && isprop(axisData, "GridAlpha")
        axis.gridcolor = getStringColor( ...
                round(255*axisData.GridColor), axisData.GridAlpha);
    else
        axis.gridcolor = axisColor;
    end

    tickLabels = axisData.(axisName + "TickLabel");
    tickValues = axisData.(axisName + "Tick");

    if ischar(tickLabels)
        tickLabels = cellstr(tickLabels);
    end
    if numel(tickLabels) < numel(tickValues)
        tickLabels = [
            tickLabels; repelem({''},numel(tickValues)-numel(tickLabels),1)
        ];
    end
    if numel(tickLabels) > numel(tickValues)
        tickLabels = tickLabels(1:numel(tickValues));
    end
    assert(isequal(numel(tickLabels),numel(tickValues)));

    if isempty(tickValues) % There are no tick labels
        axis.ticks = "";
        axis.showticklabels = false;
        axis.autorange = true;

        switch axisData.Box
            case "on"
                axis.mirror = true;
            case "off"
                axis.mirror = false;
        end
    else % There are tick labels
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
            if isprop(axisData, "XTickLabelMode") ...
                    && isequal(axisData.XTickLabelMode, "auto")
                axis.autotick = true;
                tickLabels = {};
            end

        elseif iscategorical(axisLim)
            axis.autorange = true;
            axis.type = "category";
        else
            axis.autorange = true;
        end

        switch axisData.Box
            case "on"
                axis.mirror = "ticks";
            case "off"
                axis.mirror = false;
        end

        if ~isempty(tickLabels)
            axis.ticktext = tickLabels;
        end
    end

    axisDirection = axisData.(axisName + "Dir");

    if strcmp(axisDirection, "reverse")
        axis.range = [axis.range(2) axis.range(1)];
    end

    label = axisData.(axisName + "Label");
    labelData = label;

    %-STANDARDIZE UNITS-%
    fontunits = label.FontUnits;
    label.FontUnits = "points";

    if ~isempty(labelData.String)
        axis.title = parseString(labelData.String,labelData.Interpreter);
    end

    axis.titlefont.color = getStringColor(round(255*labelData.Color));
    axis.titlefont.size = labelData.FontSize;
    axis.titlefont.family = matlab2plotlyfont(labelData.FontName);

    %-REVERT UNITS-%
    label.FontUnits = fontunits;

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
