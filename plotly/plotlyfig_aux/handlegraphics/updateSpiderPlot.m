function obj = updateSpiderPlot(obj,spiderIndex)
    %-INITIALIZATIONS-%
    axIndex = obj.getAxisIndex(obj.State.Plot(spiderIndex).AssociatedAxis);
    plotData = obj.State.Plot(spiderIndex).Handle;
    [xSource, ySource] = findSourceAxis(obj, axIndex);

    nTraces = size(plotData.P, 1);
    isLegend = false;

    axesStruct = setAxes(obj, spiderIndex);
    updateSpiderLayout(obj, spiderIndex);
    setAnnotation(obj, axesStruct, spiderIndex);

    if ~isempty(plotData.LegendHandle)
        isLegend = true;
        setLegeng(obj, spiderIndex);
    end

    %-set traces-%
    for t = 1:nTraces
        %-get plotIndex-%
        obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
        plotIndex = obj.PlotOptions.nPlots;

        %-associate axis-%
        obj.data{plotIndex}.xaxis = sprintf('x%d', xSource);
        obj.data{plotIndex}.yaxis = sprintf('y%d', ySource);

        %-trace settings-%
        obj.data{plotIndex}.type = 'scatter';
        obj.data{plotIndex}.mode = 'lines+markers';

        if strcmp(plotData.Marker{t, 1}, 'none')
            obj.data{plotIndex}.mode = 'lines';
        end

        %-set data-%
        [xData, yData] = getCartesianPoints(plotData, axesStruct, t);

        obj.data{plotIndex}.x = xData;
        obj.data{plotIndex}.y = yData;

        %-marker settings-%
        obj.data{plotIndex}.marker = getMarker(plotData, t);

        %-line settings-%
        obj.data{plotIndex}.line = getLine(plotData, t);

        %-fill area-%
        if strcmp(plotData.FillOption{t}, 'on')
            [fillColor, ~] = getColor(plotData.Color, t, ...
                plotData.FillTransparency);
            obj.data{plotIndex}.fillcolor = fillColor;
            obj.data{plotIndex}.fill = 'toself';
        end

        %-legend-%
        if isLegend
            if strcmp(plotData.LegendHandle.Visible, 'on')
                obj.data{plotIndex}.name = plotData.LegendLabels{t};
                obj.data{plotIndex}.showlegend = true;
            end
        end
    end
end

function [xData, yData] = getCartesianPoints(plotData, axesStruct, traceIndex)
    %-initializations-%
    rData = plotData.P(traceIndex, :);
    axesAngle = axesStruct.axesAngle;
    nAxes = axesStruct.nAxes;
    nTicks = axesStruct.nTicks;

    for a = 1:nAxes
        %-get axis limits-%
        try
            axesLim = plotData.AxesLimits(:, a)';
        catch
            axesLim = [min(plotData.P(:, a)), max(plotData.P(:, a))];
        end

        %-normalize radial data-%
        rPoint = [rData(a), axesLim];
        if strcmpi(plotData.AxesScaling(a), 'log')
            rPoint = log10(rPoint);
        end
        if strcmpi(plotData.AxesDirection(a), 'reverse');
            rPoint = -rPoint;
        end
        rPoint = rescale(rPoint, 1/nTicks, 1);

        %-conversion-%
        xData(a) = rPoint(1) * cos(axesAngle(a));
        yData(a) = rPoint(1) * sin(axesAngle(a));
    end

    %-return-%
    xData = [xData, xData(1)];
    yData = [yData, yData(1)];
end

function lineStruct = getLine(plotData, traceIndex)
    [lineColor, ~] = getColor(plotData.Color, traceIndex, ...
        plotData.LineTransparency);

    lineStruct = struct( ...
        "color", lineColor, ...
        "width", plotData.LineWidth(traceIndex), ...
        "dash", getLineDash(plotData.LineStyle{traceIndex, 1}) ...
    );
end

function markerStruct = getMarker(plotData, traceIndex)
    markerStruct = struct();

    [markerColor, ~] = getColor(plotData.Color, traceIndex, ...
        plotData.MarkerTransparency);
    markerStruct.color = markerColor;
    markerStruct.line.color = markerColor;
    markerStruct.size = plotData.MarkerSize(traceIndex, 1) * 0.2;

    if ~strcmp(plotData.Marker{traceIndex, 1}, "none")
        markerStruct.symbol = getMarkerSymbol(plotData.Marker{traceIndex, 1});
    end
end

function setAnnotation(obj, axesStruct, spiderIndex)
    %-INITIALIZATIONS-%
    axIndex = obj.getAxisIndex(obj.State.Plot(spiderIndex).AssociatedAxis);
    anIndex = obj.PlotlyDefaults.anIndex;

    plotData = obj.State.Plot(spiderIndex).Handle;
    [xSource, ySource] = findSourceAxis(obj, axIndex);

    axesLabels = plotData.AxesLabels;
    axesLabelsOffset = plotData.AxesLabelsOffset * 0.5;
    axesDisplay = plotData.AxesDisplay;
    axesFontColor = plotData.AxesFontColor;
    axesPrecision = plotData.AxesPrecision;
    axesLabelsEdge = plotData.AxesLabelsEdge;

    nAxes = axesStruct.nAxes;
    axesAngle = axesStruct.axesAngle;
    nTicks = axesStruct.nTicks;
    if strcmp(axesDisplay, 'data')
        nTicks = size(plotData.P, 1);
    end

    labelColor = 'rgb(0,0,0)';
    labelSize = plotData.LabelFontSize;
    labelFamily = matlab2plotlyfont(plotData.LabelFont);

    nAxesFontColor = size(axesFontColor, 1);
    axesSize = plotData.AxesFontSize;
    axesFamily = matlab2plotlyfont(plotData.AxesFont);

    %-set axes labels-%
    for l = 1:nAxes
        %-create annotation-%
        annotations{anIndex}.showarrow = false;
        annotations{anIndex}.xref = sprintf('x%d', xSource);
        annotations{anIndex}.yref = sprintf('y%d', ySource);
        annotations{anIndex}.bgcolor = 'rgba(0,0,0,0)';
        annotations{anIndex}.bordercolor = getLabelEdgeColor(axesLabelsEdge);
        annotations{anIndex}.borderwidth = 1;
        annotations{anIndex}.borderpad = labelSize * 0.5;

        %-text label-%
        textLabel = axesLabels{l};
        if isempty(textLabel)
            textLabel = parseString(textLabel, 'tex');
        end

        annotations{anIndex}.text = textLabel;

        %-location-%
        lastXTick = cos(axesAngle(l));
        lastYTick = sin(axesAngle(l));

        if abs(lastXTick) < 1e-3
            annotations{anIndex}.x = lastXTick;
            annotations{anIndex}.xanchor = 'middle';
        elseif lastXTick > 0
            annotations{anIndex}.x = lastXTick + axesLabelsOffset;
            annotations{anIndex}.xanchor = 'left';
        elseif lastXTick < 0
            annotations{anIndex}.x = lastXTick - axesLabelsOffset;
            annotations{anIndex}.xanchor = 'right';
        end

        if abs(lastYTick) < 1e-3
            annotations{anIndex}.y = lastYTick;
            annotations{anIndex}.yanchor = 'middle';
        elseif lastYTick > 0
            annotations{anIndex}.y = lastYTick + axesLabelsOffset;
            annotations{anIndex}.yanchor = 'bottom';
        elseif lastYTick < 0
            annotations{anIndex}.y = lastYTick - axesLabelsOffset;
            annotations{anIndex}.yanchor = 'top';
        end

        %-font properties-%
        annotations{anIndex}.font.color = labelColor;
        annotations{anIndex}.font.size = labelSize;
        annotations{anIndex}.font.family = labelFamily;

        %-update annotation Index-%
        anIndex = anIndex + 1;
    end

    %-set axes tick labels-%
    for t = 1:nTicks
        indexColor = mod(t-1, nAxesFontColor) + 1;
        axesColor = round(255*axesFontColor(indexColor, :));
        axesColor = getStringColor(axesColor);
        for a = 1:nAxes
            %-create annotation-%
            annotations{anIndex}.showarrow = false;
            annotations{anIndex}.xref = sprintf('x%d', xSource);
            annotations{anIndex}.yref = sprintf('y%d', ySource);
            annotations{anIndex}.bgcolor = 'rgba(0,0,0,0)';
            annotations{anIndex}.bordercolor = 'rgba(0,0,0,0)';

            %-get tick label-%
            try
                axesLim = plotData.AxesLimits(:, a)';
            catch
                axesLim = [min(plotData.P(:, a)), max(plotData.P(:, a))];
            end

            if strcmp(axesDisplay, 'data')
                tickLabel = plotData.P(t, a);

            else
                tickLabel = linspace(axesLim(1), axesLim(2), nTicks);
                tickLabel = tickLabel(t);

                if strcmpi(plotData.AxesScaling(a), 'log')
                    tickLabel = 10^(t-1);
                end
            end

            %-get tick value-%
            tickValue = [tickLabel, axesLim];

            if strcmpi(plotData.AxesScaling(a), 'log')
                tickValue = log10(tickValue);
            end

            if strcmpi(plotData.AxesDirection(a), 'reverse');
                tickValue = -1 * tickValue;
            end

            tickValue = rescale(tickValue, 1/axesStruct.nTicks, 1);
            tickValue = tickValue(1);

            %-set tick label-%
            tickLabel = num2str(tickLabel, sprintf('%%.%df', axesPrecision(a)));
            annotations{anIndex}.text = tickLabel;

            %-set tick location-%
            annotations{anIndex}.x = tickValue * cos(axesAngle(a));
            annotations{anIndex}.y = tickValue * sin(axesAngle(a));
            annotations{anIndex}.xanchor = plotData.AxesHorzAlign;
            annotations{anIndex}.yanchor = plotData.AxesVertAlign;
            annotations{anIndex}.align = plotData.AxesHorzAlign;

            if strcmp(axesDisplay, 'data')
                if annotations{anIndex}.y > 0
                    annotations{anIndex}.yanchor = 'bottom';
                elseif annotations{anIndex}.y < 0
                    annotations{anIndex}.yanchor = 'top';
                end

                if abs(annotations{anIndex}.x) < 1e-3
                    annotations{anIndex}.xanchor = 'middle';
                elseif annotations{anIndex}.x > 0
                    annotations{anIndex}.xanchor = 'left';
                elseif annotations{anIndex}.x < 0
                    annotations{anIndex}.xanchor = 'right';
                end
            end

            %-font properties-%
            annotations{anIndex}.font.color = axesColor;
            annotations{anIndex}.font.size = axesSize;
            annotations{anIndex}.font.family = axesFamily;

            %-update annotation Index-%
            anIndex = anIndex + 1;

            %-stop according AxesDisplay-%
            if strcmp(axesDisplay, 'one')
                if a==1
                    break;
                end
            elseif strcmp(axesDisplay, 'two')
                if a==2
                    break;
                end
            elseif strcmp(axesDisplay, 'three')
                if a==3
                    break;
                end
            end
        end
    end

    obj.layout.annotations = annotations;
    obj.PlotlyDefaults.anIndex = anIndex;
end

function axesStruct = setAxes(obj, spiderIndex)
    %-INITIALIZATIONS-%
    axIndex = obj.getAxisIndex(obj.State.Plot(spiderIndex).AssociatedAxis);
    plotData = obj.State.Plot(spiderIndex).Handle;
    [xSource, ySource] = findSourceAxis(obj, axIndex);

    %-set axes-%
    nAxes = size(plotData.P,2);
    angleStep = 2*pi/nAxes;
    axesAngle = [pi/2];
    plotIndex = spiderIndex;
    axesColor = getStringColor(round(255*plotData.AxesColor));

    for a = 1:nAxes
        %-get plotIndex-%
        if a > 1
            obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
            plotIndex = obj.PlotOptions.nPlots;
        end

        %-set axes-%
        obj.data{plotIndex}.xaxis = sprintf('x%d', xSource);
        obj.data{plotIndex}.yaxis = sprintf('y%d', ySource);

        obj.data{plotIndex}.type = 'scatter';
        obj.data{plotIndex}.mode = 'lines';
        obj.data{plotIndex}.line.color = axesColor;
        obj.data{plotIndex}.line.width = 1.75;

        obj.data{plotIndex}.x = [0, cos(axesAngle(a))];
        obj.data{plotIndex}.y = [0, sin(axesAngle(a))];

        %-update axesAngle list-%
        if a ~= nAxes
            if strcmp(plotData.Direction, 'clockwise')
                axesAngle(a+1) = axesAngle(a) - angleStep;
            else
                axesAngle(a+1) = axesAngle(a) + angleStep;
            end
        end

        %-hide associated trace-%
        obj.data{plotIndex}.showlegend = false;
    end

    %-set grid-%
    nTicks = plotData.AxesInterval + 1;
    tickValues = linspace(1/nTicks, 1, nTicks);
    xData = cos([axesAngle, axesAngle(1)]);
    yData = sin([axesAngle, axesAngle(1)]);

    for g = 1:nTicks
        %-get plotIndex-%
        obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
        plotIndex = obj.PlotOptions.nPlots;

        %-set current line grid-%
        obj.data{plotIndex}.xaxis = sprintf('x%d', xSource);
        obj.data{plotIndex}.yaxis = sprintf('y%d', ySource);

        obj.data{plotIndex}.type = 'scatter';
        obj.data{plotIndex}.mode = 'lines';
        obj.data{plotIndex}.line.color = axesColor;
        obj.data{plotIndex}.line.width = 0.4;

        obj.data{plotIndex}.x = tickValues(g)*xData;
        obj.data{plotIndex}.y = tickValues(g)*yData;

        %-hide associated trace-%
        obj.data{plotIndex}.showlegend = false;
    end

    %-return-%
    axesStruct.axesAngle = axesAngle;
    axesStruct.nAxes = nAxes;
    axesStruct.nTicks = nTicks;
    axesStruct.tickValues = tickValues;
end

function updateSpiderLayout(obj, spiderIndex)
    %-INITIALIZATIONS-%
    axIndex = obj.getAxisIndex(obj.State.Plot(spiderIndex).AssociatedAxis);
    plotData = obj.State.Plot(spiderIndex).Handle;
    [xSource, ySource] = findSourceAxis(obj, axIndex);

    xo = plotData.Position(1);
    yo = plotData.Position(2);
    w = plotData.Position(3);
    h = plotData.Position(4);

    %-get x axis-%
    xaxis.domain = min([xo xo + w],1);
    xaxis.range = [-1.5, 1.5];
    xaxis.showline = false;
    xaxis.zeroline = false;
    xaxis.showgrid = false;
    xaxis.showticklabels = false;

    %-get y axis-%
    yaxis.domain = min([yo yo + h],1);
    yaxis.range = [-1.25, 1.25];
    yaxis.showline = false;
    yaxis.zeroline = false;
    yaxis.showgrid = false;
    yaxis.showticklabels = false;

    obj.layout.(sprintf('xaxis%d', xSource)) = xaxis;
    obj.layout.(sprintf('yaxis%d', ySource)) = yaxis;
end

function setLegeng(obj, spiderIndex)
    %-INITIALIZATIONS-%
    plotData = obj.State.Plot(spiderIndex).Handle;

    legData = plotData.LegendHandle;
    obj.layout.showlegend = strcmpi(plotData.Visible,'on');

    %-legend location-%
    obj.layout.legend.x = legData.Position(1);
    obj.layout.legend.y = legData.Position(2);
    obj.layout.legend.xref = 'paper';
    obj.layout.legend.yref = 'paper';
    obj.layout.legend.xanchor = 'left';
    obj.layout.legend.yanchor = 'top';

    %-legend settings-%
    if (strcmp(legData.Box, 'on') && strcmp(legData.Visible, 'on'))
        edgeColor = round(255*legData.EdgeColor);
        bgColor = round(255*legData.Color);
        textColor = round(255*legData.TextColor);

        obj.layout.legend.traceorder = 'normal';
        obj.layout.legend.borderwidth = legData.LineWidth;
        obj.layout.legend.bordercolor = getStringColor(edgeColor);
        obj.layout.legend.bgcolor = getStringColor(bgColor);
        obj.layout.legend.font.size = legData.FontSize;
        obj.layout.legend.font.family = matlab2plotlyfont(legData.FontName);
        obj.layout.legend.font.color = getStringColor(textColor);
    end
end

function [strColor, numColor] = getColor(colorMatrix, traceIndex, ...
    colorOpacities)

    colorOpacity = 1;

    if nargin > 2
        colorOpacity = colorOpacities(traceIndex);
    end

    nColors = size(colorMatrix, 1);
    colorIndex = mod(traceIndex-1, nColors) + 1;
    numColor = round(255*colorMatrix(colorIndex, :));
    strColor = getStringColor(numColor, colorOpacity);
end

function edgeColor = getLabelEdgeColor(axesLabelsEdge)
    if isnumeric(axesLabelsEdge)
        edgeColor = getStringColor(round(255*axesLabelsEdge));
    elseif strcmp(axesLabelsEdge, "none")
        edgeColor = "rgba(0,0,0,0)";
    else
        switch axesLabelsEdge
            case {'b', 'blue'}
                edgeColor = 'rgb(0,0,1)';
            case {'k', 'black'}
                edgeColor = 'rgb(0,0,0)';
            case {'r', 'red'}
                edgeColor = 'rgb(1,0,0)';
            case {'g', 'green'}
                edgeColor = 'rgb(0,1,0)';
            case {'y', 'yellow'}
                edgeColor = 'rgb(1,1,0)';
            case {'c', 'cyan'}
                edgeColor = 'rgb(0,1,1)';
            case {'m', 'magenta'}
                edgeColor = 'rgb(1,0,1)';
            case {'w', 'white'}
                edgeColor = 'rgb(1,1,1)';
        end
    end
end
