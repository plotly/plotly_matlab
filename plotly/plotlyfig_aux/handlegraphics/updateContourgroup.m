function data = updateContourgroup(obj,plotIndex)
    %-INITIALIZATIONS-%

    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    axisData = obj.State.Plot(plotIndex).AssociatedAxis;
    plotData = obj.State.Plot(plotIndex).Handle;
    [xSource, ySource] = findSourceAxis(obj,axIndex);

    %-Octave contour hggroups expose different properties than
    %-MATLAB's contourgroup objects (contourmatrix, levellist and
    %-zlevelmode instead of TextList/LevelList); route them here
    if is_octave()
        data = updateOctaveContour(obj, plotIndex);
        return
    end

    %-get trace data-%
    xData = get(plotData, 'XData');
    if ~isvector(xData)
        xData = xData(1,:);
    end
    yData = get(plotData, 'YData');
    if ~isvector(yData)
        yData = yData(:,1);
    end
    zData = get(plotData, 'ZData');

    tmpTextList = get(plotData, 'TextList');
    contourStart = tmpTextList(1);
    contourEnd = tmpTextList(end);
    contourSize = mean(diff(get(plotData, 'TextList')));

    if isscalar(get(plotData, 'TextList'))
        contourStart = tmpTextList(1) - 1e-3;
        contourEnd = tmpTextList(end) + 1e-3;
        contourSize = 2e-3;
    end

    data.type = "contour";
    data.xaxis = sprintf("x%d", xSource);
    data.yaxis = sprintf("y%d", ySource);
    data.name = get(plotData, 'DisplayName');
    data.visible = strcmp(get(plotData, 'Visible'), "on");
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
    tmpCLim = get(axisData, 'CLim');
    data.zmin = tmpCLim(1);
    data.zmax = tmpCLim(2);
    data.showscale = false;
    data.reversescale = false;
    data.colorscale = getContourColorScale(plotData, axisData, tmpTextList);

    if strcmp(get(plotData, 'Fill'), "off")
        data.contours.coloring = "lines";
    else
        data.contours.coloring = "fill";
    end

    %-set contour line-%
    if ~strcmp(get(plotData, 'LineStyle'), "none")
        data.contours.showlines = true;
        data.line = getContourLine(plotData);
    else
        data.contours.showlines = false;
    end

    %-set contour label-%
    if strcmpi(get(plotData, 'ShowText'), "on")
        data.contours.showlabels = true;
        data.contours.labelfont = getLabelFont(axisData);
    end

    %-set trace legend-%
    data.showlegend = getShowLegend(plotData) & ~isempty(get(plotData, 'DisplayName'));
end

function contourLine = getContourLine(plotData)
    if isnumeric(get(plotData, 'LineColor'))
        lineColor = getStringColor(round(255*get(plotData, 'LineColor')));
    else
        lineColor = "rgba(0,0,0,0)";
    end

    contourLine = struct( ...
        "width", 1.5*get(plotData, 'LineWidth'), ...
        "dash", getLineDash(get(plotData, 'LineStyle')), ...
        "color", lineColor, ...
        "smoothing", 0 ...
    );
end

function colorScale = getContourColorScale(plotData, axisData, tmpTextList)
    cMap = get(axisData, 'Colormap');
    nColors = size(cMap, 1);
    tmpZData = get(plotData, 'ZData');
    isBackground = any(tmpZData(:) < tmpTextList(1));
    nContours = length(get(plotData, 'TextList'));
    cScaleInd = linspace(0,1, nContours);
    if nContours == 1
        cScaleInd = 0.5;
    end
    cMapInd = floor((nColors-1)*cScaleInd) + 1;

    if strcmp(get(plotData, 'Fill'), "on")
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
        "color", getStringColor(round(255*get(get(axisData, 'XAxis'), 'Color'))), ...
        "size", get(get(axisData, 'XAxis'), 'FontSize'), ...
        "family", matlab2plotlyfont(get(get(axisData, 'XAxis'), 'FontName')) ...
    );
end

function data = updateOctaveContour(obj, plotIndex)
    %-convert an Octave contour hggroup (created by contour, contourf,
    %-contour3, meshc or surfc) to a plotly trace-%
    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    axisData = obj.State.Plot(plotIndex).AssociatedAxis;
    plotData = obj.State.Plot(plotIndex).Handle;
    [xSource, ySource] = findSourceAxis(obj, axIndex);

    xData = get(plotData, 'XData');
    yData = get(plotData, 'YData');
    zData = get(plotData, 'ZData');
    levelList = get(plotData, 'Levellist');
    zLevelMode = get(plotData, 'Zlevelmode');

    if ~strcmp(zLevelMode, 'none')
        %-3D contour (contour3, or the contour lines under meshc/surfc):
        %-draw each contour line as 3D line segments at its z level-%
        if strcmp(zLevelMode, 'manual')
            zLevels = get(plotData, 'Zlevel') * ones(size(levelList));
        else
            zLevels = levelList;
        end

        if isvector(xData)
            [xGrid, yGrid] = meshgrid(xData, yData);
        else
            xGrid = xData;
            yGrid = yData;
        end

        c = get(plotData, 'Contourmatrix');
        cIdx = 1;
        data = struct();
        data.x = [];
        data.y = [];
        data.z = [];
        colorZ = [];
        while cIdx <= size(c, 2)
            level = c(1, cIdx);
            nPts = c(2, cIdx);
            if nPts > 0
                xPts = c(1, cIdx + 1:cIdx + nPts);
                yPts = c(2, cIdx + 1:cIdx + nPts);
                lvlIdx = find(levelList == level, 1);
                zLvl = zLevels(max(lvlIdx, 1));
                data.x = [data.x xPts NaN];
                data.y = [data.y yPts NaN];
                data.z = [data.z zLvl*ones(size(xPts)) NaN];
                colorZ = [colorZ level*ones(size(xPts)) NaN];
            end
            cIdx = cIdx + 1 + max(nPts, 0);
        end

        tmpCLim = get(axisData, 'CLim');
        data.type = 'scatter3d';
        data.scene = sprintf('scene%d', xSource);
        data.mode = 'lines';
        data.visible = strcmp(get(plotData, 'Visible'), 'on');
        data.name = get(plotData, 'DisplayName');
        data.showlegend = false;
        data.line.width = 2*get(plotData, 'LineWidth');
        data.line.color = colorZ;
        data.line.colorscale = getColorScale(get(axisData, 'Colormap'));
        data.line.cmin = tmpCLim(1);
        data.line.cmax = tmpCLim(2);
        updateScene(obj, plotIndex, 'setTitleFont', false);
        return
    end

    %-2D contour / contourf-%
    data = struct();
    data.type = 'contour';
    data.xaxis = sprintf('x%d', xSource);
    data.yaxis = sprintf('y%d', ySource);
    data.name = get(plotData, 'DisplayName');
    data.visible = strcmp(get(plotData, 'Visible'), 'on');
    data.xtype = 'array';
    data.ytype = 'array';
    if isvector(xData)
        data.x = xData;
        data.y = yData;
    else
        data.x = xData(1, :);
        data.y = yData(:, 1);
    end
    data.z = zData;
    data.autocontour = false;
    if numel(levelList) > 1
        data.contours.start = levelList(1);
        data.contours.end = levelList(end);
        data.contours.size = mean(diff(levelList));
    else
        data.contours.start = levelList(1) - 1e-3;
        data.contours.end = levelList(1) + 1e-3;
        data.contours.size = 2e-3;
    end
    data.zauto = false;
    tmpCLim = get(axisData, 'CLim');
    data.zmin = tmpCLim(1);
    data.zmax = tmpCLim(2);
    data.showscale = false;
    data.colorscale = octaveContourColorScale(axisData, levelList, ...
        strcmp(get(plotData, 'Fill'), 'on'));

    if strcmp(get(plotData, 'Fill'), 'on')
        data.contours.coloring = 'fill';
        % the native contourf draws the band boundaries with the
        % contour line color (black)
        data.contours.showlines = true;
        if isnumeric(get(plotData, 'LineColor'))
            data.line.width = 1.5*get(plotData, 'LineWidth');
            data.line.color = getStringColor(round(255*get(plotData, 'LineColor')));
        end
    else
        data.contours.coloring = 'lines';
        data.contours.showlines = true;
        data.line.width = 1.5*get(plotData, 'LineWidth');
        data.line.color = 'rgba(0,0,0,0)';
    end
    data.showlegend = getShowLegend(plotData) ...
        & ~isempty(get(plotData, 'DisplayName'));
end

function colorScale = octaveContourColorScale(axisData, levelList, filled)
    cMap = get(axisData, 'Colormap');
    nColors = size(cMap, 1);
    if filled
        nContours = numel(levelList);
        cScaleInd = linspace(0, 1, nContours);
        cMapInd = floor((nColors - 1)*cScaleInd) + 1;
        colorScale = cell(1, nContours);
        colors = cMap(cMapInd, :);
    else
        colorScale = cell(1, nColors);
        colors = cMap;
        cScaleInd = linspace(0, 1, nColors);
    end
    for n = 1:numel(colorScale)
        stringColor = getStringColor(round(255*colors(n, :)));
        colorScale{n} = {cScaleInd(n), stringColor};
    end
end
