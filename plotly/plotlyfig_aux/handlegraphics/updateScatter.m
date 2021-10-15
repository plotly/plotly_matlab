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
        obj.data{scatterIndex}.marker.size = markerSize * 0.15;
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

