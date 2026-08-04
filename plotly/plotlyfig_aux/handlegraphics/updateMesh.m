function obj = updateMesh(obj, surfaceIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(surfaceIndex).AssociatedAxis);

    %-CHECK FOR MULTIPLE AXES-%
    xsource = findSourceAxis(obj,axIndex);

    %-SURFACE DATA STRUCTURE- %
    meshData = obj.State.Plot(surfaceIndex).Handle;

    %-AXIS STRUCTURE-%
    axisData = ancestor(get(meshData, 'Parent'),'axes');

    %-SCENE DATA-%
    scene = obj.layout.(sprintf("scene%d", xsource));

    %-GET CONTOUR INDEX-%
    obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
    contourIndex = obj.PlotOptions.nPlots;
    obj.PlotOptions.contourIndex(surfaceIndex) = contourIndex;

    %-associate scene-%
    obj.data{surfaceIndex}.scene = sprintf('scene%d', xsource);
    obj.data{contourIndex}.scene = sprintf('scene%d', xsource);

    %-surface type for face color-%
    obj.data{surfaceIndex}.type = 'surface';

    %-scatter3d type for contour mesh lines-%
    obj.data{contourIndex}.type = 'scatter3d';
    obj.data{contourIndex}.mode = 'lines';

    %-get plot data-%
    xData = get(meshData, 'XData');
    yData = get(meshData, 'YData');
    zData = get(meshData, 'ZData');

    if isvector(xData)
        [xData, yData] = meshgrid(xData, yData);
    end

    %-reformat data to mesh-%
    xDataSurface = xData;
    yDataSurface = yData;
    zDataSurface = zData;

    xDataContourDir1 = [xDataSurface; NaN(1, size(xDataSurface, 2))];
    yDataContourDir1 = [yDataSurface; NaN(1, size(yDataSurface, 2))];
    zDataContourDir1 = [zDataSurface; NaN(1, size(zDataSurface, 2))];

    xDataContourDir2 = xDataContourDir1(1:end-1,:)';
    yDataContourDir2 = yDataContourDir1(1:end-1,:)';
    zDataContourDir2 = zDataContourDir1(1:end-1,:)';

    xDataContourDir2 = [xDataContourDir2; NaN(1, size(xDataContourDir2, 2))];
    yDataContourDir2 = [yDataContourDir2; NaN(1, size(yDataContourDir2, 2))];
    zDataContourDir2 = [zDataContourDir2; NaN(1, size(zDataContourDir2, 2))];

    xDataContour = [xDataContourDir1(:); xDataContourDir2(:)];
    yDataContour = [yDataContourDir1(:); yDataContourDir2(:)];
    zDataContour = [zDataContourDir1(:); zDataContourDir2(:)];

    %-set data on surface-%
    obj.data{surfaceIndex}.x = xDataSurface;
    obj.data{surfaceIndex}.y = yDataSurface;
    obj.data{surfaceIndex}.z = zDataSurface;

    %- setting grid mesh by default -%
    % x-direction
    xData = xData(1, :);
    obj.data{surfaceIndex}.contours.x.start = xData(1);
    obj.data{surfaceIndex}.contours.x.end = xData(end);
    obj.data{surfaceIndex}.contours.x.size = mean(diff(xData));
    obj.data{surfaceIndex}.contours.x.show = true;

    % y-direction
    yData = yData(:, 1);
    obj.data{surfaceIndex}.contours.y.start = yData(1);
    obj.data{surfaceIndex}.contours.y.end = yData(end);
    obj.data{surfaceIndex}.contours.y.size = mean(diff(yData));
    obj.data{surfaceIndex}.contours.y.show = true;

    %-set data on scatter3d-%
    obj.data{contourIndex}.x = xDataContour(:);
    obj.data{contourIndex}.y = yDataContour(:);
    obj.data{contourIndex}.z = zDataContour(:);

    %-COLORING-%

    %-get colormap-%
    cMap = get(axisData, 'Colormap');
    colorScale = getColorScale(cMap);
    tmpCLim = get(axisData, 'CLim');

    %-get edge color-%
    if isnumeric(get(meshData, 'EdgeColor'))
        cDataContour = getStringColor(round(255*get(meshData, 'EdgeColor')));

    elseif strcmpi(get(meshData, 'EdgeColor'), "interp")
        cDataContour = zDataContour(:);
        obj.data{contourIndex}.line.colorscale = colorScale;

        obj.data{surfaceIndex}.contours.x.show = false;
        obj.data{surfaceIndex}.contours.y.show = false;

    elseif strcmpi(get(meshData, 'EdgeColor'), "flat")
        cData = get(meshData, 'CData');
tmpCLim = get(axisData, 'CLim');

        if size(cData, 3) ~= 1
            cMap = unique( reshape(cData, ...
                [size(cData,1)*size(cData,2), size(cData,3)]), "rows" );
            cData = quantizeColors(cData);

            edgeColorScale = getColorScale(cMap);

            obj.data{surfaceIndex}.line.cmin = 0;
            obj.data{surfaceIndex}.line.cmax = 255;
            obj.data{contourIndex}.line.colorscale = edgeColorScale;
        else
            obj.data{contourIndex}.line.cmin = tmpCLim(1);
            obj.data{contourIndex}.line.cmax = tmpCLim(2);
            obj.data{contourIndex}.line.colorscale = colorScale;
        end

        cDataContourDir1 = [cData; NaN(1, size(cData, 2))];
        cDataContourDir2 = cDataContourDir1(1:end-1,:)';
        cDataContourDir2 = [cDataContourDir2; NaN(1, size(cDataContourDir2, 2))];
        cDataContour = [cDataContourDir1(:); cDataContourDir2(:)];

        obj.data{surfaceIndex}.contours.x.show = false;
        obj.data{surfaceIndex}.contours.y.show = false;

    elseif strcmpi(get(meshData, 'EdgeColor'), 'none')
        cDataContour = 'rgba(0,0,0,0)';
        obj.data{surfaceIndex}.contours.x.show = false;
        obj.data{surfaceIndex}.contours.y.show = false;
    end

    %-set edge color-%
    obj.data{contourIndex}.line.color = cDataContour;
    obj.data{surfaceIndex}.contours.x.color = cDataContour;
    obj.data{surfaceIndex}.contours.y.color = cDataContour;

    % the contour line colors are mapped through the trace's cmin/cmax
    obj.data{surfaceIndex}.cmin = tmpCLim(1);
    obj.data{surfaceIndex}.cmax = tmpCLim(2);

    %-get face color-%
    faceColor = get(meshData, 'FaceColor');

    if isnumeric(faceColor)
        if all(faceColor == [1, 1, 1])
            faceColor = [0.96, 0.96, 0.96];
        end

        for n = 1:size(zDataSurface, 2)
            for m = 1:size(zDataSurface, 1)
                cDataSurface(m, n, :) = faceColor;
            end
        end

        [cDataSurface, cMapSurface] = quantizeColors(cDataSurface);
        cDataSurface = double(cDataSurface) + tmpCLim(1);

        if size(cMapSurface, 1) == 1
            % a single-color colormap must still have two stops for
            % plotly to interpolate over the whole range
            colorScale = {{0, getStringColor(round(255*cMapSurface(1, :)), 1)}, ...
                {1, getStringColor(round(255*cMapSurface(1, :)), 1)}};
        else
            for c = 1: size(cMapSurface, 1)
                colorScale{c} = {(c-1)/(size(cMapSurface, 1)-1), ...
                        getStringColor(round(255*cMapSurface(c, :)), 1)};
            end
        end

        obj.data{surfaceIndex}.cmin = tmpCLim(1);
        obj.data{surfaceIndex}.cmax = tmpCLim(2);

    elseif strcmpi(faceColor, 'interp')
        cDataSurface = zDataSurface;

        if surfaceIndex > xsource
            cData = [];

            for idx = xsource:surfaceIndex
                cData = [cData; obj.data{idx}.z];
            end

            cMin = min(cData(:));
            cMax = max(cData(:));

            for idx = xsource:surfaceIndex
                obj.data{idx}.cmin = cMin;
                obj.data{idx}.cmax = cMax;
            end
        end

    elseif strcmpi(faceColor, 'flat')
        cData = get(meshData, 'CData');

        if size(cData, 3) ~= 1
            cMap = unique( reshape(cData, ...
                [size(cData,1)*size(cData,2), size(cData,3)]), 'rows' );
            cDataSurface = quantizeColors(cData);

            colorScale = getColorScale(cMap);
        else
            cDataSurface = cData;
            obj.data{surfaceIndex}.cmin = tmpCLim(1);
            obj.data{surfaceIndex}.cmax = tmpCLim(2);
        end
    end

    %-set face color-%
    obj.data{surfaceIndex}.colorscale = colorScale;
    obj.data{surfaceIndex}.surfacecolor = cDataSurface;

    %-lighting settings-%

    if isnumeric(get(meshData, 'FaceColor')) && all(get(meshData, 'FaceColor') == [1, 1, 1])
        % the native mesh faces are plain white; render them without
        % any shading so they stay white
        obj.data{surfaceIndex}.lighting.diffuse = 0;
        obj.data{surfaceIndex}.lighting.ambient = 1;
    end

    if get(meshData, 'FaceAlpha') ~= 1
        obj.data{surfaceIndex}.lighting.diffuse = 0.5;
        obj.data{surfaceIndex}.lighting.ambient = 0.725 + (1-get(meshData, 'FaceAlpha'));
    end

    if obj.PlotlyDefaults.IsLight
        obj.data{surfaceIndex}.lighting.diffuse = 1.0;
        obj.data{surfaceIndex}.lighting.ambient = 0.3;
    end

    %-opacity-%
    obj.data{surfaceIndex}.opacity = get(meshData, 'FaceAlpha');

    %-line style-%

    obj.data{contourIndex}.line.width = 3*get(meshData, 'LineWidth');

    if strcmpi(get(meshData, 'LineStyle'), '-')
        obj.data{contourIndex}.line.dash = 'solid';
    else
        obj.data{contourIndex}.line.dash = 'dot';
        obj.data{surfaceIndex}.contours.x.show = false;
        obj.data{surfaceIndex}.contours.y.show = false;
    end

    %-SCENE CONFIGURATION-%
    updateScene(obj, surfaceIndex);
    obj.data{surfaceIndex}.name = get(meshData, 'DisplayName');
    obj.data{contourIndex}.name = get(meshData, 'DisplayName');
    obj.data{surfaceIndex}.showscale = false;
    obj.data{contourIndex}.showscale = false;
    obj.data{surfaceIndex}.visible = strcmp(get(meshData, 'Visible'),'on');
    obj.data{contourIndex}.visible = strcmp(get(meshData, 'Visible'),'on');

    obj.data{surfaceIndex}.showlegend = getShowLegend(meshData);
end
