function updateLineseries(obj, plotIndex)

    %-------------------------------------------------------------------------%

    %-INITIALIZATIONS-%

    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    plotData = get(obj.State.Plot(plotIndex).Handle);

    %-check for multiple axes-%
    try
        for yax = 1:2
            yAxisColor = plotData.Parent.YAxis(yax).Color;
            yaxIndex(yax) = sum(yAxisColor == plotData.Color);
        end

        [~, yaxIndex] = max(yaxIndex);
        [xSource, ySource] = findSourceAxis(obj, axIndex, yaxIndex);

    catch
        [xSource, ySource] = findSourceAxis(obj,axIndex);
    end

    %-check if polar plot-%
    treatAs = lower(obj.PlotOptions.TreatAs);
    isPolar = ismember('compass', treatAs) || ismember('ezpolar', treatAs);

    %-check is 3D plot-%
    try
        isPlot3D = isfield(plotData,'ZData');
        isPlot3D = isPlot3D & ~isempty(plotData.ZData);
    catch
        isPlot3D = false;
    end

    %-get trace data-%
    xData = date2NumData(plotData.XData);
    yData = date2NumData(plotData.YData);

    if isPolar
        rData = sqrt(xData.^2 + yData.^2);
        thetaData = atan2(xData, yData);
        thetaData = -(rad2deg(thetaData) - 90);
    end

    if isPlot3D
        zData = date2NumData(plotData.ZData);
    end

    %-------------------------------------------------------------------------%

    %-set trace-%
    if isPolar
        obj.data{plotIndex}.type = 'scatterpolar';
        updateDefaultPolaraxes(obj, plotIndex)
        obj.data{plotIndex}.subplot = sprintf('polar%d', xSource+1);

    elseif ~isPlot3D
        obj.data{plotIndex}.type = 'scatter';
        obj.data{plotIndex}.xaxis = sprintf('x%d', xSource);
        obj.data{plotIndex}.yaxis = sprintf('y%d', ySource);
    else
        obj.data{plotIndex}.type = 'scatter3d';
        obj.data{plotIndex}.scene = sprintf('scene%d', xSource);

        updateScene(obj, plotIndex);
    end

    obj.data{plotIndex}.visible = strcmp(plotData.Visible,'on');
    obj.data{plotIndex}.name = plotData.DisplayName;
    obj.data{plotIndex}.mode = getScatterMode(plotData);

    %-------------------------------------------------------------------------%

    %-set trace data-%
    if isPolar
        obj.data{plotIndex}.r = rData;
        obj.data{plotIndex}.theta = thetaData;

    else
        obj.data{plotIndex}.x = xData;
        obj.data{plotIndex}.y = yData;

        if isPlot3D
            obj.data{plotIndex}.z = zData;
            obj.PlotOptions.is3d = true;
        end
    end

    %-------------------------------------------------------------------------%

    %-set trace line-%
    obj.data{plotIndex}.line = extractLineLine(plotData);
    if isPolar
        obj.data{plotIndex}.line.width = obj.data{plotIndex}.line.width * 1.5;
    end

    %-set trace marker-%
    obj.data{plotIndex}.marker = extractLineMarker(plotData);

    %-set trace legend-%
    obj.data{plotIndex}.showlegend = getShowLegend(plotData);

    %-------------------------------------------------------------------------%
end

function updateScene(obj, dataIndex)

    %-------------------------------------------------------------------------%

    %-INITIALIZATIONS-%
    axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);
    plotData = get(obj.State.Plot(dataIndex).Handle);
    axisData = get(plotData.Parent);
    [xSource, ~] = findSourceAxis(obj, axIndex);
    scene = eval( sprintf('obj.layout.scene%d', xSource) );

    cameraTarget = axisData.CameraTarget;
    position = axisData.Position;
    aspectRatio = axisData.PlotBoxAspectRatio;
    cameraPosition = axisData.CameraPosition;
    dataAspectRatio = axisData.DataAspectRatio;
    cameraUpVector = axisData.CameraUpVector;
    cameraEye = cameraPosition./dataAspectRatio;

    cameraOffset = 0.5;
    normFac = abs(min(cameraEye));
    normFac = normFac / (max(aspectRatio)/min(aspectRatio) + cameraOffset);

    %-------------------------------------------------------------------------%

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

    %-------------------------------------------------------------------------%

    %-scene axis configuration-%
    scene.xaxis.range = date2NumData(axisData.XLim);
    scene.yaxis.range = date2NumData(axisData.YLim);
    scene.zaxis.range = date2NumData(axisData.ZLim);

    scene.xaxis.zeroline = false;
    scene.yaxis.zeroline = false;
    scene.zaxis.zeroline = false;

    scene.xaxis.showline = true;
    scene.yaxis.showline = true;
    scene.zaxis.showline = true;

    scene.xaxis.ticklabelposition = 'outside';
    scene.yaxis.ticklabelposition = 'outside';
    scene.zaxis.ticklabelposition = 'outside';

    scene.xaxis.title = axisData.XLabel.String;
    scene.yaxis.title = axisData.YLabel.String;
    scene.zaxis.title = axisData.ZLabel.String;

    scene.xaxis.titlefont.color = 'rgba(0,0,0,1)';
    scene.yaxis.titlefont.color = 'rgba(0,0,0,1)';
    scene.zaxis.titlefont.color = 'rgba(0,0,0,1)';
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

    scene.xaxis.tickcolor = 'rgba(0,0,0,1)';
    scene.yaxis.tickcolor = 'rgba(0,0,0,1)';
    scene.zaxis.tickcolor = 'rgba(0,0,0,1)';
    scene.xaxis.tickfont.size = axisData.FontSize;
    scene.yaxis.tickfont.size = axisData.FontSize;
    scene.zaxis.tickfont.size = axisData.FontSize;
    scene.xaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);
    scene.yaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);
    scene.zaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);

    %-grid-%
    if strcmp(axisData.XGrid, 'off'), scene.xaxis.showgrid = false; end
    if strcmp(axisData.YGrid, 'off'), scene.yaxis.showgrid = false; end
    if strcmp(axisData.ZGrid, 'off'), scene.zaxis.showgrid = false; end

    %-------------------------------------------------------------------------%

    %-SET SCENE TO LAYOUT-%
    obj.layout = setfield(obj.layout, sprintf('scene%d', xSource), scene);

    %-------------------------------------------------------------------------%
end

function updateDefaultPolaraxes(obj, plotIndex)

    %-------------------------------------------------------------------------%

    %-INITIALIZATIONS-%
    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    [xSource, ysource] = findSourceAxis(obj, axIndex);
    plotData = get(obj.State.Plot(plotIndex).Handle);
    axisData = get(plotData.Parent);

    thetaAxis = axisData.XAxis;
    rAxis = axisData.YAxis;

    %-------------------------------------------------------------------------%

    %-set domain plot-%
    xo = axisData.Position(1);
    yo = axisData.Position(2);
    w = axisData.Position(3);
    h = axisData.Position(4);

    polarAxis.domain.x = min([xo xo + w], 1);
    polarAxis.domain.y = min([yo yo + h], 1);

    tickValues = rAxis.TickValues;
    tickValues = tickValues(find(tickValues==0) + 1 : end);

    %-------------------------------------------------------------------------%
        
    %-SET ANGULAR AXIS-%

    gridColor = getStringColor(255*axisData.GridColor, axisData.GridAlpha);
    gridWidth = axisData.LineWidth;

    polarAxis.angularaxis.ticklen = 0;
    polarAxis.angularaxis.autorange = true;
    polarAxis.angularaxis.linecolor = gridColor;
    polarAxis.angularaxis.gridwidth = gridWidth;
    polarAxis.angularaxis.gridcolor = gridColor;
    polarAxis.angularaxis.rotation = -axisData.View(1);

    %-axis tick-%
    polarAxis.angularaxis.showticklabels = true;
    polarAxis.angularaxis.nticks = 16;
    polarAxis.angularaxis.tickfont.size = thetaAxis.FontSize;
    polarAxis.angularaxis.tickfont.color = getStringColor(...
        255*thetaAxis.Color);
    polarAxis.angularaxis.tickfont.family = matlab2plotlyfont(...
        thetaAxis.FontName);

    %-axis label-%
    thetaLabel = thetaAxis.Label;

    polarAxis.angularaxis.title.text = thetaLabel.String;
    polarAxis.radialaxis.title.font.size = thetaLabel.FontSize;
    polarAxis.radialaxis.title.font.color = getStringColor(...
        255*thetaLabel.Color);
    polarAxis.radialaxis.title.font.family = matlab2plotlyfont(...
        thetaLabel.FontName);

    %-------------------------------------------------------------------------%
        
    %-SET RADIAL AXIS-%

    polarAxis.radialaxis.ticklen = 0;
    polarAxis.radialaxis.range = [0,  tickValues(end)];
    polarAxis.radialaxis.showline = false;

    polarAxis.radialaxis.angle = 80;
    polarAxis.radialaxis.tickangle = 80;

    polarAxis.radialaxis.gridwidth = gridWidth;
    polarAxis.radialaxis.gridcolor = gridColor;

    %-axis tick-%
    polarAxis.radialaxis.showticklabels = true;
    polarAxis.radialaxis.tickvals = tickValues;
    polarAxis.radialaxis.tickfont.size = rAxis.FontSize;
    polarAxis.radialaxis.tickfont.color = getStringColor(255*rAxis.Color);
    polarAxis.radialaxis.tickfont.family = matlab2plotlyfont(...
        rAxis.FontName);

    %-axis label-%
    rLabel = rAxis.Label;

    polarAxis.radialaxis.title.text = rLabel.String;
    polarAxis.radialaxis.title.font.size = rLabel.FontSize;
    polarAxis.radialaxis.title.font.color = getStringColor(255*rLabel.Color);
    polarAxis.radialaxis.title.font.family = matlab2plotlyfont(...
        rLabel.FontName);

    %-------------------------------------------------------------------------%

    %-set Polar Axes to layout-%
    obj.layout = setfield(obj.layout, sprintf('polar%d', xSource+1), ...
        polarAxis);

    %-------------------------------------------------------------------------%
end