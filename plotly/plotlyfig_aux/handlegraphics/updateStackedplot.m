function updateStackedplot(obj, plotIndex)

    %-------------------------------------------------------------------------%

    %-INITIALIZATIONS-%

    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    plotData = get(obj.State.Plot(plotIndex).Handle);
    lineData = plotData.LineProperties(end:-1:1);
    
    %-get trace data-%

    sourceTable = plotData.SourceTable;
    displayVariables = plotData.DisplayVariables;
    nTraces = length(plotData.AxesProperties);
    
    if isempty(sourceTable)
        xData = plotData.XData;
        for t = 1:nTraces
            n = nTraces - t + 1;
            yData{t} = plotData.YData(:, n);
        end

    else
        if istimetable(sourceTable)
            xData = date2NumData(sourceTable.Properties.RowTimes);
        else
            xData = 1:size(sourceTable, 1);
        end

        for t = 1:nTraces
            n = nTraces - t + 1;
            yData{t} = date2NumData(sourceTable.(displayVariables{n}));
        end
    end

    %-------------------------------------------------------------------------%

    %-UPDATE STACKEDPLOT AXIS-%
    updateStackedplotAxis(obj, plotIndex)

    %-------------------------------------------------------------------------%

    %-SET TRACES-%
    traceIndex = plotIndex;

    for t = 1:nTraces

        %-update current trace Index-%
        if t ~= 1
            obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
            traceIndex = obj.PlotOptions.nPlots;
        end

        %-set current trace-%
        obj.data{traceIndex}.type = 'scatter';
        obj.data{traceIndex}.visible = strcmp(plotData.Visible,'on');
        obj.data{traceIndex}.name = plotData.DisplayLabels{t};
        obj.data{traceIndex}.xaxis = sprintf('x%d', 1);
        obj.data{traceIndex}.yaxis = sprintf('y%d', t);

        %-set current trace data-%
        obj.data{traceIndex}.x = xData;
        obj.data{traceIndex}.y = yData{t};

        %-set current trace marker-%
        switch lineData(t).PlotType
            case 'scatter'
                markerSize = ones(size(xData)) * lineData(t).MarkerSize;
                obj.data{traceIndex}.mode = 'markers';
                obj.data{traceIndex}.marker = extractLineMarker(lineData(t));
                obj.data{traceIndex}.marker.size = markerSize;
                obj.data{traceIndex}.marker.line.width = 1;
            otherwise
                obj.data{traceIndex}.mode = 'lines';
                obj.data{traceIndex}.line = extractLineLine(lineData(t));
        end

    end

    %-------------------------------------------------------------------------%
end

function updateStackedplotAxis(obj, plotIndex)

    %-------------------------------------------------------------------------%

    %-INITIALIZATIONS-%

    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    plotData = get(obj.State.Plot(plotIndex).Handle);

    %-------------------------------------------------------------------------%

    %-SET X-AXIS-%

    [xaxis, xExpoFormat] = getAxis(obj, plotIndex, 'X');
    obj.layout = setfield(obj.layout, 'xaxis1', xaxis{1});

    %-------------------------------------------------------------------------%

    %-SET Y-AXIS-%

    [yaxis, yExpoFormat] = getAxis(obj, plotIndex, 'Y');

    for a = 1:length(yaxis)
        obj.layout = setfield(obj.layout, sprintf('yaxis%d', a), yaxis{a});
    end

    %-------------------------------------------------------------------------%

    %-SET AXES ANOTATIONS-%

    %-trace title-%
    updateTitle(obj, plotData.Title, [1, 3]);

    %-exponent for x-axis-%
    updateExponentFormat(obj, xExpoFormat(1), [1,1], 'X');

    %-exponent for y-axis-%
    for a = 1:length(yExpoFormat)
        updateExponentFormat(obj, yExpoFormat(a), [1, a], 'Y');
    end
end

function [ax, expoFormat] = getAxis(obj, plotIndex, axName)

    %-------------------------------------------------------------------------%

    %-INITIALIZATIONS-%

    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    plotData = get(obj.State.Plot(plotIndex).Handle);

    lineFactor = obj.PlotlyDefaults.AxisLineIncreaseFactor;
    axisPos = plotData.Position;
    axisColor = getStringColor(zeros(1,3));
    lineWidth = 1;
    fontSize = plotData.FontSize;
    fontFamily = matlab2plotlyfont(plotData.FontName);;
    tickLen = 5;

    %-------------------------------------------------------------------------%

    %-Parse parameters accorging to axisName (X or Y)

    switch axName
        case {'x', 'X'}
            nAxis = 1;
            nTicks = [5, 12];
            axisLim{nAxis} = plotData.XLimits;
            axisLabel{nAxis} = plotData.XLabel;
            axisDomain{nAxis} = min([axisPos(1) sum(axisPos([1,3]))], 1);
            axisAnchor{nAxis} = 'y1';
            
        case {'x', 'Y'}
            nAxis = length(plotData.AxesProperties);
            yPos = linspace(axisPos(2), sum(axisPos([2,4])), nAxis+1);
            yOffset = diff(yPos)*0.1; yOffset(1) = 0;

            for a = 1:nAxis
                b = nAxis-a+1;
                axisLim{a} = plotData.AxesProperties(b).YLimits;
                axisLabel{a} = plotData.DisplayLabels{b};
                axisDomain{a} = min([yPos(a)+yOffset(a) yPos(a+1)], 1);
                axisAnchor{a} = 'x1';
            end

            if nAxis < 4
                nTicks = [5, 8];
            else
                nTicks = [3, 5];
            end
    end

    %-------------------------------------------------------------------------%

    %-GET EACH AXIS-%

    for a = 1:nAxis

        %-general-%
        ax{a}.domain = axisDomain{a};
        ax{a}.anchor = axisAnchor{a};
        ax{a}.range = date2NumData(axisLim{a});

        ax{a}.side = 'left';
        ax{a}.mirror = false;
        ax{a}.zeroline = false;
    
        ax{a}.linecolor = axisColor;
        ax{a}.linewidth = lineWidth;
        ax{a}.exponentformat = obj.PlotlyDefaults.ExponentFormat;

        %-grid-%
        if strcmp(plotData.GridVisible, 'on')
            ax{a}.showgrid = true;
            ax{a}.gridwidth = lineWidth;
            ax{a}.gridcolor = getStringColor(0.15*ones(1,3), 0.15);
        else
            ax{a}.showgrid = false;
        end

        %-ticks-%
        if isnumeric(axisLim{a})
            [tickVals, tickText, expoFormat(a)] = getNumTicks(axisLim{a}, nTicks);

            [tickVals, tickText] = rmTicks(ax{a}.range, tickVals, tickText, 's');
            [tickVals, tickText] = rmTicks(ax{a}.range, tickVals, tickText, 'e');

        elseif isduration(axisLim{a}) || isdatetime(axisLim{a})
            [tickVals, tickText] = getDateTicks(axisLim{a}, nTicks);
            expoFormat(a) = 0;

            [tickVals, tickText] = rmTicks(ax{a}.range, tickVals, tickText, 's');
        end

        ax{a}.showticklabels = true;
        ax{a}.ticks = 'inside';
        ax{a}.ticklen = tickLen;
        ax{a}.tickwidth = lineWidth;

        ax{a}.tickfont.size = fontSize;
        ax{a}.tickfont.family = fontFamily;
        ax{a}.tickfont.color = axisColor;

        ax{a}.tickvals = tickVals;
        ax{a}.ticktext = tickText;

        %-label-%
        if ~isempty(axisLabel{a})
            ax{a}.title = parseString(axisLabel{a});
            ax{a}.titlefont.color = axisColor;
            ax{a}.titlefont.size = fontSize;
            ax{a}.titlefont.family = fontFamily;
        end
    end

    %-------------------------------------------------------------------------%
end

function [tickVals, tickText] = getDateTicks(axisLim, nTicks)

    %-by year-%
    yearLim = year(date2NumData(axisLim));
    isYear = length(unique(yearLim)) > 1;
    refYear = [1, 2, 5];

    if isYear
        yearTick = getTickVals(yearLim, refYear, 1, nTicks);

        for n = 1:length(yearTick)
            tickVals(n) = datenum(datetime(yearTick(n),1,1,'Format','yy'));
            tickText{n} = num2str(yearTick(n));
        end

        return;
    end

    %-by month-%
    monthLim = month(date2NumData(axisLim));
    isMonth = length(unique(monthLim)) > 1;

    if isMonth
        % TODO
        return
    end

    %-by day-%
    dayLim = day(date2NumData(axisLim));
    isDay = length(unique(dayLim)) > 1;
    refDay = [0.5, 1];

    if isDay
        dayTick = getTickVals(dayLim, refDay, 1, nTicks);
        hourTick = 24 * ( dayTick - fix(dayTick) );
        dayTick = fix(dayTick);

        for n = 1:length(dayTick)
            matDate = [yearLim(1),monthLim(1),dayTick(n),hourTick(n),0,0];
            tickVals(n) = datetime(matDate,'Format', 'MMM dd, HH:mm');
            tickText{n} = datestr(tickVals(n), 'mmm dd, HH:MM');
        end

        tickVals = datenum(tickVals);
        return;
    end
end

function [tickVals, tickText, expoFormat] = getNumTicks(axisLim, nTicks)
    refVals = [1, 2, 5];
    refPot = floor(log10(range(axisLim)));
    nonStop = true;

    fixAxisLim = fix(axisLim);

    if ~all(fixAxisLim == 0)
        expoFormat = floor(log10(max(1, range(fixAxisLim))));
    else
        expoFormat = refPot;
    end

    if abs(expoFormat) < 3 expoFormat = 0; end

    tickVals = getTickVals(axisLim, refVals, refPot, nTicks);

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
            if startTick < axisLim, startTick = startTick + vp; end
            endTick = axisLim(2) - mod(axisLim(2), vp);
            nPoints = floor(range([startTick, endTick])/vp) + 1;

            tickVals = startTick:vp:endTick;
            lenTicks = length(tickVals);

            if lenTicks >= nTicks(1) && lenTicks <= nTicks(2)
                done = true;
                break;
            end
        end

        if done, break; end
    end
end

function updateTitle(obj, titleText, xySource)
    xaxis = eval(sprintf('obj.layout.xaxis%d', xySource(1)));
    yaxis = eval(sprintf('obj.layout.yaxis%d', xySource(2)));
    anIndex = 1;
    if ~isempty(titleText), titleText = parseString(titleText); end

    ann.showarrow = false;
    ann.text = sprintf('<b>%s</b>', titleText);
    ann.xref = 'paper';
    ann.yref = 'paper';
    ann.x = mean(xaxis.domain);
    ann.y = yaxis.domain(2);
    ann.xanchor = 'middle';
    ann.yanchor = 'bottom';
    ann.font.size = 1.5*xaxis.tickfont.size;
    ann.font.color = xaxis.tickfont.color;
    ann.font.family = xaxis.tickfont.family;

    obj.layout.annotations{anIndex} = ann;
end

function updateExponentFormat(obj, expoFormat, xySource, axName)

    axName = lower(axName);
    xaxis = eval(sprintf('obj.layout.xaxis%d', xySource(1)));
    yaxis = eval(sprintf('obj.layout.yaxis%d', xySource(2)));
    anIndex = obj.PlotlyDefaults.anIndex + 1;

    if expoFormat ~= 0
        exponentText = sprintf('\\times10^%d', expoFormat);
        exponentText = parseString(exponentText, 'tex');
        % exponentText = ['<p>' exponentText '</p>'];

        ann.showarrow = false;
        ann.text = exponentText;
        ann.xref = 'paper';
        ann.yref = 'paper';
        ann.font.size = eval(sprintf('%saxis.tickfont.size', axName));
        ann.font.color = eval(sprintf('%saxis.tickfont.color', axName));
        ann.font.family = eval(sprintf('%saxis.tickfont.family', axName));
        ann.xanchor = 'left';

        switch axName
            case 'x'
                ann.yanchor = 'bottom';
                ann.x = xaxis.domain(2);
                ann.y = yaxis.domain(1);
                
            case 'y'
                ann.yanchor = 'bottom';
                ann.x = xaxis.domain(1);
                ann.y = yaxis.domain(2);
        end

        obj.layout.annotations{anIndex} = ann;
        obj.PlotlyDefaults.anIndex = anIndex;
    end
end

function [tickVals, tickText] = rmTicks(axisLim, tickVals, tickText, rmCase)
    rangeLim = range(axisLim);

    switch rmCase
        case 's'
            if abs(axisLim(1)-tickVals(1)) < rangeLim * 0.01
                tickVals = tickVals(2:end);
                tickText = tickText(2:end);
            end
            
        case 'e'
            if abs(axisLim(end)-tickVals(end)) < rangeLim * 0.01
                tickVals = tickVals(1:end-1);
                tickText = tickText(1:end-1);
            end

    end
end

