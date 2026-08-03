function obj = updateFmesh(obj, surfaceIndex)
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

    %-associate scene-%
    obj.data{surfaceIndex}.scene = sprintf('scene%d', xsource);
    obj.data{contourIndex}.scene = sprintf('scene%d', xsource);

    %-surface type for face color-%
    obj.data{surfaceIndex}.type = 'surface';

    %-scatter3d type for contour mesh lines-%
    obj.data{contourIndex}.type = 'scatter3d';
    obj.data{contourIndex}.mode = 'lines';

    %-get plot data-%
    meshDensity = get(meshData, 'MeshDensity');
    tmpXData = get(meshData, 'XData');
    xData = tmpXData(1:meshDensity^2);
    tmpYData = get(meshData, 'YData');
    yData = tmpYData(1:meshDensity^2);
    tmpZData = get(meshData, 'ZData');
    zData = tmpZData(1:meshDensity^2);

    %-reformat data to mesh-%
    xDataSurface = reshape(xData, [meshDensity, meshDensity])';
    yDataSurface = reshape(yData, [meshDensity, meshDensity])';
    zDataSurface = reshape(zData, [meshDensity, meshDensity])';

    xDataContour = [xDataSurface; NaN(1, size(xDataSurface, 2))];
    yDataContour = [yDataSurface; NaN(1, size(yDataSurface, 2))];
    zDataContour = [zDataSurface; NaN(1, size(zDataSurface, 2))];

    xDataContour = [xDataContour; xDataContour(1:end-1,:)'];
    yDataContour = [yDataContour; yDataContour(1:end-1,:)'];
    zDataContour = [zDataContour; zDataContour(1:end-1,:)'];

    xDataContour = [xDataContour; NaN(1, size(xDataContour, 2))];
    yDataContour = [yDataContour; NaN(1, size(yDataContour, 2))];
    zDataContour = [zDataContour; NaN(1, size(zDataContour, 2))];

    %-set data on surface-%
    obj.data{surfaceIndex}.x = xDataSurface;
    obj.data{surfaceIndex}.y = yDataSurface;
    obj.data{surfaceIndex}.z = zDataSurface;

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
    elseif strcmpi(get(meshData, 'EdgeColor'), "interp")
        cDataContour = zDataContour(:);
        obj.data{contourIndex}.line.colorscale = colorScale;
    elseif strcmpi(get(meshData, 'EdgeColor'), "none")
        cDataContour = "rgba(0,0,0,0)";
    end

    %-set edge color-%
    obj.data{contourIndex}.line.color = cDataContour;

    %-get face color-%
    if isnumeric(get(meshData, 'FaceColor'))
        for n = 1:size(zDataSurface, 2)
            for m = 1:size(zDataSurface, 1)
                cDataSurface(m, n, :) = get(meshData, 'FaceColor');
            end
        end

        [cDataSurface, cMapSurface] = rgb2ind(cDataSurface, 256);

        for c = 1:size(cMapSurface, 1)
            colorScale{c} = {(c-1)*fac, getStringColor(round(255*cMapSurface(c, :)), 1)};
        end

        obj.data{surfaceIndex}.cmin = 0;
        obj.data{surfaceIndex}.cmax = 255;

    elseif strcmpi(get(meshData, 'FaceColor'), 'interp')
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
    end

    obj.data{surfaceIndex}.colorscale = colorScale;
    obj.data{surfaceIndex}.surfacecolor = cDataSurface;

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

    obj.data{contourIndex}.line.width = 3*get(meshData, 'LineWidth');
    obj.data{contourIndex}.line.dash = getLineDash(get(meshData, 'LineStyle'));


    if strcmpi(get(meshData, 'ShowContours'), 'on')
        obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
        projectionIndex = obj.PlotOptions.nPlots;

        obj.data{projectionIndex}.type = 'surface';
        obj.data{projectionIndex}.scene = sprintf('scene%d', xsource);

        obj.data{projectionIndex}.x = xDataSurface;
        obj.data{projectionIndex}.y = yDataSurface;
        obj.data{projectionIndex}.z = zDataSurface;

        obj.data{projectionIndex}.colorscale = colorScale;
        obj.data{projectionIndex}.hidesurface = true;
        obj.data{projectionIndex}.surfacecolor = zDataSurface;
        obj.data{projectionIndex}.showscale = false;

        obj.data{projectionIndex}.contours.z.show = true;
        obj.data{projectionIndex}.contours.z.width = 15;
        obj.data{projectionIndex}.contours.z.usecolormap = true;
        obj.data{projectionIndex}.contours.z.project.z = true;
    end

    %-SCENE CONFIGURATION-%
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
