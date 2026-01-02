function obj = updateSurf(obj, surfaceIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(surfaceIndex).AssociatedAxis);

    %-CHECK FOR MULTIPLE AXES-%
    xsource = findSourceAxis(obj,axIndex);

    %-SURFACE DATA STRUCTURE- %
    meshData = obj.State.Plot(surfaceIndex).Handle;

    %-AXIS STRUCTURE-%
    axisData = ancestor(meshData.Parent,'axes');

    %-SCENE DATA-%
    scene = obj.layout.("scene" + xsource);

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
    xData = meshData.XData;
    yData = meshData.YData;
    zData = meshData.ZData;

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
    obj.data{surfaceIndex}.contours.y.size = mean(diff(yData));;
    obj.data{surfaceIndex}.contours.y.show = true;

    %-set data on scatter3d-%
    obj.data{contourIndex}.x = xDataContour(:);
    obj.data{contourIndex}.y = yDataContour(:);
    obj.data{contourIndex}.z = zDataContour(:);

    %-COLORING-%

    %-get colormap-%
    cMap = axisData.Colormap;
    fac = 1/(length(cMap)-1);
    colorScale = {};

    for c = 1: length(cMap)
        colorScale{c} = {(c-1)*fac, ...
                getStringColor(round(255*cMap(c, :)))};
    end

    %-get edge color-%
    if isnumeric(meshData.EdgeColor)
        cDataContour = getStringColor(round(255*meshData.EdgeColor));

    elseif strcmpi(meshData.EdgeColor, 'interp')
        cDataContour = zDataContour(:);
        obj.data{contourIndex}.line.colorscale = colorScale;

        obj.data{surfaceIndex}.contours.x.show = false;
        obj.data{surfaceIndex}.contours.y.show = false;

    elseif strcmpi(meshData.EdgeColor, 'flat')
        cData = meshData.CData;

        if size(cData, 3) ~= 1
            cMap = unique( reshape(cData, ...
                [size(cData,1)*size(cData,2), size(cData,3)]), 'rows' );
            cData = rgb2ind(cData, cMap);

            edgeColorScale = {};
            fac = 1/(length(cMap)-1);

            for c = 1: length(cMap)
                edgeColorScale{c} = {(c-1)*fac , ...
                        getStringColor(round(255*cMap(c, :)))};
            end

            obj.data{surfaceIndex}.line.cmin = 0;
            obj.data{surfaceIndex}.line.cmax = 255;
            obj.data{contourIndex}.line.colorscale = edgeColorScale;
        else
            obj.data{contourIndex}.line.cmin = axisData.CLim(1);
            obj.data{contourIndex}.line.cmax = axisData.CLim(2);
            obj.data{contourIndex}.line.colorscale = colorScale;
        end

        cDataContourDir1 = [cData; NaN(1, size(cData, 2))];
        cDataContourDir2 = cDataContourDir1(1:end-1,:)';
        cDataContourDir2 = [cDataContourDir2; NaN(1, size(cDataContourDir2, 2))];
        cDataContour = [cDataContourDir1(:); cDataContourDir2(:)];

        obj.data{surfaceIndex}.contours.x.show = false;
        obj.data{surfaceIndex}.contours.y.show = false;

    elseif strcmpi(meshData.EdgeColor, 'none')
        cDataContour = 'rgba(0,0,0,0)';
        obj.data{surfaceIndex}.contours.x.show = false;
        obj.data{surfaceIndex}.contours.y.show = false;
    end

    %-set edge color-%
    obj.data{contourIndex}.line.color = cDataContour;
    obj.data{surfaceIndex}.contours.x.color = cDataContour;
    obj.data{surfaceIndex}.contours.y.color = cDataContour;

    %-get face color-%
    faceColor = meshData.FaceColor;

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
        cDataSurface = double(cDataSurface) + axisData.CLim(1);

        for c = 1: size(cMapSurface, 1)
            colorScale{c} = {(c-1)*fac, ...
                    getStringColor(round(255*cMapSurface(c, :)), 1)};
        end

        obj.data{surfaceIndex}.cmin = axisData.CLim(1);
        obj.data{surfaceIndex}.cmax = axisData.CLim(2);
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
        cData = meshData.CData;
        if size(cData, 3) ~= 1
            cMap = unique( reshape(cData, ...
                [size(cData,1)*size(cData,2), size(cData,3)]), 'rows' );
            cDataSurface = rgb2ind(cData, cMap);

            colorScale = {};
            fac = 1/(length(cMap)-1);

            for c = 1: length(cMap)
                colorScale{c} = {(c-1)*fac, ...
                        getStringColor(round(255*cMap(c, :)))};
            end
        else
            cDataSurface = cData;
            obj.data{surfaceIndex}.cmin = axisData.CLim(1);
            obj.data{surfaceIndex}.cmax = axisData.CLim(2);
        end
    end

    %-set face color-%
    obj.data{surfaceIndex}.colorscale = colorScale;
    obj.data{surfaceIndex}.surfacecolor = cDataSurface;

    %-lighting settings-%
    if isnumeric(meshData.FaceColor) && all(meshData.FaceColor == [1, 1, 1])
        obj.data{surfaceIndex}.lighting.diffuse = 0.5;
        obj.data{surfaceIndex}.lighting.ambient = 0.725;
    end

    if meshData.FaceAlpha ~= 1
        obj.data{surfaceIndex}.lighting.diffuse = 0.5;
        obj.data{surfaceIndex}.lighting.ambient = 0.725 + (1-meshData.FaceAlpha);
    end

    if obj.PlotlyDefaults.IsLight
        obj.data{surfaceIndex}.lighting.diffuse = 1.0;
        obj.data{surfaceIndex}.lighting.ambient = 0.3;
    end

    obj.data{surfaceIndex}.opacity = meshData.FaceAlpha;
    obj.data{contourIndex}.line.width = 3*meshData.LineWidth;

    if strcmpi(meshData.LineStyle, '-')
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
        zar = 0.75*xyar;
    end

    scene.aspectratio.x = 1.1*xyar;
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
            xfac = -0.0;
        else
            xfac = 0.0;
        end
        yey = - xyar;
        if yey>0
            yfac = -0.3;
        else
            yfac = 0.3;
        end
        if zar>0
            zfac = -0.1;
        else
            zfac = 0.1;
        end

        scene.camera.eye.x = xey + xfac*xey;
        scene.camera.eye.y = yey + yfac*yey;
        scene.camera.eye.z = zar + zfac*zar;
    end

    %-scene axis configuration-%
    scene.xaxis.range = axisData.XLim;
    scene.yaxis.range = axisData.YLim;
    scene.zaxis.range = axisData.ZLim;

    scene.xaxis.tickvals = axisData.XTick;
    scene.xaxis.ticktext = axisData.XTickLabel;

    scene.yaxis.tickvals = axisData.YTick;
    scene.yaxis.ticktext = axisData.YTickLabel;

    scene.zaxis.tickvals = axisData.ZTick;
    scene.zaxis.ticktext = axisData.ZTickLabel;

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

    scene.xaxis.title = axisData.XLabel.String;
    scene.yaxis.title = axisData.YLabel.String;
    scene.zaxis.title = axisData.ZLabel.String;

    scene.xaxis.tickfont.size = axisData.FontSize;
    scene.yaxis.tickfont.size = axisData.FontSize;
    scene.zaxis.tickfont.size = axisData.FontSize;

    scene.xaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);
    scene.yaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);
    scene.zaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);

    %-SET SCENE TO LAYOUT-%
    obj.layout.("scene" + xsource) = scene;

    obj.data{surfaceIndex}.name = meshData.DisplayName;
    obj.data{contourIndex}.name = meshData.DisplayName;
    obj.data{surfaceIndex}.showscale = false;
    obj.data{contourIndex}.showscale = false;
    obj.data{surfaceIndex}.visible = strcmp(meshData.Visible,'on');
    obj.data{contourIndex}.visible = strcmp(meshData.Visible,'on');

    switch meshData.Annotation.LegendInformation.IconDisplayStyle
        case "on"
            obj.data{surfaceIndex}.showlegend = true;
        case "off"
            obj.data{surfaceIndex}.showlegend = false;
    end
end
