function updateScatterhistogram(obj, plotIndex)
    %-INITIALIZATIONS-%

    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    plotData = obj.State.Plot(plotIndex).Handle;

    [~, ~, groupName] = getTraceData(plotData);

    %-SET MAIN SCATTER PLOT-%

    %-set plotly layout-%
    updateMainScatterAxis(obj, plotIndex);
    updateTitle(obj, plotIndex);
    updateLegend(obj, plotIndex, groupName);
    obj.layout.barmode = 'overlay';
    obj.layout.bargap = 0.05;

    %-set plotly data-%
    updateMainScatter(obj, plotIndex);

    %-SET MARGINAL PLOTS-%

    %-set plotly layout-%
    updateXMarginalAxis(obj, plotIndex);
    updateYMarginalAxis(obj, plotIndex);

    %-set plotly data-%
    switch plotData.HistogramDisplayStyle
        case 'stairs'
            updateMarginalHistogram(obj, plotIndex, 'X');
            updateMarginalHistogram(obj, plotIndex, 'Y');
        case 'smooth'
            updateMarginalSmooth(obj, plotIndex, 'X');
            updateMarginalSmooth(obj, plotIndex, 'Y');
    end
end

function updateMainScatter(obj, plotIndex)
    %-INITIALIZATIONS-%

    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    plotData = obj.State.Plot(plotIndex).Handle;
    [xSource, ySource] = findSourceAxis(obj,axIndex);

    %-get trace data-%
    traceIndex = plotIndex;
    [xData, yData, groupName] = getTraceData(plotData);

    %-SET ALL TRACES-%

    for t = 1:length(xData)
        %-get current trace index-%
        if t > 1
            obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
            traceIndex = obj.PlotOptions.nPlots;
        end

        %-set current trace-%
        obj.data{traceIndex}.type = 'scatter';
        obj.data{traceIndex}.mode = 'markers';
        obj.data{traceIndex}.xaxis = sprintf('x%d', xSource);
        obj.data{traceIndex}.yaxis = sprintf('y%d', ySource);
        obj.data{traceIndex}.visible = strcmp(plotData.Visible,'on');

        %-set current trace data-%
        obj.data{traceIndex}.x = xData{t};
        obj.data{traceIndex}.y = yData{t};

        %-scatter marker-%
        childmarker = extractScatterhistogramMarker(plotData, t);
        obj.data{traceIndex}.marker = childmarker;

        %-legend-%
        if ~isempty(groupName)
            try
              obj.data{traceIndex}.name = char(groupName(t));
            catch
              obj.data{traceIndex}.name = char(string(groupName(t)));
            end
            obj.data{traceIndex}.legendgroup = obj.data{traceIndex}.name;
            obj.data{traceIndex}.showlegend = true;
        end
    end
end

function updateMainScatterAxis(obj, plotIndex)
    %-INITIALIZATIONS-%

    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    plotData = obj.State.Plot(plotIndex).Handle;
    [xSource, ySource] = findSourceAxis(obj,axIndex);

    xaxis = getMainScatterAxis(plotData, 'X');
    xaxis.anchor = sprintf('y%d', xSource);
    obj.layout.(sprintf('xaxis%d', xSource)) = xaxis;

    yaxis = getMainScatterAxis(plotData, 'Y');
    yaxis.anchor = sprintf('x%d', ySource);
    obj.layout.(sprintf('yaxis%d', ySource)) = yaxis;
end

function ax = getMainScatterAxis(plotData, axName)
    axisPos = plotData.Position;
    axisColor = 'rgba(0,0,0, 0.9)';
    axisLim = plotData.(axName + "Limits");
    axisPlot = plotData.(axName + "Data");
    axisLabel = plotData.(axName + "Label");

    switch axName
        case 'X'
            axisDomain = min([axisPos(1) sum(axisPos([1 3]))], 1);
        case 'Y'
            axisDomain = min([axisPos(2) sum(axisPos([2 4]))], 1);
    end

    %-general-%
    ax.domain = axisDomain;
    ax.linecolor = axisColor;
    ax.zeroline = true;
    ax.showgrid = false;
    ax.mirror = 'ticks';

    %-ticks-%
    ax.showticklabels = true;
    ax.ticks = 'inside';
    ax.tickfont.size = 1.2*plotData.FontSize;
    ax.tickcolor = axisColor;
    ax.tickfont.family = matlab2plotlyfont(plotData.FontName);

    %-label-%
    ax.title.text = axisLabel;
    if ~isempty(axisLabel)
        axisLabel = parseString(axisLabel);
    end
    ax.title.font.size = 1.2*plotData.FontSize;
    ax.title.font.color = 1.2*axisColor;
    ax.title.font.family = matlab2plotlyfont(plotData.FontName);

    %-range and ticklabels-%
    if ~iscategorical(axisPlot)
        ax.range = axisLim;
        ax.nticks = 10;
    else
        [axCateg, ~, axisPlot] = unique(axisPlot);
        ax.range = [min(axisPlot)-0.5, max(axisPlot)+0.5];
        ax.tickvals = 1:max(axisPlot);
        for n=1:length(axCateg), ax.ticktext{n} = char(axCateg(n)); end
    end
end

function updateMarginalHistogram(obj, plotIndex, axName)
    %-INITIALIZATIONS-%
    plotData = obj.State.Plot(plotIndex).Handle;
    if strcmp(axName, 'X')
        xySource = 1;
    else
        xySource = 2;
    end
    xySource = obj.State.Figure.NumAxes + xySource;

    %-get trace data-%
    [xData, yData, groupName] = getTraceData(plotData);


    %-SET ALL TRACES-%
    for t = 1:length(xData)
        %-get current trace index-%
        obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
        traceIndex = obj.PlotOptions.nPlots;

        %-set current trace-%
        obj.data{traceIndex}.type = 'histogram';
        obj.data{traceIndex}.xaxis = sprintf('x%d', xySource);
        obj.data{traceIndex}.yaxis = sprintf('y%d', xySource);

        %-set current plot data-%
        obj.data{traceIndex}.x = xData{t};
        obj.data{traceIndex}.y = yData{t};

        %-set other trace properties-%
        traceColor = getStringColor(plotData.Color(t,:), 0.7);

        obj.data{traceIndex}.marker.color = traceColor;
        obj.data{traceIndex}.histnorm = 'probability';
        obj.data{traceIndex}.histfunc = 'count';
        obj.data{traceIndex}.showlegend = false;

        switch axName
            case 'X'
                obj.data{traceIndex}.orientation = 'v';
                try obj.data{traceIndex}.nbinsx = plotData.NumBins(1,t); end
            case 'Y'
                obj.data{traceIndex}.orientation = 'h';
                try obj.data{traceIndex}.nbinsy = plotData.NumBins(2,t); end
        end

        %-link legend-%
        if ~isempty(groupName)
            try
                obj.data{traceIndex}.name = char(groupName(t));
            catch
                obj.data{traceIndex}.name = char(string(groupName(t)));
            end
            obj.data{traceIndex}.legendgroup = obj.data{traceIndex}.name;
        end
    end
end

function updateMarginalSmooth(obj, plotIndex, axName)
    %-INITIALIZATIONS-%
    plotData = obj.State.Plot(plotIndex).Handle;
    if strcmp(axName, 'X')
        xySource = 1;
    else
        xySource = 2;
    end
    xySource = obj.State.Figure.NumAxes + xySource;

    %-get trace data-%
    [xData, yData, groupName] = getTraceData(plotData);
    axisLim = getAxisLim(plotData, axName);
    evalPoints = linspace(axisLim(1), axisLim(2), 500);

    %-SET ALL TRACES-%
    for t = 1:length(xData)
        %-get current trace index-%
        obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
        traceIndex = obj.PlotOptions.nPlots;

        %-set current trace-%
        obj.data{traceIndex}.type = 'scatter';
        obj.data{traceIndex}.mode = 'lines';
        obj.data{traceIndex}.xaxis = sprintf('x%d', xySource);
        obj.data{traceIndex}.yaxis = sprintf('y%d', xySource);

        %-get current trace data-%
        if strcmp(axName, 'X')
            [ySmooth, xSmooth] = ksdensity(xData{t}, evalPoints);
        elseif strcmp(axName, 'Y')
            [xSmooth, ySmooth] = ksdensity(yData{t}, evalPoints);
        end

        %-set current plot data-%
        obj.data{traceIndex}.x = xSmooth;
        obj.data{traceIndex}.y = ySmooth;

        %-set other trace properties-%
        traceColor = getStringColor(plotData.Color(t,:), 0.7);
        lineStyle = plotData.LineStyle(t);

        obj.data{traceIndex}.line.color = traceColor;
        obj.data{traceIndex}.line.width = 2*plotData.LineWidth(t);
        obj.data{traceIndex}.line.dash = getLineDash(lineStyle);
        obj.data{traceIndex}.showlegend = false;

        %-link legend-%
        if ~isempty(groupName)
            try
                obj.data{traceIndex}.name = char(groupName(t));
            catch
                obj.data{traceIndex}.name = char(string(groupName(t)));
            end

            obj.data{traceIndex}.legendgroup = obj.data{traceIndex}.name;
        end
    end
end

function updateXMarginalAxis(obj, plotIndex)
    %-INITIALIZATIONS-%
    plotData = obj.State.Plot(plotIndex).Handle;

    xySource = obj.State.Figure.NumAxes + 1;

    xaxis = getXMarginalAxis(plotData, 'X');
    xaxis.anchor = sprintf('y%d', xySource);
    obj.layout.(sprintf('xaxis%d', xySource)) = xaxis;

    yaxis = getXMarginalAxis(plotData, 'Y');
    yaxis.anchor = sprintf('x%d', xySource);
    obj.layout.(sprintf('yaxis%d', xySource)) = yaxis;
end

function ax = getXMarginalAxis(plotData, axName)
    switch axName
        case 'X'
            ax.showline = true;
            ax.linecolor = 'black';
            ax.range = getAxisLim(plotData, 'X');
        case 'Y'
            ax.showline = false;
    end

    ax.domain = getXMarginalDomain(plotData, axName);
    ax.showgrid = false;
    ax.showticklabels = false;
    ax.zeroline = false;
end

function axisDomain = getXMarginalDomain(plotData, axName)
    axisPos = plotData.Position;
    plotLocation = plotData.ScatterPlotLocation;
    isTitle = ~isempty(plotData.Title);

    switch axName
        case 'X'
            axisDomain = min([axisPos(1) sum(axisPos([1,3]))], 1);
        case 'Y'
            if contains(plotLocation, 'South')
                yo = axisPos(2) + axisPos(4) + 0.01;
                if isTitle
                    h=0.9-yo;
                else
                    h = 0.96 - yo;
                end
            elseif contains(plotLocation, 'North')
                yo = 0.02; h = axisPos(2)*0.7-yo;
            end
            axisDomain = min([yo yo+h], 1);
    end
end

function updateYMarginalAxis(obj, plotIndex)
    %-INITIALIZATIONS-%
    plotData = obj.State.Plot(plotIndex).Handle;

    xySource = obj.State.Figure.NumAxes + 2;

    xaxis = getYMarginalAxis(plotData, 'X');
    xaxis.anchor = sprintf('y%d', xySource);
    obj.layout.(sprintf('xaxis%d', xySource)) = xaxis;

    yaxis = getYMarginalAxis(plotData, 'Y');
    yaxis.anchor = sprintf('x%d', xySource);
    obj.layout.(sprintf('yaxis%d', xySource)) = yaxis;
end

function ax = getYMarginalAxis(plotData, axName)
    switch axName
        case 'X'
            ax.showline = false;
        case 'Y'
            ax.showline = true;
            ax.linecolor = 'black';
            ax.range = getAxisLim(plotData, 'Y');
    end
    ax.domain = getYMarginalDomain(plotData, axName);
    ax.showgrid = false;
    ax.showticklabels = false;
    ax.zeroline = false;
end

function axisDomain = getYMarginalDomain(plotData, axName)
    axisPos = plotData.Position;
    plotLocation = plotData.ScatterPlotLocation;
    switch axName
        case 'X'
            if contains(plotLocation, 'West')
                xo = axisPos(1) + axisPos(3) + 0.01;
                w = 0.96-xo;
            elseif contains(plotLocation, 'East')
                xo = 0.02; w = axisPos(1)*0.7-xo;
            end
            axisDomain = min([xo xo+w], 1);
        case 'Y'
            axisDomain = min([axisPos(2) sum(axisPos([2,4]))], 1);
    end
end

function axisLim = getAxisLim(plotData, axName)
    axisLim = plotData.(axName + "Limits");
    axisPlot = plotData.(axName + "Data");
    if iscategorical(axisPlot)
        axisPlot = plotData.(axName + "Data");
        [~, ~, axisPlot] = unique(axisPlot);
        axisLim = [min(axisPlot)-0.5, max(axisPlot)+0.5];
    end
end

function [xData, yData, groupName] = getTraceData(plotData)
    %-parcing data-%
    xPlot = plotData.XData;
    yPlot = plotData.YData;

    if iscategorical(xPlot)
        [~, ~, xPlot] = unique(xPlot);
    end
    if iscategorical(yPlot)
        [~, ~, yPlot] = unique(yPlot);
    end

    xData = {}; yData = {};
    groupData = plotData.GroupData;
    isByGroups = ~isempty(groupData);
    groupName = {};

    if isByGroups
        if iscellstr(groupData)
            groupData = string(groupData);
        end
        groupName = unique(groupData,'stable');
        for g = 1:length(groupName)
            groudInd = groupData == groupName(g);
            xData{g} = xPlot(groudInd);
            yData{g} = yPlot(groudInd);
        end
        if isnumeric(groupName)
            groupName=num2str(groupName);
        end
    else
        xData{1} = xPlot;
        yData{1} = yPlot;
    end
end

function updateTitle(obj, plotIndex)
    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    plotData = obj.State.Plot(plotIndex).Handle;
    xSource = findSourceAxis(obj,axIndex);
    isTitle = ~isempty(plotData.Title);

    obj.layout.annotations{1}.text = plotData.Title;
    obj.layout.annotations{1}.showarrow = false;

    if isTitle
        titleText = sprintf('<b>%s</b>', parseString(plotData.Title));
        titleFamily = matlab2plotlyfont(plotData.FontName);
        xaxis = obj.layout.("xaxis" + xSource);

        obj.layout.annotations{1}.text = titleText;
        obj.layout.annotations{1}.x = mean(xaxis.domain);
        obj.layout.annotations{1}.y = 0.96;
        obj.layout.annotations{1}.xref = 'paper';
        obj.layout.annotations{1}.yref = 'paper';
        obj.layout.annotations{1}.yanchor = 'top';
        obj.layout.annotations{1}.xanchor = 'middle';

        obj.layout.annotations{1}.font.color = 'black';
        obj.layout.annotations{1}.font.family = titleFamily;
        obj.layout.annotations{1}.font.size = 1.5*plotData.FontSize;
    end
end

function updateLegend(obj, plotIndex, groupName)
    plotData = obj.State.Plot(plotIndex).Handle;

    if ~isempty(groupName)
        fontFamily = matlab2plotlyfont(plotData.FontName);
        legTitle = plotData.LegendTitle;
        plotLocation = plotData.ScatterPlotLocation;

        obj.layout.showlegend = true;
        obj.layout.legend.xref = 'paper';
        obj.layout.legend.valign = 'middle';
        obj.layout.legend.borderwidth = 1;
        obj.layout.legend.bordercolor = 'rgba(0,0,0,0.2)';
        obj.layout.legend.font.size = 1.0*plotData.FontSize;
        obj.layout.legend.font.family = fontFamily;

        if ~isempty(legTitle) > 0
            legTitle = sprintf('<b>%s</b>', parseString(legTitle));

            obj.layout.legend.title.text = legTitle;
            obj.layout.legend.title.side = 'top';
            obj.layout.legend.title.font.size = 1.2*plotData.FontSize;
            obj.layout.legend.title.font.color = 'black';
            obj.layout.legend.title.font.family = fontFamily;
        end

        if contains(plotLocation, 'SouthWest')
            obj.layout.legend.x = 0.96;
            obj.layout.legend.y = 0.96;
            obj.layout.legend.xanchor = 'right';
            obj.layout.legend.yanchor = 'top';
        elseif contains(plotLocation, 'NorthEast')
            obj.layout.legend.x = 0.02;
            obj.layout.legend.y = 0.02;
            obj.layout.legend.xanchor = 'left';
            obj.layout.legend.yanchor = 'bottom';
        end
    end
end
