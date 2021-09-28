function updateGeoPlot(obj,geoIndex)

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(geoIndex).AssociatedAxis);

    %-GET STRUCTURES-%
    geoData = get(obj.State.Plot(geoIndex).Handle);
    axisData = geoData.Parent;
    figureData = get(obj.State.Figure.Handle);

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %-ASSOCIATE GEO-AXES LAYOUT-%
    if strcmpi(obj.PlotOptions.geoRenderType, 'geo')
        obj.data{geoIndex}.geo = sprintf('geo%d', xsource+1);
    elseif strcmpi(obj.PlotOptions.geoRenderType, 'mapbox')
        obj.data{geoIndex}.subplot = sprintf('mapbox%d', xsource+1);
    end

    %-------------------------------------------------------------------------%

    %-set scattergeo type-%
    if strcmpi(obj.PlotOptions.geoRenderType, 'geo')
        obj.data{geoIndex}.type = 'scattergeo';

    %-set scattermapbox type-%
    elseif strcmpi(obj.PlotOptions.geoRenderType, 'mapbox')
        obj.data{geoIndex}.type = 'scattermapbox';
    end

    %-------------------------------------------------------------------------%

    %-set scattergeo mode-%
    obj.data{geoIndex}.mode = 'lines+markers';

    %-------------------------------------------------------------------------%

    %-set plot data-%    
    obj.data{geoIndex}.lat = geoData.LatitudeData;
    obj.data{geoIndex}.lon = geoData.LongitudeData;

    %-------------------------------------------------------------------------%

    %-get marker setting-%
    [marker, linee] = extractGeoLinePlusMarker(geoData, axisData);

    %-------------------------------------------------------------------------%

    %-corrections-%
    if strcmpi(geoData.Marker, 'none')
        obj.data{geoIndex}.mode = 'lines';
    else
        if strcmpi(obj.PlotOptions.geoRenderType, 'mapbox')
            marker.allowoverlap = true;
            marker = rmfield(marker, 'symbol');

            if strcmp(marker.color, 'rgba(0,0,0,0)') && isfield(marker, 'line')
                marker.color = marker.line.color;
            end
        end
    end

    %-------------------------------------------------------------------------%

    %-set marker field-%
    obj.data{geoIndex}.marker = marker;

    %-------------------------------------------------------------------------%

    %-set line field-%
    obj.data{geoIndex}.line = linee;

    %-------------------------------------------------------------------------%
end