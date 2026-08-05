function obj = updateFunctionSurface(obj, surfaceIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(surfaceIndex).AssociatedAxis);

    %-CHECK FOR MULTIPLE AXES-%
    xsource = findSourceAxis(obj,axIndex);

    %-SURFACE DATA STRUCTURE- %
    meshData = obj.State.Plot(surfaceIndex).Handle;
    figureData = obj.State.Figure.Handle;

    %-AXIS STRUCTURE-%
    axisData = ancestor(get(meshData, 'Parent'),'axes');

    %-get plot data-%
    meshDensity = get(meshData, 'MeshDensity');
    tmpXData = get(meshData, 'XData');
    xData = tmpXData(1:meshDensity^2);
    tmpYData = get(meshData, 'YData');
    yData = tmpYData(1:meshDensity^2);
    tmpZData = get(meshData, 'ZData');
    zData = tmpZData(1:meshDensity^2);

    xDataSurface = reformatDataToMesh(xData, meshDensity);
    yDataSurface = reformatDataToMesh(yData, meshDensity);
    zDataSurface = reformatDataToMesh(zData, meshDensity);

    surfaceData.scene = sprintf("scene%d", xsource);
    surfaceData.type = "surface";
    surfaceData.x = xDataSurface;
    surfaceData.y = yDataSurface;
    surfaceData.z = zDataSurface;
    surfaceData.name = get(meshData, 'DisplayName');
    surfaceData.showscale = false;
    surfaceData.visible = strcmp(get(meshData, 'Visible'), "on");

    contourData.scene = sprintf("scene%d", xsource);
    contourData.type = "scatter3d";
    contourData.mode = "lines";
    contourData.x = getContourDataFromSurface(xDataSurface);
    contourData.y = getContourDataFromSurface(yDataSurface);
    contourData.z = getContourDataFromSurface(zDataSurface);
    contourData.name = get(meshData, 'DisplayName');
    contourData.showscale = false;
    contourData.visible = strcmp(get(meshData, 'Visible'), "on");

    %-COLORING-%

    %-get colormap-%
    cMap = get(figureData, 'Colormap');
    colorScale = getColorScale(cMap);
    %-get edge color-%
    if isnumeric(get(meshData, 'EdgeColor'))
        cDataContour = getStringColor(round(255*get(meshData, 'EdgeColor')));
    elseif strcmpi(get(meshData, 'EdgeColor'), "interp")
        cDataContour = contourData.z;
        contourData.line.colorscale = colorScale;
    elseif strcmpi(get(meshData, 'EdgeColor'), "none")
        cDataContour = "rgba(0,0,0,0)";
    end

    contourData.line.color = cDataContour;

    if isnumeric(get(meshData, 'FaceColor'))
        for n = 1:size(zDataSurface, 2)
            for m = 1:size(zDataSurface, 1)
                cDataSurface(m, n, :) = get(meshData, 'FaceColor');
            end
        end
        [cDataSurface, cMapSurface] = rgb2ind(cDataSurface, 256);
        fac = 1/255;
        for c = 1: size(cMapSurface, 1)
            colorScale{c} = { (c-1)*fac , getStringColor(round(255*cMapSurface(c, :)), 1)};
        end
        surfaceData.cmin = 0;
        surfaceData.cmax = 255;
    elseif strcmpi(meshData.FaceColor, 'interp')
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

    surfaceData.colorscale = colorScale;
    surfaceData.surfacecolor = cDataSurface;

    if isnumeric(get(meshData, 'FaceColor')) && all(get(meshData, 'FaceColor') == [1, 1, 1])
        surfaceData.lighting.diffuse = 0.5;
        surfaceData.lighting.ambient = 0.725;
    end
    if get(meshData, 'FaceAlpha') ~= 1
        surfaceData.lighting.diffuse = 0.5;
        surfaceData.lighting.ambient = 0.725 + (1-get(meshData, 'FaceAlpha'));
    end
    if obj.PlotlyDefaults.IsLight
        surfaceData.lighting.diffuse = 1.0;
        surfaceData.lighting.ambient = 0.3;
    end

    surfaceData.opacity = get(meshData, 'FaceAlpha');
    contourData.line.width = 3*get(meshData, 'LineWidth');
    contourData.line.dash = getLineDash(get(meshData, 'LineStyle'));

    surfaceData.showlegend = getShowLegend(meshData);

    obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
    contourIndex = obj.PlotOptions.nPlots;
    obj.data{surfaceIndex} = surfaceData;
    obj.data{contourIndex} = contourData;

    if strcmpi(get(meshData, 'ShowContours'), "on")
        obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
        projectionIndex = obj.PlotOptions.nPlots;
        obj.data{projectionIndex} = struct( ...
            "type", "surface", ...
            "scene", sprintf("scene%d", xsource), ...
            "x", xDataSurface, ...
            "y", yDataSurface, ...
            "z", zDataSurface, ...
            "colorscale", colorScale, ...
            "hidesurface", true, ...
            "surfacecolor", zDataSurface, ...
            "showscale", false, ...
            "contours", struct( ...
                "z", struct( ...
                    "show", true, ...
                    "width", 15, ...
                    "usecolormap", true, ...
                    "project.z", true ...
                ) ...
            ) ...
        );
    end

    %-SCENE CONFIGURATION-%
    scene = obj.layout.(sprintf("scene%d", xsource));

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

    scene.xaxis.range = get(axisData, 'XLim');
    scene.xaxis.tickvals = get(axisData, 'XTick');
    scene.xaxis.ticktext = get(axisData, 'XTickLabel');
    scene.xaxis.zeroline = false;
    scene.xaxis.showline = true;
    scene.xaxis.tickcolor = "rgba(0,0,0,1)";
    scene.xaxis.ticklabelposition = "outside";
    scene.xaxis.title = get(get(axisData, 'XLabel'), 'String');
    scene.xaxis.tickfont.size = get(axisData, 'FontSize');
    scene.xaxis.tickfont.family = matlab2plotlyfont(get(axisData, 'FontName'));

    scene.yaxis.range = get(axisData, 'YLim');
    scene.yaxis.tickvals = get(axisData, 'YTick');
    scene.yaxis.ticktext = get(axisData, 'YTickLabel');
    scene.yaxis.zeroline = false;
    scene.yaxis.showline = true;
    scene.yaxis.tickcolor = "rgba(0,0,0,1)";
    scene.yaxis.ticklabelposition = "outside";
    scene.yaxis.title = get(get(axisData, 'YLabel'), 'String');
    scene.yaxis.tickfont.size = get(axisData, 'FontSize');
    scene.yaxis.tickfont.family = matlab2plotlyfont(get(axisData, 'FontName'));

    scene.zaxis.range = get(axisData, 'ZLim');
    scene.zaxis.tickvals = get(axisData, 'ZTick');
    scene.zaxis.ticktext = get(axisData, 'ZTickLabel');
    scene.zaxis.zeroline = false;
    scene.zaxis.showline = true;
    scene.zaxis.tickcolor = "rgba(0,0,0,1)";
    scene.zaxis.ticklabelposition = "outside";
    scene.zaxis.title = get(get(axisData, 'ZLabel'), 'String');
    scene.zaxis.tickfont.size = get(axisData, 'FontSize');
    scene.zaxis.tickfont.family = matlab2plotlyfont(get(axisData, 'FontName'));

    obj.layout.(sprintf("scene%d", xsource)) = scene;
end

function surfaceData = reformatDataToMesh(data, meshDensity)
    surfaceData = reshape(data, [meshDensity, meshDensity])';
end

function contourData = getContourDataFromSurface(surfaceData)
    contourData = [surfaceData; NaN(1, size(surfaceData, 2))];
    contourData = [contourData; contourData(1:end-1,:)'];
    contourData = [contourData; NaN(1, size(contourData, 2))];
    contourData = contourData(:);
end
