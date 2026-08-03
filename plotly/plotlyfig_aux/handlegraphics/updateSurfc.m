function obj = updateSurfc(obj, dataIndex)
    if strcmpi(obj.State.Plot(dataIndex).Class, 'surface')
        surfaceIndex = dataIndex;
        updateSurfOnly(obj, surfaceIndex)
    elseif strcmpi(obj.State.Plot(dataIndex).Class, 'contour')
        contourIndex = dataIndex;
        updateContourOnly(obj, contourIndex)
    end
end

function updateContourOnly(obj, contourIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(contourIndex).AssociatedAxis);

    %-CHECK FOR MULTIPLE AXES-%
    xsource = findSourceAxis(obj,axIndex);

    %-AXIS DATA STRUCTURE-%
    axisData = obj.State.Plot(contourIndex).AssociatedAxis;

    %-CONTOUR DATA STRUCTURE- %
    contourData = obj.State.Plot(contourIndex).Handle;
    surfData = obj.State.Plot(contourIndex-1).Handle;
    figureData = obj.State.Figure.Handle;

    %-associate scene-%
    obj.data{contourIndex}.scene = sprintf('scene%d', xsource);

    %-scatter3d type for contour projection-%
    obj.data{contourIndex}.type = 'scatter3d';
    obj.data{contourIndex}.mode = 'lines';

    %-get colormap-%
    cMap = get(figureData, 'Colormap');
    colorScale = getColorScale(cMap);

    %-get plot data-%
    contourMatrix = get(contourData, 'ContourMatrix');

    xData = [];
    yData = [];
    zData = [];
    cData = [];

    tmpZLim = get(axisData, 'ZLim');
    zmin = tmpZLim(1);
    len = size(contourMatrix, 2);
    n = 1;

    while (n < len)
        %-get plot data-%
        m = contourMatrix(2, n);
        zlevel = contourMatrix(1, n);

        xData = [xData, contourMatrix(1, n+1:n+m), NaN];
        yData = [yData, contourMatrix(2, n+1:n+m), NaN];
        zData = [zData, zmin * ones(1, m), NaN];

        if isnumeric(get(contourData, 'LineColor'))
            cData = getStringColor(round(255*get(contourData, 'LineColor')));
        elseif strcmpi(get(contourData, 'LineColor'), 'interp')
            cData = zData;
            obj.data{contourIndex}.line.colorscale = colorScale;
        elseif strcmpi(get(contourData, 'LineColor'), 'flat')
            [err, r] = min(abs(get(surfData, 'ZData') - zlevel));
            [~, c] = min(err);
            r = r(c);

            tmpZData = get(surfData, 'ZData');
            cData = [cData, tmpZData(r, c) * ones(1, m), NaN];
            obj.data{contourIndex}.line.colorscale = colorScale;
        elseif strcmpi(get(contourData, 'LineColor'), 'none')
            cData = 'rgba(0,0,0,0)';
        end
        n = n + m + 1;
    end

    obj.data{contourIndex}.x = xData;
    obj.data{contourIndex}.y = yData;
    obj.data{contourIndex}.z = zData;

    obj.data{contourIndex}.line.color = cData;
    obj.data{contourIndex}.line.width = 2*get(contourData, 'LineWidth');
    obj.data{contourIndex}.line.dash = getLineDash(get(contourData, 'LineStyle'));

    obj.data{contourIndex}.name = get(contourData, 'DisplayName');
    obj.data{contourIndex}.showscale = false;
    obj.data{contourIndex}.visible = strcmp(get(contourData, 'Visible'),'on');
end


function updateSurfOnly(obj, surfaceIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(surfaceIndex).AssociatedAxis);

    %-CHECK FOR MULTIPLE AXES-%
    xsource = findSourceAxis(obj,axIndex);

    %-SURFACE DATA STRUCTURE- %
    meshData = obj.State.Plot(surfaceIndex).Handle;
    figureData = obj.State.Figure.Handle;

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
    cMap = get(figureData, 'Colormap');
    colorScale = getColorScale(cMap);

    %-get edge color-%
    if isnumeric(get(meshData, 'EdgeColor'))
        cDataContour = getStringColor(round(255*get(meshData, 'EdgeColor')));

    elseif strcmpi(get(meshData, 'EdgeColor'), 'interp')
        cDataContour = zDataContour(:);
        obj.data{contourIndex}.line.colorscale = colorScale;
        obj.data{surfaceIndex}.contours.x.colorscale = cDataContour;
        obj.data{surfaceIndex}.contours.y.colorscale = cDataContour;

        obj.data{surfaceIndex}.contours.x.show = false;
        obj.data{surfaceIndex}.contours.y.show = false;

    elseif strcmpi(get(meshData, 'EdgeColor'), 'flat')
        cData = get(meshData, 'CData');
tmpCLim = get(axisData, 'CLim');

        if size(cData, 3) ~= 1
            cMap = unique( reshape(cData, ...
                [size(cData,1)*size(cData,2), size(cData,3)]), 'rows' );
            cData = rgb2ind(cData, cMap);

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
    end

    %-set edge color-%
    obj.data{contourIndex}.line.color = cDataContour;
    obj.data{surfaceIndex}.contours.x.color = cDataContour;
    obj.data{surfaceIndex}.contours.y.color = cDataContour;

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

        [cDataSurface, cMapSurface] = rgb2ind(cDataSurface, 256);
        cDataSurface = double(cDataSurface) + tmpCLim(1);

        for c = 1: size(cMapSurface, 1)
            colorScale{c} = {(c-1)*fac, ...
                    getStringColor(round(255*cMapSurface(c, :)), 1)};
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
            cMap = unique(reshape(cData, [size(cData,1)*size(cData,2), ...
                    size(cData,3)]), 'rows');
            cDataSurface = rgb2ind(cData, cMap);

            colorScale = getColorScale(cMap);
        else
            cDataSurface = cData;
        end
    end

    %-set face color-%
    obj.data{surfaceIndex}.colorscale = colorScale;
    obj.data{surfaceIndex}.surfacecolor = cDataSurface;

    %-lighting settings-%
    if isnumeric(get(meshData, 'FaceColor')) && all(get(meshData, 'FaceColor') == [1, 1, 1])
        obj.data{surfaceIndex}.lighting.diffuse = 0.5;
        obj.data{surfaceIndex}.lighting.ambient = 0.725;
    end

    if get(meshData, 'FaceAlpha') ~= 1
        obj.data{surfaceIndex}.lighting.diffuse = 0.5;
        obj.data{surfaceIndex}.lighting.ambient = 0.725 + (1-get(meshData, 'FaceAlpha'));
    end

    if obj.PlotlyDefaults.IsLight
        obj.data{surfaceIndex}.lighting.diffuse = 1.0;
        obj.data{surfaceIndex}.lighting.ambient = 0.3;
    end

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

    %-aspect ratio-%
    asr = obj.PlotOptions.AspectRatio;

    if ~isempty(asr)
        if ischar(asr)
            scene.aspectmode = asr;
        elseif isvector(ar) && length(asr) == 3
            zar = asr(3);
        end
    else
        %-define as default-%
        xar = max(xData(:));
        yar = max(yData(:));
        xyar = max([xar, yar]);
        zar = 0.7*xyar;
    end

    scene.aspectratio.x = 1.15*xyar;
    scene.aspectratio.y = 1.0*xyar;
    scene.aspectratio.z = zar;

    %-camera eye-%
    ey = obj.PlotOptions.CameraEye;

    if ~isempty(ey)
        if isvector(ey) && length(ey) == 3
            scene.camera.eye.x = ey(1);
            scene.camera.eye.y = ey(2);
            scene.camera.eye.z = ey(3);
        end
    else
        %-define as default-%
        xey = - xyar;
        if xey>0
            xfac = 0.1;
        else
            xfac = -0.1;
        end
        yey = - xyar;
        if yey>0
            yfac = -0.5;
        else
            yfac = 0.5;
        end
        if zar>0
            zfac = 0.1;
        else
            zfac = -0.1;
        end

        scene.camera.eye.x = xey + xfac*xey;
        scene.camera.eye.y = yey + yfac*yey;
        scene.camera.eye.z = zar + zfac*zar;
    end

    %-scene axis configuration-%
    scene.xaxis.range = get(axisData, 'XLim');
    scene.yaxis.range = get(axisData, 'YLim');
    scene.zaxis.range = get(axisData, 'ZLim');

    scene.xaxis.tickvals = get(axisData, 'XTick');
    scene.xaxis.ticktext = get(axisData, 'XTickLabel');

    scene.yaxis.tickvals = get(axisData, 'YTick');
    scene.yaxis.ticktext = get(axisData, 'YTickLabel');

    scene.zaxis.tickvals = get(axisData, 'ZTick');
    scene.zaxis.ticktext = get(axisData, 'ZTickLabel');

    scene.xaxis.zeroline = false;
    scene.yaxis.zeroline = false;
    scene.zaxis.zeroline = false;

    scene.xaxis.showline = true;
    scene.yaxis.showline = true;
    scene.zaxis.showline = true;

    scene.xaxis.tickcolor = 'rgba(0,0,0,1)';
    scene.yaxis.tickcolor = 'rgba(0,0,0,1)';
    scene.zaxis.tickcolor = 'rgba(0,0,0,1)';

    scene.xaxis.ticklabelposition = 'outside';
    scene.yaxis.ticklabelposition = 'outside';
    scene.zaxis.ticklabelposition = 'outside';

    scene.xaxis.title = get(get(axisData, 'XLabel'), 'String');
    scene.yaxis.title = get(get(axisData, 'YLabel'), 'String');
    scene.zaxis.title = get(get(axisData, 'ZLabel'), 'String');

    scene.xaxis.tickfont.size = get(axisData, 'FontSize');
    scene.yaxis.tickfont.size = get(axisData, 'FontSize');
    scene.zaxis.tickfont.size = get(axisData, 'FontSize');

    scene.xaxis.tickfont.family = matlab2plotlyfont(get(axisData, 'FontName'));
    scene.yaxis.tickfont.family = matlab2plotlyfont(get(axisData, 'FontName'));
    scene.zaxis.tickfont.family = matlab2plotlyfont(get(axisData, 'FontName'));

    %-SET SCENE TO LAYOUT-%
    obj.layout.(sprintf("scene%d", xsource)) = scene;

    obj.data{surfaceIndex}.name = get(meshData, 'DisplayName');
    obj.data{contourIndex}.name = get(meshData, 'DisplayName');
    obj.data{surfaceIndex}.showscale = false;
    obj.data{contourIndex}.showscale = false;
    obj.data{surfaceIndex}.visible = strcmp(get(meshData, 'Visible'),'on');
    obj.data{contourIndex}.visible = strcmp(get(meshData, 'Visible'),'on');

    obj.data{surfaceIndex}.showlegend = getShowLegend(meshData);
end
