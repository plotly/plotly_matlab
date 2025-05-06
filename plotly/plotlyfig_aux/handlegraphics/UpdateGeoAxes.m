function UpdateGeoAxes(obj, geoIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(geoIndex).AssociatedAxis);

    %-GET DATA STRUCTURE- %
    geoData = obj.State.Plot(geoIndex).Handle;

    %-CHECK FOR MULTIPLE AXES-%
    xsource = findSourceAxis(obj,axIndex);

    %-set domain geo plot-%
    xo = geoData.Position(1);
    yo = geoData.Position(2);
    w = geoData.Position(3);
    h = geoData.Position(4);

    geoaxes.domain.x = min([xo xo + w],1);
    geoaxes.domain.y = min([yo yo + h],1);

    %-setting projection-%
    if strcmpi(obj.PlotOptions.geoRenderType, 'geo')
        geoaxes.projection.type = 'mercator';
    end

    %-setting basemap-%
    if strcmpi(obj.PlotOptions.geoRenderType, 'geo')
        geoaxes.framecolor = 'rgb(120,120,120)';
        if strcmpi(geoData.Basemap, 'streets-light')
            geoaxes.oceancolor = 'rgba(215,215,220,1)';
            geoaxes.landcolor = 'rgba(220,220,220,0.4)';
        elseif strcmpi(geoData.Basemap, 'colorterrain')
            geoaxes.oceancolor = 'rgba(118,165,225,0.6)';
            geoaxes.landcolor = 'rgba(190,180,170,1)';
            geoaxes.showcountries = true;
            geoaxes.showlakes = true;
        end
        geoaxes.showocean = true;
        geoaxes.showcoastlines = false;
        geoaxes.showland = true;
    end

    %-setting latitude axis-%
    if strcmpi(obj.PlotOptions.geoRenderType, 'geo')
        latTick = geoData.LatitudeAxis.TickValues;

        geoaxes.lataxis.range = geoData.LatitudeLimits;
        geoaxes.lataxis.tick0 = latTick(1);
        geoaxes.lataxis.dtick = mean(diff(latTick));

        if strcmpi(geoData.Grid, 'on')
            geoaxes.lataxis.showgrid = true;
            geoaxes.lataxis.gridwidth = geoData.LineWidth;
            geoaxes.lataxis.gridcolor = getStringColor( ...
                    round(255*geoData.GridColor), geoData.GridAlpha);
        end
    end

    %-setting longitude axis-%
    if strcmpi(obj.PlotOptions.geoRenderType, 'geo')
        lonTick = geoData.LongitudeAxis.TickValues;

        geoaxes.lonaxis.range = geoData.LongitudeLimits;
        geoaxes.lonaxis.tick0 = lonTick(1);
        geoaxes.lonaxis.dtick = mean(diff(lonTick));

        if strcmpi(geoData.Grid, 'on')
            geoaxes.lonaxis.showgrid = true;
            geoaxes.lonaxis.gridwidth = geoData.LineWidth;
            geoaxes.lonaxis.gridcolor = getStringColor( ...
                    round(255*geoData.GridColor), geoData.GridAlpha);
        end
    end

    %-set map center-%
    geoaxes.center.lat = geoData.MapCenter(1);
    geoaxes.center.lon = geoData.MapCenter(2);

    %-set better resolution-%
    if strcmpi(obj.PlotOptions.geoRenderType, 'geo')
        geoaxes.resolution = '50';
    end

    %-set mapbox style-%
    if strcmpi(obj.PlotOptions.geoRenderType, 'mapbox')
        geoaxes.zoom = geoData.ZoomLevel - 1.4;
        if strcmpi(geoData.Basemap, 'streets-light')
            geoaxes.style = 'carto-positron';
        elseif strcmpi(geoData.Basemap, 'colorterrain')
            geoaxes.style = 'stamen-terrain';
        end
    end

    %-TEXT SETTINGS-%
    isText = false;
    child = geoData.Children;
    t = 1;

    for n=1:length(child)
        if strcmpi(child(n).Type, 'text')
            isText = true;
            texts{t} = child(t).String;
            lats(t) = child(t).Position(1);
            lons(t) = child(t).Position(2);
            sizes(t) = child(t).FontSize;
            families{t} = matlab2plotlyfont(child(t).FontName);
            colors{t} = getStringColor(round(255*child(t).Color));

            if strcmpi(child(t).HorizontalAlignment, 'left')
                pos{t} = 'right';
            elseif strcmpi(child(t).HorizontalAlignment, 'right')
                pos{t} = 'left';
            else
                pos{t} = child(t).HorizontalAlignment;
            end
            t = t + 1;
        end
    end

    if isText
        if strcmpi(obj.PlotOptions.geoRenderType, 'geo')
            obj.data{geoIndex}.type = 'scattergeo';
        elseif strcmpi(obj.PlotOptions.geoRenderType, 'mapbox')
            obj.data{geoIndex}.type = 'scattermapbox';
        end

        obj.data{geoIndex}.mode = 'text';
        obj.data{geoIndex}.text = texts;
        obj.data{geoIndex}.lat = lats;
        obj.data{geoIndex}.lon = lons;

        obj.data{geoIndex}.textfont.size = sizes;
        obj.data{geoIndex}.textfont.color = colors;
        obj.data{geoIndex}.textfont.family = families;
        obj.data{geoIndex}.textposition = pos;

        if strcmpi(obj.PlotOptions.geoRenderType, 'geo')
            obj.data{geoIndex}.geo = obj.data{geoIndex-1}.geo;
        elseif strcmpi(obj.PlotOptions.geoRenderType, 'mapbox')
            obj.data{geoIndex}.subplot = obj.data{geoIndex-1}.subplot;
        end
    end

    %-set geo axes to layout-%
    if strcmpi(obj.PlotOptions.geoRenderType, 'geo')
        obj.layout.(sprintf('geo%d', xsource+1)) = geoaxes;
    elseif strcmpi(obj.PlotOptions.geoRenderType, 'mapbox')
        obj.layout.(sprintf('mapbox%d', xsource+1)) = geoaxes;
    end
end
