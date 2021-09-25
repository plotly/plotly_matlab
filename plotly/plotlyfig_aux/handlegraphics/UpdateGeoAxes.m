function UpdateGeoAxes(obj, geoIndex)

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(geoIndex).AssociatedAxis);

    %-GET DATA STRUCTURE- %
    geoData = get(obj.State.Plot(geoIndex).Handle);

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %-------------------------------------------------------------------------%

    %-set domain geo plot-%
    xo = geoData.Position(1);
    yo = geoData.Position(2);
    w = geoData.Position(3);
    h = geoData.Position(4);

    geo.domain.x = min([xo xo + w],1);
    geo.domain.y = min([yo yo + h],1);

    %-------------------------------------------------------------------------%

    %-setting projection-%
    geo.projection.type = 'mercator';

    %-------------------------------------------------------------------------%

    %-setting basemap-%
    geo.framecolor = 'rgb(120,120,120)';

    if strcmpi(geoData.Basemap, 'streets-light')    
        geo.oceancolor = 'rgba(20,220,220,1)';
        geo.landcolor = 'rgba(20,220,220,0.2)';
    elseif strcmpi(geoData.Basemap, 'colorterrain')
        geo.oceancolor = 'rgba(118,165,225,0.6)';
        geo.landcolor = 'rgba(190,180,170,1)';
        geo.showcountries = true;
        geo.showlakes = true;
    end

    geo.showocean = true;
    geo.showcoastlines = false;
    geo.showland = true;

    %-------------------------------------------------------------------------%

    %-setting latitude axis
    latTick = geoData.LatitudeAxis.TickValues;

    geo.lataxis.range = geoData.LatitudeLimits;
    geo.lataxis.tick0 = latTick(1);
    geo.lataxis.dtick = mean(diff(latTick));

    if strcmpi(geoData.Grid, 'on')
        geo.lataxis.showgrid = true;
        geo.lataxis.gridwidth = geoData.LineWidth;
        geo.lataxis.gridcolor = sprintf('rgba(%f,%f,%f,%f)', 255*geoData.GridColor, geoData.GridAlpha);
    end

    %-------------------------------------------------------------------------%
    
    %-setting longitude axis
    lonTick = geoData.LongitudeAxis.TickValues;

    geo.lonaxis.range = geoData.LongitudeLimits;
    geo.lonaxis.tick0 = lonTick(1);
    geo.lonaxis.dtick = mean(diff(lonTick));

    if strcmpi(geoData.Grid, 'on')
        geo.lonaxis.showgrid = true;
        geo.lonaxis.gridwidth = geoData.LineWidth;
        geo.lonaxis.gridcolor = sprintf('rgba(%f,%f,%f,%f)', 255*geoData.GridColor, geoData.GridAlpha);
    end

    %-------------------------------------------------------------------------%

    %-set geo axes to layout-%

    obj.layout = setfield(obj.layout, sprintf('geo%d', xsource+1), geo);

    %-------------------------------------------------------------------------%
end