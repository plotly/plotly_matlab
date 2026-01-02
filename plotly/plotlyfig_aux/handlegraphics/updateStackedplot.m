function updateStackedplot(obj, plotIndex)
    plotData = obj.State.Plot(plotIndex).Handle;
    lineData = plotData.LineProperties(end:-1:1);

    sourceTable = plotData.SourceTable;
    displayVariables = plotData.DisplayVariables;
    nTraces = length(plotData.AxesProperties);

    yData = cell(1,nTraces);
    if isempty(sourceTable)
        xData = plotData.XData;
        for t = 1:nTraces
            n = nTraces - t + 1;
            yData{t} = plotData.YData(:, n);
        end
    else
        if istimetable(sourceTable)
            xData = sourceTable.Properties.RowTimes;
        else
            xData = 1:size(sourceTable, 1);
        end
        for t = 1:nTraces
            n = nTraces - t + 1;
            yData{t} = sourceTable.(displayVariables{n});
        end
    end

    %-UPDATE STACKEDPLOT AXIS-%
    updateStackedplotAxis(obj, plotIndex)

    traceIndex = plotIndex;

    for t = 1:nTraces
        %-update current trace Index-%
        if t ~= 1
            obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
            traceIndex = obj.PlotOptions.nPlots;
        end

        %-set current trace-%
        data.type = "scatter";
        data.visible = plotData.Visible == "on";
        data.name = plotData.DisplayLabels{t};
        data.xaxis = "x1";
        data.yaxis = "y" + t;

        %-set current trace data-%
        data.x = xData;
        data.y = yData{t};

        %-set current trace marker-%
        switch lineData(t).PlotType
            case "scatter"
                markerSize = ones(size(xData)) * lineData(t).MarkerSize;
                data.mode = "markers";
                data.marker = extractLineMarker(lineData(t));
                data.marker.size = markerSize;
                data.marker.line.width = 1;
            otherwise
                data.mode = "lines";
                data.line = extractLineLine(lineData(t));
        end
        obj.data{traceIndex} = data;
    end
end

function updateStackedplotAxis(obj, plotIndex)
    plotData = obj.State.Plot(plotIndex).Handle;

    [xaxis, xExpoFormat] = getAxis(obj, plotIndex, "X");
    obj.layout.xaxis1 = xaxis{1};

    [yaxis, yExpoFormat] = getAxis(obj, plotIndex, "Y");

    for a = 1:length(yaxis)
        obj.layout.("yaxis" + a) = yaxis{a};
    end

    obj.layout.annotations{1} = updateTitle(obj, plotData.Title, [1, 3]);
    if xExpoFormat(1) ~= 0
        anIndex = obj.PlotlyDefaults.anIndex + 1;
        obj.layout.annotations{anIndex} = ...
                updateExponentFormat(obj, xExpoFormat(1), [1,1], "X");
        obj.PlotlyDefaults.anIndex = anIndex;
    end
    for a = 1:length(yExpoFormat)
        if yExpoFormat(a) ~= 0
            anIndex = obj.PlotlyDefaults.anIndex + 1;
            obj.layout.annotations{anIndex} = ...
                    updateExponentFormat(obj, yExpoFormat(a), [1, a], "Y");
            obj.PlotlyDefaults.anIndex = anIndex;
        end
    end
end

function [ax, expoFormat] = getAxis(obj, plotIndex, axName)
    plotData = obj.State.Plot(plotIndex).Handle;

    axisPos = plotData.Position;
    axisColor = getStringColor(zeros(1,3));
    lineWidth = 1;
    fontSize = plotData.FontSize;
    fontFamily = matlab2plotlyfont(plotData.FontName);;
    tickLen = 5;

    %-Parse parameters according to axisName (X or Y)
    switch axName
        case {"x", "X"}
            nAxis = 1;
            nTicks = [5, 12];
            axisLim{nAxis} = plotData.XLimits;
            axisLabel{nAxis} = plotData.XLabel;
            axisDomain{nAxis} = min([axisPos(1) sum(axisPos([1,3]))], 1);
            axisAnchor{nAxis} = "y1";

        case {"y", "Y"}
            nAxis = length(plotData.AxesProperties);
            yPos = linspace(axisPos(2), sum(axisPos([2,4])), nAxis+1);
            yOffset = diff(yPos)*0.1; yOffset(1) = 0;

            axisLim = cell(1,nAxis);
            axisLabel = cell(1,nAxis);
            axisDomain = cell(1,nAxis);
            axisAnchor = cell(1,nAxis);
            for a = 1:nAxis
                b = nAxis-a+1;
                axisLim{a} = plotData.AxesProperties(b).YLimits;
                axisLabel{a} = plotData.DisplayLabels{b};
                axisDomain{a} = min([yPos(a)+yOffset(a) yPos(a+1)], 1);
                axisAnchor{a} = "x1";
            end

            if nAxis < 4
                nTicks = [5, 8];
            else
                nTicks = [3, 5];
            end
    end

    %-GET EACH AXIS-%
    ax = cell(1,nAxis);
    expoFormat = zeros(1,nAxis);
    for a = 1:nAxis
        axis.domain = axisDomain{a};
        axis.anchor = axisAnchor{a};
        axis.range = axisLim{a};
        axis.side = "left";
        axis.mirror = false;
        axis.zeroline = false;
        axis.linecolor = axisColor;
        axis.linewidth = lineWidth;
        axis.exponentformat = obj.PlotlyDefaults.ExponentFormat;

        if plotData.GridVisible == "on"
            axis.showgrid = true;
            axis.gridwidth = lineWidth;
            axis.gridcolor = getStringColor(round(255*0.15*ones(1,3)), 0.15);
        else
            axis.showgrid = false;
        end

        if isnumeric(axisLim{a})
            [tickVals, tickText, expoFormat(a)] = getNumTicks(axisLim{a}, nTicks);
        elseif isduration(axisLim{a}) || isdatetime(axisLim{a})
            [tickVals, tickText] = getDateTicks(axisLim{a}, nTicks);
            expoFormat(a) = 0;
        end

        axis.showticklabels = true;
        axis.ticks = "inside";
        axis.ticklen = tickLen;
        axis.tickwidth = lineWidth;
        axis.tickfont.size = fontSize;
        axis.tickfont.family = fontFamily;
        axis.tickfont.color = axisColor;
        axis.tickvals = tickVals;
        axis.ticktext = tickText;

        if ~isempty(axisLabel{a})
            axis.title = parseString(axisLabel{a});
            axis.titlefont.color = axisColor;
            axis.titlefont.size = fontSize;
            axis.titlefont.family = fontFamily;
        end
        ax{a} = axis;
    end
end

function [tickVals, tickText] = getDateTicks(axisLim, nTicks)
    %-by year-%
    yearLim = year(axisLim);
    isYear = length(unique(yearLim)) > 1;
    refYear = [1, 2, 5];

    if isYear
        yearTick = getTickVals(yearLim, refYear, 1, nTicks);

        tickVals = NaT(1,length(yearTick));
        tickText = cell(1,length(yearTick));
        for n = 1:length(yearTick)
            tickVals(n) = datetime(yearTick(n),1,1,'Format','yy');
            tickText{n} = num2str(yearTick(n));
        end

        return;
    end

    %-by month-%
    monthLim = month(axisLim);
    isMonth = length(unique(monthLim)) > 1;

    if isMonth
        % TODO
        return
    end

    %-by day-%
    dayLim = day(axisLim);
    isDay = length(unique(dayLim)) > 1;
    refDay = [0.5, 1];

    if isDay
        dayTick = getTickVals(dayLim, refDay, 1, nTicks);
        hourTick = 24 * ( dayTick - fix(dayTick) );
        dayTick = fix(dayTick);

        tickVals = NaT(1,length(dayTick));
        tickText = cell(1,length(dayTick));
        for n = 1:length(dayTick)
            matDate = [yearLim(1),monthLim(1),dayTick(n),hourTick(n),0,0];
            tickVals(n) = datetime(matDate,'Format', 'MMM dd, HH:mm');
            tickText{n} = datestr(tickVals(n), 'mmm dd, HH:MM');
        end

        return;
    end
end

function [tickVals, tickText, expoFormat] = getNumTicks(axisLim, nTicks)
    refVals = [1, 2, 5];
    refPot = floor(log10(rangeLength(axisLim)));

    fixAxisLim = fix(axisLim);

    if ~all(fixAxisLim == 0)
        expoFormat = floor(log10(max(1, rangeLength(fixAxisLim))));
    else
        expoFormat = refPot;
    end

    if abs(expoFormat) < 3
        expoFormat = 0;
    end

    tickVals = getTickVals(axisLim, refVals, refPot, nTicks);

    tickText = cell(1,length(tickVals));
    for n = 1:length(tickVals)
        tickText{n} = num2str(tickVals(n)/10^expoFormat);
    end
end

function tickVals = getTickVals(axisLim, refVals, refPot, nTicks)
    done = false;

    for p = refPot:-1:refPot-1
        for v = refVals
            vp = v*10^p;

            startTick = axisLim(1) - mod(axisLim(1), vp);
            if startTick < axisLim
                startTick = startTick + vp;
            end
            endTick = axisLim(2) - mod(axisLim(2), vp);

            tickVals = startTick:vp:endTick;
            lenTicks = length(tickVals);

            if lenTicks >= nTicks(1) && lenTicks <= nTicks(2)
                done = true;
                break;
            end
        end

        if done
            break;
        end
    end
end

function ann = updateTitle(obj, titleText, xySource)
    xaxis = obj.layout.("xaxis" + xySource(1));
    yaxis = obj.layout.("yaxis" + xySource(2));
    if ~isempty(titleText)
        titleText = parseString(titleText);
    end
    ann = struct( ...
        "showarrow", false, ...
        "text", sprintf("<b>%s</b>", titleText), ...
        "xref", "paper", ...
        "yref", "paper", ...
        "x", mean(xaxis.domain), ...
        "y", yaxis.domain(2), ...
        "xanchor", "middle", ...
        "yanchor", "bottom", ...
        "font", struct( ...
            "size", 1.5*xaxis.tickfont.size, ...
            "color", xaxis.tickfont.color, ...
            "family", xaxis.tickfont.family ...
        ) ...
    );
end

function ann = updateExponentFormat(obj, expoFormat, xySource, axName)
    axName = lower(axName);
    xaxis = obj.layout.("xaxis" + xySource(1));
    yaxis = obj.layout.("yaxis" + xySource(2));

    exponentText = sprintf("\\times10^%d", expoFormat);
    exponentText = parseString(exponentText, "tex");

    ann = struct( ...
        "showarrow", false, ...
        "text", exponentText, ...
        "xref", "paper", ...
        "yref", "paper", ...
        "font", struct( ...
            "size", eval(sprintf("%saxis.tickfont.size", axName)), ...
            "color", eval(sprintf("%saxis.tickfont.color", axName)), ...
            "family", eval(sprintf("%saxis.tickfont.family", axName)) ...
        ), ...
        "xanchor", "left" ...
    );

    switch axName
        case "x"
            ann.yanchor = "bottom";
            ann.x = xaxis.domain(2);
            ann.y = yaxis.domain(1);

        case "y"
            ann.yanchor = "bottom";
            ann.x = xaxis.domain(1);
            ann.y = yaxis.domain(2);
    end
end
