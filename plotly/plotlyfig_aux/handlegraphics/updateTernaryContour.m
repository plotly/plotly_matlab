function obj = updateTernaryContour(obj, ternaryIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(ternaryIndex).AssociatedAxis);

    %-GET DATA STRUCTURES-%
    ternaryData = obj.State.Plot(ternaryIndex).Handle;
    axisData = obj.State.Plot(ternaryIndex).AssociatedAxis;
    figureData = obj.State.Figure.Handle;

    %-CHECK FOR MULTIPLE AXES-%
    xsource = findSourceAxis(obj, axIndex);

    %=====================================================================%
    %
    %-UPDATE CONTOURS FILL-%
    %
    %=====================================================================%

    if strcmpi(ternaryData.Fill, 'on')
        fillContours(obj, ternaryIndex)
    end

    %=====================================================================%
    %
    %-UPDATE CONTOUR LINES-%
    %
    %=====================================================================%

    %-parse plot data-%
    contourMatrix = ternaryData.ContourMatrix;

    len = size(contourMatrix, 2);
    n = 1; c = 1;

    while (n < len)
        %-get plot data-%
        m = contourMatrix(2, n);
        zLevel = contourMatrix(1, n);

        xData{c} = contourMatrix(1, n+1:n+m);
        yData{c} = contourMatrix(2, n+1:n+m);

        %-get edge color-%
        if isnumeric(ternaryData.LineColor)
            lineColor{c} = getStringColor(round(255*ternaryData.LineColor));
        elseif strcmpi(ternaryData.LineColor, "flat")
            cMap = figureData.Colormap;
            cMin = axisData.CLim(1);
            cMax = axisData.CLim(2);
            nColors = size(cMap,1);

            cData = max(min(zLevel, cMax), cMin);
            cData = (cData - cMin)/(cMax - cMin);
            cData = 1 + floor( cData*(nColors-1) );

            lineColor{c} = getStringColor(round(255*cMap(cData,:)));
        elseif strcmpi(ternaryData.LineColor, "none")
            lineColor{c} = "rgba(0,0,0,0)";
        end

        n = n + m + 1;
        c = c + 1;
    end

    %-set contour lines-%
    for c = 1:length(xData)
        %-get trace index-%
        traceIndex = ternaryIndex;

        if c > 1 || strcmpi(ternaryData.Fill, 'on')
            obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
            traceIndex = obj.PlotOptions.nPlots;
        end

        %-set trace-%
        obj.data{traceIndex}.type = 'scatterternary';
        obj.data{traceIndex}.mode = 'lines';
        obj.data{traceIndex}.subplot = sprintf('ternary%d', xsource+1);

        %-convert from cartesian coordinates to trenary points-%
        aData = yData{c}/sin(deg2rad(60));
        bData = 1 - xData{c} - yData{c}*cot(deg2rad(60));

        %-set plot data-%
        obj.data{traceIndex}.a = aData;
        obj.data{traceIndex}.b = bData;

        %-line settings-%
        obj.data{traceIndex}.line.width = 1.0*ternaryData.LineWidth;
        obj.data{traceIndex}.line.color = lineColor{c};
        obj.data{traceIndex}.line.dash = getLineDash(ternaryData.LineStyle);

        %-some trace settings-%
        obj.data{traceIndex}.name = ternaryData.DisplayName;
        obj.data{traceIndex}.showscale = false;
        obj.data{traceIndex}.visible = strcmp(ternaryData.Visible,'on');


        obj.data{traceIndex}.showlegend = false;
    end

    %=====================================================================%
    %
    %-UPDATE TERNARY AXES-%
    %
    %=====================================================================%

    ternaryAxes(obj, ternaryIndex)
end


function fillContours(obj, ternaryIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(ternaryIndex).AssociatedAxis);

    %-GET DATA STRUCTURES-%
    ternaryData = obj.State.Plot(ternaryIndex).Handle;
    axisData = obj.State.Plot(ternaryIndex).AssociatedAxis;
    figureData = obj.State.Figure.Handle;

    %-CHECK FOR MULTIPLE AXES-%
    xsource = findSourceAxis(obj, axIndex);

    %-get zLevels-%
    contourMatrix = ternaryData.ContourMatrix;
    len = size(contourMatrix, 2);
    n = 1; c = 1;

    while (n < len)
        m = contourMatrix(2, n);
        zLevel(c) = contourMatrix(1, n);

        n = n + m + 1;
        c = c + 1;
    end

    zLevel = sort(zLevel);

    %-get close contours-%
    resizeScale = 1000/mean(size(ternaryData.XData));
    xDataResize = imresize(ternaryData.XData, resizeScale, 'triangle');
    yDataResize = imresize(ternaryData.YData, resizeScale, 'triangle');
    zDataResize = imresize(ternaryData.ZData, resizeScale, 'triangle');

    cMap = figureData.Colormap;
    cLim = axisData.CLim;
    c = 1;

    for l = 1:length(zLevel)-1
        B = getBoundaries(zDataResize, zLevel(l), zLevel(l+1));
        for k = 1:length(B)
            outStruct = getContourData(B{k}, zLevel(l), ...
                xDataResize, yDataResize, zDataResize, cLim, cMap);
            xData{c} = outStruct.xData;
            yData{c} = outStruct.yData;
            contourArea(c) = outStruct.contourArea;
            lineColor{c} = outStruct.lineColor;

            c = c + 1;
        end
    end

    BW = zDataResize >= zLevel(end);
    [B, ~] = bwboundaries(BW, 8, 'noholes');

    for k = 1:length(B)
        outStruct = getContourData(B{k}, zLevel(end), ...
            xDataResize, yDataResize, zDataResize, cLim, cMap);
        xData{c} = outStruct.xData;
        yData{c} = outStruct.yData;
        contourArea(c) = outStruct.contourArea;
        lineColor{c} = outStruct.lineColor;

        c = c + 1;
    end

    idxx = zDataResize < zLevel(1);
    [B, ~] = bwboundaries(idxx, 8, 'noholes');

    for k = 1:length(B)
        outStruct = getContourData(B{k}, zLevel(1), ...
            xDataResize, yDataResize, zDataResize, cLim, cMap);
        xData{c} = outStruct.xData;
        yData{c} = outStruct.yData;
        contourArea(c) = outStruct.contourArea;
        lineColor{c} = 'rgb(255,255,255)';

        c = c + 1;
    end

    %-sort contours by area size-%
    [~, idx] = sort(contourArea, 'descend');

    for c = 1:length(idx)
        xDataSorted{c} = xData{idx(c)};
        yDataSorted{c} = yData{idx(c)};
        lineColorSorted{c} = lineColor{idx(c)};
    end

    xData = xDataSorted;
    yData = yDataSorted;
    lineColor = lineColorSorted;

    %-set contour fill-%
    for c = 1:length(xData)
        %-get trace index-%
        traceIndex = ternaryIndex;

        if c > 1
            obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
            traceIndex = obj.PlotOptions.nPlots;
        end

        %-set trace-%
        obj.data{traceIndex}.type = 'scatterternary';
        obj.data{traceIndex}.mode = 'lines';
        obj.data{traceIndex}.subplot = sprintf('ternary%d', xsource+1);

        %-convert from cartesian coordinates to trenary points-%
        aData = yData{c}/sin(deg2rad(60));
        bData = 1 - xData{c} - yData{c}*cot(deg2rad(60));

        %-set plot data-%
        obj.data{traceIndex}.a = aData;
        obj.data{traceIndex}.b = bData;

        %-line settings-%
        obj.data{traceIndex}.line.color = lineColor{c};
        obj.data{traceIndex}.line.shape = 'spline';
        obj.data{traceIndex}.line.smoothing = 1.3;
        obj.data{traceIndex}.line.width = 1.0*ternaryData.LineWidth;
        obj.data{traceIndex}.line.dash = getLineDash(ternaryData.LineStyle);

        %-fill settings-%
        obj.data{traceIndex}.fill = 'toself';
        obj.data{traceIndex}.fillcolor = lineColor{c};

        %-some trace settings-%
        obj.data{traceIndex}.name = ternaryData.DisplayName;
        obj.data{traceIndex}.showscale = false;
        obj.data{traceIndex}.visible = strcmp(ternaryData.Visible,'on');

        %-trace legend-%
        obj.data{traceIndex}.showlegend = false;
    end
end

function ternaryAxes(obj, ternaryIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(ternaryIndex).AssociatedAxis);

    %-GET DATA STRUCTURES-%
    axisData = obj.State.Plot(ternaryIndex).AssociatedAxis;

    %-CHECK FOR MULTIPLE AXES-%
    xsource = findSourceAxis(obj, axIndex);

    %-set domain plot-%
    xo = axisData.Position(1);
    yo = axisData.Position(2);
    w = axisData.Position(3);
    h = axisData.Position(4);

    ternary.domain.x = min([xo xo + w],1);
    ternary.domain.y = min([yo yo + h],1);

    %-label settings-%
    l = 1; t = 1;
    labelLetter = {'b', 'a', 'c'};

    for n = 1:length(axisData.Children)
        if strcmpi(axisData.Children(n).Type, 'text')
            stringText = axisData.Children(n).String;
            if any(isletter(stringText))
                labelIndex(l) = n;
                l = l + 1;
            else
                tickIndex(t) = n;
                t = t + 1;
            end
        end
    end

    for l = 1:length(labelIndex)
        n = labelIndex(l);

        labelText = axisData.Children(n).String;
        labelFontColor = getStringColor(round(255*axisData.Children(n).Color));
        labelFontSize = 1.5 * axisData.Children(n).FontSize;
        labelFontFamily = matlab2plotlyfont(axisData.Children(n).FontName);

        ternary.(labelLetter(l) + "axis").title.text = labelText;
        ternary.(labelLetter(l) + "axis").title.font.color = labelFontColor;
        ternary.(labelLetter(l) + "axis").title.font.size = labelFontSize;
        ternary.(labelLetter(l) + "axis").title.font.family = labelFontFamily;
    end

    %-tick settings-%
    t0 = tickIndex(1); t1 = tickIndex(2);
    tick0 = str2num(axisData.Children(t0).String);
    tick1 = str2num(axisData.Children(t1).String);
    dtick = tick1 - tick0;

    tickFontColor = getStringColor(round(255*axisData.Children(t0).Color));
    tickFontSize = 1.0 * axisData.Children(t0).FontSize;
    tickFontFamily = matlab2plotlyfont(axisData.Children(t0).FontName);

    for l = 1:3
        ternary.(labelLetter{l} + "axis").tick0 = tick0;
        ternary.(labelLetter{l} + "axis").dtick = dtick;
        ternary.(labelLetter{l} + "axis").tickfont.color = tickFontColor;
        ternary.(labelLetter{l} + "axis").tickfont.size = tickFontSize;
        ternary.(labelLetter{l} + "axis").tickfont.family = tickFontFamily;
    end

    %-set ternary axes to layout-%
    obj.layout.(sprintf('ternary%d', xsource+1)) = ternary;

    obj.PlotlyDefaults.isTernary = true;
end

function rad = deg2rad(deg)
    rad = deg / 180 * pi;
end

function B = getBoundaries(zData, lowLevel, upperLevel)
    BW = zData >= lowLevel & zData <= upperLevel;
    [B, ~] = bwboundaries(double(BW), 'noholes');
end

function outStruct = getContourData(B, zLevel, xData, yData, zData, cLim, cMap)
    idx = sub2ind(size(zData), B(:,1), B(:,2));

    outStruct.xData = xData(idx);
    outStruct.yData = yData(idx);
    outStruct.contourArea = polyarea(xData(idx), yData(idx));

    nColors = size(cMap, 1);
    colorIndex = max(min(zLevel, cLim(2)), cLim(1));
    colorIndex = (colorIndex - cLim(1))/(cLim(2) - cLim(1));
    colorIndex = 1 + floor( colorIndex*(nColors-1) );

    outStruct.lineColor = getStringColor(round(255*cMap(colorIndex,:)));
end
