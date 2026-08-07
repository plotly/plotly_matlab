function [axis, exponentFormat] = extractAxisData(obj,axisData,axisName)
    % extract information related to each axis
    %   axisData is the data extracted from the figure, axisName take the
    %   values "x" "y" or "z"

    axisColor = getStringColor(round(255 * get(axisData, sprintf("%sColor", axisName))));
    lineWidth = max(1, ...
            get(axisData, 'LineWidth')*obj.PlotlyDefaults.AxisLineIncreaseFactor);

    if isprop(axisData, sprintf("%sAxis", axisName)) ...
            && isprop(get(axisData, sprintf("%sAxis", axisName)), "Exponent")
        exponentFormat = get(get(axisData, sprintf("%sAxis", axisName)), 'Exponent');
    else
        exponentFormat = 0;
    end

    tmpTickLength = get(axisData, 'TickLength');
    axisPosition = get(axisData, 'Position');
    tickLength = min(obj.PlotlyDefaults.MaxTickLength, ...
        max(tmpTickLength(1)*axisPosition(3)*obj.layout.width, ...
        tmpTickLength(1)*axisPosition(4)*obj.layout.height));

    axis = struct(...
        "side", get(axisData, sprintf("%sAxisLocation", axisName)), ...
        "zeroline", false, ...
        "autorange", false, ...
        "linecolor", axisColor, ...
        "linewidth", lineWidth, ...
        "exponentformat", obj.PlotlyDefaults.ExponentFormat, ...
        "tickfont", struct( ...
            "size", get(axisData, 'FontSize'), ...
            "family", matlab2plotlyfont(get(axisData, 'FontName')), ...
            "color", axisColor ...
        ), ...
        "ticklen", tickLength, ...
        "tickcolor", axisColor, ...
        "tickwidth", lineWidth, ...
        "tickangle", -get(axisData, sprintf("%sTickLabelRotation", axisName)), ...
        "type", get(axisData, sprintf("%sScale", axisName)) ...
    );

    switch get(axisData, 'TickDir')
        case "in"
            axis.ticks = "inside";
        case "out"
            axis.ticks = "outside";
    end

    isGrid = get(axisData, sprintf("%sGrid", axisName));
    isMinorGrid = get(axisData, sprintf("%sMinorGrid", axisName));
    if strcmp(isGrid, "on") || strcmp(isMinorGrid, "on")
        axis.showgrid = true;
        axis.gridwidth = lineWidth;
    else
        axis.showgrid = false;
    end

    if isprop(axisData, "GridColor") && isprop(axisData, "GridAlpha")
        axis.gridcolor = getStringColor( ...
                round(255*get(axisData, 'GridColor')), get(axisData, 'GridAlpha'));
    else
        axis.gridcolor = axisColor;
    end

    tickLabels = get(axisData, sprintf("%sTickLabel", axisName));
    tickValues = get(axisData, sprintf("%sTick", axisName));

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

        switch get(axisData, 'Box')
            case "on"
                axis.mirror = true;
            case "off"
                axis.mirror = false;
        end
    else % There are tick labels
        axis.showticklabels = true;
        axis.tickmode = "array";

        if ~isa(tickValues, "categorical")
            axis.tickvals = tickValues;
            % a single tick (numeric scalar or single date string) must
            % be an array for plotly
            if isscalar(tickValues) || ...
                    (ischar(tickValues) && size(tickValues, 1) == 1)
                axis.tickvals = {tickValues};
            end
        end

        %-set axis limits-%
        axisLim = get(axisData, sprintf("%sLim", axisName));

        if isnumeric(axisLim)
            if any(~isfinite(axisLim))
                axis.range = shrinkInfLimits(axisData, axisLim, axisName);
            elseif strcmp(axis.type, "linear")
                axis.range = axisLim;
            elseif strcmp(axis.type, "log")
                axis.range = log10(axisLim);
            end
        elseif isa(axisLim, "duration")
            [temp,type] = convertDuration(axisLim);
            if (~isa(temp, "duration")) % duration class has specified .Format
                axis.range = temp;
                axis.type = "duration";
                axis.title = type;
                axis.tickvals = convertDuration(axis.tickvals);
            else
                nticks = length(get(axisData, sprintf("%sTick", axisName)))-1;
                delta = 0.1;
                axis.range = [-delta nticks+delta];
                axis.type = "duration - specified format";
            end
        elseif isa(axisLim, "datetime")
            axis.range = axisLim;
            axis.type = "date";
            if isprop(axisData, "XTickLabelMode") ...
                    && isequal(get(axisData, 'XTickLabelMode'), "auto")
                axis.autotick = true;
                tickLabels = {};
            end

        elseif isa(axisLim, "categorical")
            axis.autorange = true;
            axis.type = "category";
        else
            axis.autorange = true;
        end

        switch get(axisData, 'Box')
            case "on"
                axis.mirror = "ticks";
            case "off"
                axis.mirror = false;
        end

        if ~isempty(tickLabels)
            axis.ticktext = tickLabels;
        end
    end

    axisDirection = get(axisData, sprintf("%sDir", axisName));

    if strcmp(axisDirection, "reverse")
        axis.range = [axis.range(2) axis.range(1)];
    end

    label = get(axisData, sprintf("%sLabel", axisName));
    labelData = label;

    %-STANDARDIZE UNITS-%
    fontunits = get(label, 'FontUnits');
    set(label, 'FontUnits', 'points');

    if ~isempty(get(labelData, 'String'))
        axis.title = struct( ...
            "text", parseString(get(labelData, 'String'),get(labelData, 'Interpreter')) ...
        );
    end

    axis.titlefont.color = getStringColor(round(255*get(labelData, 'Color')));
    axis.titlefont.size = get(labelData, 'FontSize');
    axis.titlefont.family = matlab2plotlyfont(get(labelData, 'FontName'));

    %-REVERT UNITS-%
    set(label, 'FontUnits', fontunits);

    if strcmp(get(axisData, 'Visible'), "on")
        axis.showline = true;
    else
        axis.showticklabels = false;
        axis.showline = false;
        axis.showgrid = false;
        axis.ticks = "";
    end
end

function lim = shrinkInfLimits(axis, lim, axisName)
    plots = get(axis, 'Children');
    plots = plots(~arrayfun( ...
            @(x) isa(x,"matlab.graphics.chart.decoration.ConstantLine"), ...
            plots));
    if ~isempty(plots)
        dataRange = [Inf -Inf];
        for i = 1:numel(plots)
            dataRange(1) = min(dataRange(1),min(get(plots(i), sprintf("%sData", axisName))));
            dataRange(2) = max(dataRange(2),max(get(plots(i), sprintf("%sData", axisName))));
        end
        dataRange = dataRange + [-1 1]*diff(dataRange)/8; % add some margin
    else
        dataRange = [0 1]; % matches default y-axis from `figure; xline(1)`
    end
    toShrink = ~isfinite(lim);
    lim(toShrink) = dataRange(toShrink);
end
