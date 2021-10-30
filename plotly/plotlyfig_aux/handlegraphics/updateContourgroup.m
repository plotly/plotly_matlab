function obj = updateContourgroup(obj,plotIndex)

    %-------------------------------------------------------------------------%

    %-INITIALIZATIONS-%

    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    axisData = get(obj.State.Plot(plotIndex).AssociatedAxis);
    plotData = get(obj.State.Plot(plotIndex).Handle);
    [xSource, ySource] = findSourceAxis(obj,axIndex);

    %-get trace data-%
    xData = plotData.XData; if ~isvector(xData), xData = xData(1,:); end
    yData = plotData.YData; if ~isvector(yData), yData = yData(:,1); end
    zData = plotData.ZData;

    contourStart = plotData.TextList(1);
    contourEnd = plotData.TextList(end);
    contourSize = mean(diff(plotData.TextList));

    if length(plotData.TextList) == 1
        contourStart = plotData.TextList(1) - 1e-3;
        contourEnd = plotData.TextList(end) + 1e-3;
        contourSize = 2e-3;
    end

    %-------------------------------------------------------------------------%

    %-set trace-%
    obj.data{plotIndex}.type = 'contour';
    obj.data{plotIndex}.xaxis = sprintf('x%s', xSource);
    obj.data{plotIndex}.yaxis = sprintf('y%s', xSource);
    obj.data{plotIndex}.name = plotData.DisplayName;
    obj.data{plotIndex}.visible = strcmp(plotData.Visible,'on');
    obj.data{plotIndex}.xtype = 'array';
    obj.data{plotIndex}.ytype = 'array';

    %-------------------------------------------------------------------------%

    %-set trace data-%
    obj.data{plotIndex}.x = xData;
    obj.data{plotIndex}.y = yData;
    obj.data{plotIndex}.z = zData;

    %-set contour levels-%
    obj.data{plotIndex}.autocontour = false;
    obj.data{plotIndex}.contours.start = contourStart;
    obj.data{plotIndex}.contours.end = contourEnd;
    obj.data{plotIndex}.contours.size = contourSize;

    %-------------------------------------------------------------------------%

    %-set trace coloring-%
    obj.data{plotIndex}.zauto = false;
    obj.data{plotIndex}.zmin = axisData.CLim(1);
    obj.data{plotIndex}.zmax = axisData.CLim(2);
    obj.data{plotIndex}.showscale = false;
    obj.data{plotIndex}.reversescale = false;
    obj.data{plotIndex}.colorscale = getColorScale(plotData, axisData);

    if strcmp(plotData.Fill, 'off')
        obj.data{plotIndex}.contours.coloring = 'lines';
    else
        obj.data{plotIndex}.contours.coloring = 'fill';
    end

    %-set contour line-%
    if ~strcmp(plotData.LineStyle, 'none')
        obj.data{plotIndex}.contours.showlines = true;
        obj.data{plotIndex}.line = getContourLine(plotData);
    else
        obj.data{plotIndex}.contours.showlines = false;
    end

    %-set contour label-%
    if strcmpi(plotData.ShowText, 'on')
        obj.data{plotIndex}.contours.showlabels = true;
        obj.data{plotIndex}.contours.labelfont = getLabelFont(axisData);
    end

    %-set trace legend-%
    obj.data{plotIndex}.showlegend = getShowLegend(plotData);

    %-------------------------------------------------------------------------%
end

function contourLine = getContourLine(plotData)

    %-initializations-%
    lineStyle = plotData.LineStyle;
    lineWidth = 1.5*plotData.LineWidth;
    lineColor = plotData.LineColor;

    %-line color-%
    if isnumeric(lineColor)
        lineColor = getStringColor( 255*lineColor );
    else
        lineColor = 'rgba(0,0,0,0)';
    end

    %-line dash-%
    switch lineStyle
        case '-'
            lineStyle = 'solid';
        case '--'
            lineStyle = 'dash';
        case ':'
            lineStyle = 'dot';
        case '-.'
            lineStyle = 'dashdot';
    end

    %-return-%
    contourLine.width = lineWidth;
    contourLine.dash = lineStyle;
    contourLine.color = lineColor;
    contourLine.smoothing = 0;
end

function colorScale = getColorScale(plotData, axisData)

    %-initializations-%
    cMap = axisData.Colormap;
    nColors = size(cMap, 1);
    isBackground = any(plotData.ZData(:) < plotData.TextList(1));
    nContours = length(plotData.TextList);
    cScaleInd = linspace(0,1, nContours); 
    if nContours==1, cScaleInd = 0.5; end
    cMapInd = floor( (nColors-1)*cScaleInd ) + 1;

    %-colorscale-%
    if strcmp(plotData.Fill, 'on')
        if isBackground
            colorScale{1} = {0, getStringColor( 255*ones(1,3) )};
            cScaleInd = linspace(1/nContours, 1, nContours);
        end

        for n = 1:nContours
            m = n; if isBackground, m = n+1; end
            stringColor = getStringColor( 255*cMap(cMapInd(n), :) );
            colorScale{m} = {cScaleInd(n), stringColor};
        end
    else
        cScaleInd = rescale(1:nColors, 0, 1);

        for n = 1:nColors
            stringColor = getStringColor( 255*cMap(n,:) );
            colorScale{n} = {cScaleInd(n), stringColor};
        end
    end
end

function labelFont = getLabelFont(axisData)
    labelColor = getStringColor(255*axisData.XAxis.Color);
    labelSize = axisData.XAxis.FontSize;
    labelFamily = matlab2plotlyfont(axisData.XAxis.FontName);

    labelFont.color = labelColor;
    labelFont.size = labelSize;
    labelFont.family = labelFamily;
end