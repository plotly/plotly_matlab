function updateGeobubble(obj,geoIndex)
    %-INITIALIZATIONS-%

    axIndex = obj.getAxisIndex(obj.State.Plot(geoIndex).AssociatedAxis);
    geoData = obj.State.Plot(geoIndex).Handle;
    xSource = findSourceAxis(obj,axIndex);

    %-get trace data-%
    bubbleRange = geoData.BubbleWidthRange;
    allLats = geoData.LatitudeData;
    allLons = geoData.LongitudeData;
    allSizes = rescale(geoData.SizeData, bubbleRange(1), bubbleRange(2));
    colorMap = geoData.BubbleColorList;
    nColors = size(colorMap, 1);

    if ~isempty(geoData.ColorData)
        allNames = geoData.ColorData;

        [groupNames, ~, allNamesIdx] = unique(allNames);
        nGroups = length(groupNames);
        byGroups = true;

        for g=1:nGroups
            idx = g == allNamesIdx;

            group{g} = char(groupNames(g));
            lat{g} = allLats(idx);
            lon{g} = allLons(idx);
            sData{g} = allSizes(idx);

            if length(lat{g}) < 2
                lat{g} = [allLats(idx); NaN; NaN];
                lon{g} = [allLons(idx); NaN; NaN];
                sData{g} = [allSizes(idx); NaN; NaN];
            end
        end
    else
        lat{1} = allLats;
        lon{1} = allLons;
        sData{1} = allSizes;
        nGroups = 1;
        byGroups = false;
    end

    %=====================================================================%
    %
    %-SET TRACES-%
    %
    %=====================================================================%

    for g = 1:nGroups
        %-get current trace index-%
        p = geoIndex;

        if g > 1
            obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
            p = obj.PlotOptions.nPlots;
        end

        %-set current trace-%
        if strcmpi(obj.PlotOptions.geoRenderType, 'geo')
            obj.data{p}.type = 'scattergeo';
            obj.data{p}.geo = sprintf('geo%d', xSource+1);

        elseif strcmpi(obj.PlotOptions.geoRenderType, 'mapbox')
            obj.data{p}.type = 'scattermapbox';
            obj.data{p}.subplot = sprintf('mapbox%d', xSource+1);
        end

        obj.data{p}.mode = 'markers';

        %-set current trace data-%
        obj.data{p}.lat = lat{g};
        obj.data{p}.lon = lon{g};

        %-set trace marker-%
        marker = struct();
        marker.size = sData{g}*1.25;
        marker.color = getStringColor(round(255*colorMap(mod(g-1, nColors)+1, :)));
        marker.line.color = "rgb(255, 255, 255)";

        obj.data{p}.marker = marker;

        %-legend-%
        if byGroups
            obj.data{p}.name = group{g};
            obj.data{p}.legendgroup = obj.data{p}.name;
            obj.data{p}.showlegend = true;
        end
    end

    %=====================================================================%
    %
    %-UPDATE GEO AXES-%
    %
    %=====================================================================%

    %-set domain plot-%
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
        geoaxes.lataxis.range = geoData.LatitudeLimits;

        if strcmpi(geoData.GridVisible, 'on')
            geoaxes.lataxis.showgrid = true;
            geoaxes.lataxis.gridwidth = 0.5;
            geoaxes.lataxis.gridcolor = 'rgba(38.250000,38.250000,38.250000,0.150000)';
        end
    end

    %-setting longitude axis-%
    if strcmpi(obj.PlotOptions.geoRenderType, 'geo')
        geoaxes.lonaxis.range = geoData.LongitudeLimits;

        if strcmpi(geoData.GridVisible, 'on')
            geoaxes.lonaxis.showgrid = true;
            geoaxes.lonaxis.gridwidth = 0.5;
            geoaxes.lonaxis.gridcolor = 'rgba(38.250000,38.250000,38.250000,0.150000)';
        end
    end

    %-set map center-%
    geoaxes.center.lat = geoData.MapCenter(1);
    geoaxes.center.lon = geoData.MapCenter(2);

    %-set better resolution-%
    if strcmpi(obj.PlotOptions.geoRenderType, 'geo')
        geo.resolution = '50';
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

    %-set geo geoaxes to layout-%
    if strcmpi(obj.PlotOptions.geoRenderType, 'geo')
        obj.layout.(sprintf('geo%d', xSource+1)) = geoaxes;
    elseif strcmpi(obj.PlotOptions.geoRenderType, 'mapbox')
        obj.layout.(sprintf('mapbox%d', xSource+1)) = geoaxes;
    end

    %-remove any annotation text-%
    istitle = length(geoData.Title) > 0;
    obj.layout.annotations{1}.text = ' ';
    obj.layout.annotations{1}.showarrow = false;

    %-layout title-%
    if istitle
      obj.layout.annotations{1}.text = sprintf('<b>%s</b>', geoData.Title);
      obj.layout.annotations{1}.xref = 'paper';
      obj.layout.annotations{1}.yref = 'paper';
      obj.layout.annotations{1}.yanchor = 'top';
      obj.layout.annotations{1}.xanchor = 'middle';
      obj.layout.annotations{1}.x = mean(geoaxes.domain.x);
      obj.layout.annotations{1}.y = 0.96;
      obj.layout.annotations{1}.font.color = 'black';
      obj.layout.annotations{1}.font.family = matlab2plotlyfont(geoData.FontName);
      obj.layout.annotations{1}.font.size = 1.5*geoData.FontSize;
    end

    %-setting legend-%
    if byGroups
        obj.layout.showlegend = true;
        obj.layout.legend.borderwidth = 1;
        obj.layout.legend.bordercolor = 'rgba(0,0,0,0.2)';
        obj.layout.legend.font.family = matlab2plotlyfont(geoData.FontName);
        obj.layout.legend.font.size = 1.0*geoData.FontSize;

        if length(geoData.ColorLegendTitle) > 0
            obj.layout.legend.title.text = sprintf('<b>%s</b>', geoData.ColorLegendTitle);
            obj.layout.legend.title.side = 'top';
            obj.layout.legend.title.font.family = matlab2plotlyfont(geoData.FontName);
            obj.layout.legend.title.font.size = 1.2*geoData.SizeLegendTitle;
            obj.layout.legend.title.font.color = 'black';
        end

        if strcmpi(obj.PlotOptions.geoRenderType, 'geo')
            obj.layout.legend.x = geoaxes.domain.x(end)*0.975;
            obj.layout.legend.y = geoaxes.domain.y(end)*1.001;
        elseif strcmpi(obj.PlotOptions.geoRenderType, 'mapbox')
            obj.layout.legend.x = geoaxes.domain.x(end)*1.005;
            obj.layout.legend.y = geoaxes.domain.y(end)*1.0005;
        end

        obj.layout.legend.xanchor = 'left';
        obj.layout.legend.yanchor = 'top';
        obj.layout.legend.itemsizing = 'constant';
        obj.layout.legend.itemwidth = 30;
        obj.layout.legend.tracegroupgap = 0.01;
        obj.layout.legend.traceorder = 'normal';
        obj.layout.legend.valign = 'middle';
    end
end
