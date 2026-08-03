function UpdateGeoAxes(obj, geoIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(geoIndex).AssociatedAxis);

    %-GET DATA STRUCTURE- %
    geoData = obj.State.Plot(geoIndex).Handle;

    %-CHECK FOR MULTIPLE AXES-%
    xsource = findSourceAxis(obj,axIndex);

    %-set domain geo plot-%
    geoPosition = get(geoData, 'Position');
    xo = geoPosition(1);
    yo = geoPosition(2);
    w = geoPosition(3);
    h = geoPosition(4);

    geoaxes.domain.x = min([xo xo + w],1);
    geoaxes.domain.y = min([yo yo + h],1);

    %-setting projection-%
    if strcmpi(obj.PlotOptions.geoRenderType, 'geo')
        geoaxes.projection.type = 'mercator';
    end

    %-setting basemap-%
    if strcmpi(obj.PlotOptions.geoRenderType, 'geo')
        geoaxes.framecolor = 'rgb(120,120,120)';
        if strcmpi(get(geoData, 'Basemap'), 'streets-light')
            geoaxes.oceancolor = 'rgba(215,215,220,1)';
            geoaxes.landcolor = 'rgba(220,220,220,0.4)';
        elseif strcmpi(get(geoData, 'Basemap'), 'colorterrain')
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
        latTick = get(get(geoData, 'LatitudeAxis'), 'TickValues');

        geoaxes.lataxis.range = get(geoData, 'LatitudeLimits');
        geoaxes.lataxis.tick0 = latTick(1);
        geoaxes.lataxis.dtick = mean(diff(latTick));

        if strcmpi(get(geoData, 'Grid'), 'on')
            geoaxes.lataxis.showgrid = true;
            geoaxes.lataxis.gridwidth = get(geoData, 'LineWidth');
            geoaxes.lataxis.gridcolor = getStringColor( ...
                    round(255*get(geoData, 'GridColor')), get(geoData, 'GridAlpha'));
        end
    end

    %-setting longitude axis-%
    if strcmpi(obj.PlotOptions.geoRenderType, 'geo')
        lonTick = get(get(geoData, 'LongitudeAxis'), 'TickValues');

        geoaxes.lonaxis.range = get(geoData, 'LongitudeLimits');
        geoaxes.lonaxis.tick0 = lonTick(1);
        geoaxes.lonaxis.dtick = mean(diff(lonTick));

        if strcmpi(get(geoData, 'Grid'), 'on')
            geoaxes.lonaxis.showgrid = true;
            geoaxes.lonaxis.gridwidth = get(geoData, 'LineWidth');
            geoaxes.lonaxis.gridcolor = getStringColor( ...
                    round(255*get(geoData, 'GridColor')), get(geoData, 'GridAlpha'));
        end
    end

    %-set map center-%
    tmpMapCenter = get(geoData, 'MapCenter');
    geoaxes.center.lat = tmpMapCenter(1);
    geoaxes.center.lon = tmpMapCenter(2);

    %-set better resolution-%
    if strcmpi(obj.PlotOptions.geoRenderType, 'geo')
        geoaxes.resolution = '50';
    end

    %-set mapbox style-%
    if strcmpi(obj.PlotOptions.geoRenderType, 'mapbox')
        geoaxes.zoom = get(geoData, 'ZoomLevel') - 1.4;
        if strcmpi(get(geoData, 'Basemap'), 'streets-light')
            geoaxes.style = 'carto-positron';
        elseif strcmpi(get(geoData, 'Basemap'), 'colorterrain')
            geoaxes.style = 'stamen-terrain';
        end
    end

    %-TEXT SETTINGS-%
    isText = false;
    child = get(geoData, 'Children');
    t = 1;

    for n=1:length(child)
        if strcmpi(get(child(n), 'Type'), 'text')
            isText = true;
            texts{t} = get(child(t), 'String');
            tmpPosition = get(child(t), 'Position');
            lats(t) = tmpPosition(1);
            lons(t) = tmpPosition(2);
            sizes(t) = get(child(t), 'FontSize');
            families{t} = matlab2plotlyfont(get(child(t), 'FontName'));
            colors{t} = getStringColor(round(255*get(child(t), 'Color')));

            if strcmpi(get(child(t), 'HorizontalAlignment'), 'left')
                pos{t} = 'right';
            elseif strcmpi(get(child(t), 'HorizontalAlignment'), 'right')
                pos{t} = 'left';
            else
                pos{t} = get(child(t), 'HorizontalAlignment');
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
