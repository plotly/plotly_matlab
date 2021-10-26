function updateScatter(obj,plotIndex)

    %-------------------------------------------------------------------------%

    %-INITIALIZATIONS-%
    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    [xSource, ySource] = findSourceAxis(obj,axIndex);
    plotData = get(obj.State.Plot(plotIndex).Handle);

    %-check is 3D scatter-%
    try
        isScatter3D = isfield(plotData,'ZData');
        isScatter3D = isScatter3D & ~isempty(plotData.ZData);
    catch
        isScatter3D = false;
    end

    %-------------------------------------------------------------------------%

    %-set trace-%
    if ~isScatter3D
        obj.data{plotIndex}.type = 'scatter';    
        obj.data{plotIndex}.xaxis = sprintf('x%d', xSource);
        obj.data{plotIndex}.yaxis = sprintf('y%d', ySource);
    else
        obj.data{plotIndex}.type = 'scatter3d';
        obj.data{plotIndex}.scene = sprintf('scene%d', xSource);

        updateScene(obj, plotIndex);
    end

    obj.data{plotIndex}.mode = 'markers';
    obj.data{plotIndex}.visible = strcmp(plotData.Visible,'on');
    obj.data{plotIndex}.name = plotData.DisplayName;

    %-------------------------------------------------------------------------%
        
    %-set trace data-%
    obj.data{plotIndex}.x = plotData.XData;
    obj.data{plotIndex}.y = plotData.YData;

    if isScatter3D
        obj.data{plotIndex}.z = plotData.ZData;
    end
        
    %-------------------------------------------------------------------------%
    
    %-set trace marker-%
    obj.data{plotIndex}.marker = extractScatterMarker(plotData);

    if isScatter3D
        markerSize = obj.data{plotIndex}.marker.size;
        obj.data{plotIndex}.marker.size = 2*markerSize;
    end
        
    %-set trace legend-%
    if isScatter3D
        obj.data{plotIndex}.showlegend = getShowLegend(plotData);
    end

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

