function updateScatter(obj,scatterIndex)

    %-------------------------------------------------------------------------%

    %-INITIALIZATIONS-%
    axIndex = obj.getAxisIndex(obj.State.Plot(scatterIndex).AssociatedAxis);
    [xSource, ySource] = findSourceAxis(obj,axIndex);
    scatterData = get(obj.State.Plot(scatterIndex).Handle);

    try
        isScatter3D = isfield(scatterData,'ZData');
        isScatter3D = isScatter3D & ~isempty(scatterData.ZData);
    catch
        isScatter3D = false;
    end
    
    %-------------------------------------------------------------------------%

    %-set trace-%
    if ~isScatter3D
        obj.data{scatterIndex}.type = 'scatter';    
        obj.data{scatterIndex}.xaxis = sprintf('x%d', xSource);
        obj.data{scatterIndex}.yaxis = sprintf('y%d', ySource);
    else
        obj.data{scatterIndex}.type = 'scatter3d';
        obj.data{scatterIndex}.scene = sprintf('scene%d', xSource);

        updateScene(obj, scatterIndex);
    end

    obj.data{scatterIndex}.mode = 'markers';
    obj.data{scatterIndex}.visible = strcmp(scatterData.Visible,'on');
    obj.data{scatterIndex}.name = scatterData.DisplayName;

    %-------------------------------------------------------------------------%
        
    %-set plot data-%
    obj.data{scatterIndex}.x = scatterData.XData;
    obj.data{scatterIndex}.y = scatterData.YData;

    if isScatter3D
        obj.data{scatterIndex}.z = scatterData.ZData;
    end
        
    %-------------------------------------------------------------------------%
    
    %-set marker property-%
    obj.data{scatterIndex}.marker = extractScatterMarker(scatterData);
    markerSize = obj.data{scatterIndex}.marker.size;
    markerColor = obj.data{scatterIndex}.marker.color;
    markerLineColor = obj.data{scatterIndex}.marker.line.color;

    if length(markerSize) == 1
        obj.data{scatterIndex}.marker.size = markerSize * 0.11;
    end

    if length(markerColor) == 1 
        obj.data{scatterIndex}.marker.color = markerColor{1};
    end

    if length(markerLineColor) == 1 
        obj.data{scatterIndex}.marker.line.color = markerLineColor{1};
    end
    
    %-------------------------------------------------------------------------%
        
    %-set showlegend property-%
    if isScatter3D
        leg = get(scatterData.Annotation);
        legInfo = get(leg.LegendInformation);
        
        switch legInfo.IconDisplayStyle
            case 'on'
                showleg = true;
            case 'off'
                showleg = false;
        end

        obj.data{scatterIndex}.showlegend = showleg;
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
    normFac = min(cameraTarget) / max(cameraTarget);
    normFac = 1.1 * normFac * abs(min(cameraEye));

    %-------------------------------------------------------------------------%

    %-aspect ratio-%
    scene.aspectratio.x = 1.0*aspectRatio(1);
    scene.aspectratio.y = 1.0*aspectRatio(2);
    scene.aspectratio.z = 1.0*aspectRatio(3);

    %-camera eye-%
    scene.camera.eye.x = cameraEye(1) / normFac;
    scene.camera.eye.y = cameraEye(2) / normFac;
    scene.camera.eye.z = cameraEye(3) / normFac;

    %-camera up-%
    scene.camera.up.x = cameraUpVector(1); 
    scene.camera.up.y = cameraUpVector(2);
    scene.camera.up.z = cameraUpVector(3);

    %-------------------------------------------------------------------------%

    %-scene axis configuration-%
    rangeFac = 0.0;

    xRange = range(axisData.XLim);
    scene.xaxis.range(1) = axisData.XLim(1) - rangeFac * xRange;
    scene.xaxis.range(2) = axisData.XLim(2) + rangeFac * xRange;

    yRange = range(axisData.YLim);
    scene.yaxis.range(1) = axisData.YLim(1) - rangeFac * yRange;
    scene.yaxis.range(2) = axisData.YLim(2) + rangeFac * yRange;

    zRange = range(axisData.ZLim);
    scene.zaxis.range(1) = axisData.ZLim(1) - rangeFac * zRange;
    scene.zaxis.range(2) = axisData.ZLim(2) + rangeFac * zRange;

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
    scene.xaxis.tickvals = axisData.XTick;
    scene.xaxis.ticktext = axisData.XTickLabel;
    scene.yaxis.tickvals = axisData.YTick;
    scene.yaxis.ticktext = axisData.YTickLabel;
    scene.zaxis.tickvals = axisData.ZTick;
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

