function data = updateLineseries(obj, plotIndex)
    %-INITIALIZATIONS-%

    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    plotData = obj.State.Plot(plotIndex).Handle;

    %-check for multiple axes-%
    if isprop(plotData.Parent, "YAxis") && numel(plotData.Parent.YAxis) > 1
        yaxMatch = zeros(1,2);
        for yax = 1:2
            yAxisColor = plotData.Parent.YAxis(yax).Color;
            yaxMatch(yax) = sum(yAxisColor == plotData.Color);
        end
        [~, yaxIndex] = max(yaxMatch);
        [xSource, ySource] = findSourceAxis(obj, axIndex, yaxIndex);
    else
        [xSource, ySource] = findSourceAxis(obj,axIndex);
    end

    treatAs = lower(obj.PlotOptions.TreatAs);
    isPolar = ismember('compass', treatAs) || ismember('ezpolar', treatAs);

    isPlot3D = isfield(plotData, "ZData") && ~isempty(plotData.ZData);

    xData = plotData.XData;
    yData = plotData.YData;

    if isPolar
        rData = sqrt(xData.^2 + yData.^2);
        thetaData = atan2(xData, yData);
        thetaData = -(rad2deg(thetaData) - 90);
    end

    if isPlot3D
        zData = plotData.ZData;
    end

    if isPolar
        data.type = "scatterpolar";
        data.subplot = sprintf("polar%d", xSource+1);
        obj.layout.(data.subplot) = updateDefaultPolarAxes(obj, plotIndex);
    elseif ~isPlot3D
        data.type = "scatter";
        data.xaxis = "x" + xSource;
        data.yaxis = "y" + ySource;
    else
        data.type = "scatter3d";
        data.scene = "scene" + xSource;
        updateScene(obj, plotIndex);
    end

    data.visible = plotData.Visible == "on";
    data.name = plotData.DisplayName;
    data.mode = getScatterMode(plotData);

    if isPolar
        data.r = rData;
        data.theta = thetaData;
    else
        data.x = xData;
        data.y = yData;
        if isPlot3D
            data.z = zData;
            obj.PlotOptions.is3d = true;
        end
    end

    data.line = extractLineLine(plotData);
    if isPolar
        data.line.width = data.line.width * 1.5;
    end
    data.marker = extractLineMarker(plotData);
    data.showlegend = getShowLegend(plotData);
end

function updateScene(obj, dataIndex)
    %-INITIALIZATIONS-%
    axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);
    plotData = obj.State.Plot(dataIndex).Handle;
    axisData = plotData.Parent;
    xSource = findSourceAxis(obj, axIndex);
    scene = obj.layout.("scene" + xSource);

    aspectRatio = axisData.PlotBoxAspectRatio;
    cameraPosition = axisData.CameraPosition;
    dataAspectRatio = axisData.DataAspectRatio;
    cameraUpVector = axisData.CameraUpVector;
    cameraEye = cameraPosition./dataAspectRatio;

    cameraOffset = 0.5;
    normFac = abs(min(cameraEye));
    normFac = normFac / (max(aspectRatio)/min(aspectRatio) + cameraOffset);

    %-aspect ratio-%
    scene.aspectratio.x = 1.0*aspectRatio(1);
    scene.aspectratio.y = 1.0*aspectRatio(2);
    scene.aspectratio.z = 1.0*aspectRatio(3);

    %-camera eye-%
    scene.camera.eye.x = cameraEye(1)/normFac;
    scene.camera.eye.y = cameraEye(2)/normFac;
    scene.camera.eye.z = cameraEye(3)/normFac;

    %-camera up-%
    scene.camera.up.x = cameraUpVector(1);
    scene.camera.up.y = cameraUpVector(2);
    scene.camera.up.z = cameraUpVector(3);

    %-scene axis configuration-%
    scene.xaxis.range = axisData.XLim;
    scene.yaxis.range = axisData.YLim;
    scene.zaxis.range = axisData.ZLim;

    scene.xaxis.zeroline = false;
    scene.yaxis.zeroline = false;
    scene.zaxis.zeroline = false;

    scene.xaxis.showline = true;
    scene.yaxis.showline = true;
    scene.zaxis.showline = true;

    scene.xaxis.ticklabelposition = "outside";
    scene.yaxis.ticklabelposition = "outside";
    scene.zaxis.ticklabelposition = "outside";

    scene.xaxis.title = axisData.XLabel.String;
    scene.yaxis.title = axisData.YLabel.String;
    scene.zaxis.title = axisData.ZLabel.String;

    scene.xaxis.titlefont.color = "rgba(0,0,0,1)";
    scene.yaxis.titlefont.color = "rgba(0,0,0,1)";
    scene.zaxis.titlefont.color = "rgba(0,0,0,1)";
    scene.xaxis.titlefont.size = axisData.XLabel.FontSize;
    scene.yaxis.titlefont.size = axisData.YLabel.FontSize;
    scene.zaxis.titlefont.size = axisData.ZLabel.FontSize;
    scene.xaxis.titlefont.family = matlab2plotlyfont(axisData.XLabel.FontName);
    scene.yaxis.titlefont.family = matlab2plotlyfont(axisData.YLabel.FontName);
    scene.zaxis.titlefont.family = matlab2plotlyfont(axisData.ZLabel.FontName);

    %-tick labels-%
    xTick = axisData.XTick;
    if isduration(xTick) || isdatetime(xTick)
        xTickChar = char(xTick);
        xTickLabel = axisData.XTickLabel;
        for n = 1:length(xTickLabel)
            for m = 1:size(xTickChar, 1)
                if ~isempty(strfind(string(xTickChar(m, :)), xTickLabel{n}))
                    idx(n) = m;
                end
            end
        end
        xTick = datenum(xTick(idx));
    end

    yTick = axisData.YTick;
    if isduration(yTick) || isdatetime(yTick)
        yTickChar = char(yTick);
        yTickLabel = axisData.YTickLabel;
        for n = 1:length(yTickLabel)
            for m = 1:size(yTickChar, 1)
                if ~isempty(strfind(string(yTickChar(m, :)), yTickLabel{n}))
                    idx(n) = m;
                end
            end
        end
        yTick = datenum(yTick(idx));
    end


    zTick = axisData.ZTick;
    if isduration(zTick) || isdatetime(zTick)
        zTickChar = char(zTick);
        zTickLabel = axisData.ZTickLabel;
        for n = 1:length(zTickLabel)
            for m = 1:size(zTickChar, 1)
                if ~isempty(strfind(string(zTickChar(m, :)), zTickLabel{n}))
                    idx(n) = m;
                end
            end
        end
        zTick = datenum(zTick(idx));
    end

    scene.xaxis.tickvals = xTick;
    scene.xaxis.ticktext = axisData.XTickLabel;
    scene.yaxis.tickvals = yTick;
    scene.yaxis.ticktext = axisData.YTickLabel;
    scene.zaxis.tickvals = zTick;
    scene.zaxis.ticktext = axisData.ZTickLabel;

    scene.xaxis.tickcolor = "rgba(0,0,0,1)";
    scene.yaxis.tickcolor = "rgba(0,0,0,1)";
    scene.zaxis.tickcolor = "rgba(0,0,0,1)";
    scene.xaxis.tickfont.size = axisData.FontSize;
    scene.yaxis.tickfont.size = axisData.FontSize;
    scene.zaxis.tickfont.size = axisData.FontSize;
    scene.xaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);
    scene.yaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);
    scene.zaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);

    %-grid-%
    if strcmp(axisData.XGrid, "off")
        scene.xaxis.showgrid = false;
    end
    if strcmp(axisData.YGrid, "off")
        scene.yaxis.showgrid = false;
    end
    if strcmp(axisData.ZGrid, "off")
        scene.zaxis.showgrid = false;
    end

    %-SET SCENE TO LAYOUT-%
    obj.layout.("scene" + xsource) = scene;
end

function polarAxis = updateDefaultPolarAxes(obj, plotIndex)
    %-INITIALIZATIONS-%
    plotData = obj.State.Plot(plotIndex).Handle;
    axisData = plotData.Parent;

    thetaAxis = axisData.XAxis;
    rAxis = axisData.YAxis;
    thetaLabel = thetaAxis.Label;

    %-set domain plot-%
    xo = axisData.Position(1);
    yo = axisData.Position(2);
    w = axisData.Position(3);
    h = axisData.Position(4);

    tickValues = rAxis.TickValues;
    tickValues = tickValues(find(tickValues==0) + 1 : end);
    rLabel = rAxis.Label;

    gridColor = getStringColor(255*axisData.GridColor, axisData.GridAlpha);
    gridWidth = axisData.LineWidth;

    polarAxis.domain = struct( ...
        "x", min([xo xo + w], 1), ...
        "y", min([yo yo + h], 1) ...
    );
    polarAxis.angularaxis = struct(...
        "ticklen", 0, ...
        "autorange", true, ...
        "linecolor", gridColor, ...
        "gridwidth", gridWidth, ...
        "gridcolor", gridColor, ...
        "rotation", -axisData.View(1), ...
        "showticklabels", true, ...
        "nticks", 16, ...
        "tickfont", struct( ...
            "size", thetaAxis.FontSize, ...
            "color", getStringColor(round(255*thetaAxis.Color)), ...
            "family", matlab2plotlyfont(thetaAxis.FontName) ...
        ), ...
        "title", struct( ...
            "text", thetaLabel.String, ...
            "font", struct( ...
                "size", thetaLabel.FontSize, ...
                "color", getStringColor(round(255*thetaLabel.Color)), ...
                "family", matlab2plotlyfont(thetaLabel.FontName) ...
            ) ...
        ) ...
    );
    polarAxis.radialaxis = struct( ...
        "ticklen", 0, ...
        "range", [0,  tickValues(end)], ...
        "showline", false, ...
        "angle", 80, ...
        "tickangle", 80, ...
        "gridwidth", gridWidth, ...
        "gridcolor", gridColor, ...
        "showticklabels", true, ...
        "tickvals", tickValues, ...
        "tickfont", struct( ...
            "size", rAxis.FontSize, ...
            "color", getStringColor(round(255*rAxis.Color)), ...
            "family", matlab2plotlyfont(rAxis.FontName) ...
        ), ...
        "title", struct( ...
            "text", rLabel.String, ...
            "font", struct( ...
                "size", rLabel.FontSize, ...
                "color", getStringColor(round(255*rLabel.Color)), ...
                "family", matlab2plotlyfont(rLabel.FontName) ...
            ) ...
        ) ...
    );
end
