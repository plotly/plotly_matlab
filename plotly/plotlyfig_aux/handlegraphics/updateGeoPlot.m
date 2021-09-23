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
    obj.data{geoIndex}.geo = sprintf('geo%d', xsource+1);

    %-------------------------------------------------------------------------%

    %-set scattergeo type-%
    obj.data{geoIndex}.type = 'scattergeo';

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

    %-set marker field-%
    obj.data{geoIndex}.marker = marker;

    if strcmpi(geoData.Marker, 'none')
        obj.data{geoIndex}.mode = 'lines';
    end

    %-------------------------------------------------------------------------%

    %-set line field-%
    obj.data{geoIndex}.line = linee;

    %-------------------------------------------------------------------------%
end