function data = updateContourgroup(obj,plotIndex)
    %-INITIALIZATIONS-%

    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    axisData = obj.State.Plot(plotIndex).AssociatedAxis;
    plotData = obj.State.Plot(plotIndex).Handle;
    [xSource, ySource] = findSourceAxis(obj,axIndex);

    %-get trace data-%
    xData = plotData.XData;
    if ~isvector(xData)
        xData = xData(1,:);
    end
    yData = plotData.YData;
    if ~isvector(yData)
        yData = yData(:,1);
    end
    zData = plotData.ZData;

    contourStart = plotData.TextList(1);
    contourEnd = plotData.TextList(end);
    contourSize = mean(diff(plotData.TextList));

    if isscalar(plotData.TextList)
        contourStart = plotData.TextList(1) - 1e-3;
        contourEnd = plotData.TextList(end) + 1e-3;
        contourSize = 2e-3;
    end

    data.type = "contour";
    data.xaxis = "x" + xSource;
    data.yaxis = "y" + ySource;
    data.name = plotData.DisplayName;
    data.visible = plotData.Visible == "on";
    data.xtype = "array";
    data.ytype = "array";

    data.x = xData;
    data.y = yData;
    data.z = zData;

    data.autocontour = false;
    data.contours.start = contourStart;
    data.contours.end = contourEnd;
    data.contours.size = contourSize;

    data.zauto = false;
    data.zmin = axisData.CLim(1);
    data.zmax = axisData.CLim(2);
    data.showscale = false;
    data.reversescale = false;
    data.colorscale = getColorScale(plotData, axisData);

    if plotData.Fill == "off"
        data.contours.coloring = "lines";
    else
        data.contours.coloring = "fill";
    end

    %-set contour line-%
    if plotData.LineStyle ~= "none"
        data.contours.showlines = true;
        data.line = getContourLine(plotData);
    else
        data.contours.showlines = false;
    end

    %-set contour label-%
    if lower(plotData.ShowText) == "on"
        data.contours.showlabels = true;
        data.contours.labelfont = getLabelFont(axisData);
    end

    %-set trace legend-%
    data.showlegend = getShowLegend(plotData);
end

function contourLine = getContourLine(plotData)
    if isnumeric(plotData.LineColor)
        lineColor = getStringColor(round(255*plotData.LineColor));
    else
        lineColor = "rgba(0,0,0,0)";
    end

    contourLine = struct( ...
        "width", 1.5*plotData.LineWidth, ...
        "dash", getLineDash(plotData.LineStyle), ...
        "color", lineColor, ...
        "smoothing", 0 ...
    );
end

function colorScale = getColorScale(plotData, axisData)
    cMap = axisData.Colormap;
    nColors = size(cMap, 1);
    isBackground = any(plotData.ZData(:) < plotData.TextList(1));
    nContours = length(plotData.TextList);
    cScaleInd = linspace(0,1, nContours);
    if nContours == 1
        cScaleInd = 0.5;
    end
    cMapInd = floor((nColors-1)*cScaleInd) + 1;

    if plotData.Fill == "on"
        colorScale = cell(1, nContours);
        colors = cMap(cMapInd, :);
        if isBackground
            colorScale = cell(1, nContours+1);
            colors = [ones(1,3); colors];
            cScaleInd = linspace(0, 1, nContours+1);
        end
    else
        colors = cMap;
        colorScale = cell(1,nColors);
        cScaleInd = rescale(1:nColors, 0, 1);
    end
    for n = 1:numel(colorScale)
        stringColor = getStringColor(round(255*colors(n,:)));
        colorScale{n} = {cScaleInd(n), stringColor};
    end
end

function labelFont = getLabelFont(axisData)
    labelFont = struct( ...
        "color", getStringColor(round(255*axisData.XAxis.Color)), ...
        "size", axisData.XAxis.FontSize, ...
        "family", matlab2plotlyfont(axisData.XAxis.FontName) ...
    );
end
