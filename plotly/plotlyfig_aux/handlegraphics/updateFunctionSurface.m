function obj = updateFunctionSurface(obj, surfaceIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(surfaceIndex).AssociatedAxis);

    %-CHECK FOR MULTIPLE AXES-%
    xsource = findSourceAxis(obj,axIndex);

    %-SURFACE DATA STRUCTURE- %
    meshData = obj.State.Plot(surfaceIndex).Handle;
    figureData = obj.State.Figure.Handle;

    %-AXIS STRUCTURE-%
    axisData = ancestor(meshData.Parent,'axes');

    %-get plot data-%
    meshDensity = meshData.MeshDensity;
    xData = meshData.XData(1:meshDensity^2);
    yData = meshData.YData(1:meshDensity^2);
    zData = meshData.ZData(1:meshDensity^2);

    xDataSurface = reformatDataToMesh(xData, meshDensity);
    yDataSurface = reformatDataToMesh(yData, meshDensity);
    zDataSurface = reformatDataToMesh(zData, meshDensity);

    surfaceData.scene = "scene" + xsource;
    surfaceData.type = "surface";
    surfaceData.x = xDataSurface;
    surfaceData.y = yDataSurface;
    surfaceData.z = zDataSurface;
    surfaceData.name = meshData.DisplayName;
    surfaceData.showscale = false;
    surfaceData.visible = meshData.Visible == "on";

    contourData.scene = "scene" + xsource;
    contourData.type = "scatter3d";
    contourData.mode = "lines";
    contourData.x = getContourDataFromSurface(xDataSurface);
    contourData.y = getContourDataFromSurface(yDataSurface);
    contourData.z = getContourDataFromSurface(zDataSurface);
    contourData.name = meshData.DisplayName;
    contourData.showscale = false;
    contourData.visible = meshData.Visible == "on";

    %-COLORING-%

    %-get colormap-%
    cMap = figureData.Colormap;
    fac = 1/(length(cMap)-1);
    colorScale = cell(1,length(cMap));

    for c = 1:length(cMap)
        colorScale{c} = {(c-1)*fac, getStringColor(round(255*cMap(c, :)))};
    end
    %-get edge color-%
    if isnumeric(meshData.EdgeColor)
        cDataContour = getStringColor(round(255*meshData.EdgeColor));
    elseif strcmpi(meshData.EdgeColor, "interp")
        cDataContour = contourData.z;
        contourData.line.colorscale = colorScale;
    elseif strcmpi(meshData.EdgeColor, "none")
        cDataContour = "rgba(0,0,0,0)";
    end

    contourData.line.color = cDataContour;

    if isnumeric(meshData.FaceColor)
        for n = 1:size(zDataSurface, 2)
            for m = 1:size(zDataSurface, 1)
                cDataSurface(m, n, :) = meshData.FaceColor;
            end
        end
        [cDataSurface, cMapSurface] = rgb2ind(cDataSurface, 256);
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

    if isnumeric(meshData.FaceColor) && all(meshData.FaceColor == [1, 1, 1])
        surfaceData.lighting.diffuse = 0.5;
        surfaceData.lighting.ambient = 0.725;
    end
    if meshData.FaceAlpha ~= 1
        surfaceData.lighting.diffuse = 0.5;
        surfaceData.lighting.ambient = 0.725 + (1-meshData.FaceAlpha);
    end
    if obj.PlotlyDefaults.IsLight
        surfaceData.lighting.diffuse = 1.0;
        surfaceData.lighting.ambient = 0.3;
    end

    surfaceData.opacity = meshData.FaceAlpha;
    contourData.line.width = 3*meshData.LineWidth;
    contourData.line.dash = getLineDash(meshData.LineStyle);

    switch meshData.Annotation.LegendInformation.IconDisplayStyle
        case "on"
            surfaceData.showlegend = true;
        case "off"
            surfaceData.showlegend = false;
    end

    obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
    contourIndex = obj.PlotOptions.nPlots;
    obj.data{surfaceIndex} = surfaceData;
    obj.data{contourIndex} = contourData;

    if lower(meshData.ShowContours) == "on"
        obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
        projectionIndex = obj.PlotOptions.nPlots;
        obj.data{projectionIndex} = struct( ...
            "type", "surface", ...
            "scene", "scene" + xsource, ...
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
    scene = obj.layout.("scene" + xsource);

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

    scene.xaxis.range = axisData.XLim;
    scene.xaxis.tickvals = axisData.XTick;
    scene.xaxis.ticktext = axisData.XTickLabel;
    scene.xaxis.zeroline = false;
    scene.xaxis.showline = true;
    scene.xaxis.tickcolor = "rgba(0,0,0,1)";
    scene.xaxis.ticklabelposition = "outside";
    scene.xaxis.title = axisData.XLabel.String;
    scene.xaxis.tickfont.size = axisData.FontSize;
    scene.xaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);

    scene.yaxis.range = axisData.YLim;
    scene.yaxis.tickvals = axisData.YTick;
    scene.yaxis.ticktext = axisData.YTickLabel;
    scene.yaxis.zeroline = false;
    scene.yaxis.showline = true;
    scene.yaxis.tickcolor = "rgba(0,0,0,1)";
    scene.yaxis.ticklabelposition = "outside";
    scene.yaxis.title = axisData.YLabel.String;
    scene.yaxis.tickfont.size = axisData.FontSize;
    scene.yaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);

    scene.zaxis.range = axisData.ZLim;
    scene.zaxis.tickvals = axisData.ZTick;
    scene.zaxis.ticktext = axisData.ZTickLabel;
    scene.zaxis.zeroline = false;
    scene.zaxis.showline = true;
    scene.zaxis.tickcolor = "rgba(0,0,0,1)";
    scene.zaxis.ticklabelposition = "outside";
    scene.zaxis.title = axisData.ZLabel.String;
    scene.zaxis.tickfont.size = axisData.FontSize;
    scene.zaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);

    obj.layout.("scene" + xsource) = scene;
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
