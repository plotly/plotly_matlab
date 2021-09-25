function updateGeobubble(obj,geoIndex)

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(geoIndex).AssociatedAxis);

    %-GET STRUCTURES-%
    geoData = get(obj.State.Plot(geoIndex).Handle);

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %-----------------------------------------------------------------------------%

    %-PASE DATA-%
    bubbleRange = geoData.BubbleWidthRange;
    allLats = geoData.LatitudeData;
    allLons = geoData.LongitudeData;
    allSizes = rescale(geoData.SizeData, bubbleRange(1), bubbleRange(2));

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

    %-----------------------------------------------------------------------------%

    %=============================================================================%
    %
    %-SETTING GEOBBUBLE PLOT-%
    %
    %=============================================================================%

    for g = 1:nGroups

        %-------------------------------------------------------------------------%

        %-get current trace index-%
        p = geoIndex;

        if g > 1
            obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
            p = obj.PlotOptions.nPlots;
        end

        %-------------------------------------------------------------------------%

        %-set scattergeo type-%
        obj.data{p}.type = 'scattergeo';

        %-------------------------------------------------------------------------%

        %-set scattergeo mode-%
        obj.data{p}.mode = 'markers';

        %-------------------------------------------------------------------------%

        %-set plot data-%
        obj.data{p}.lat = lat{g};
        obj.data{p}.lon = lon{g};

        %-------------------------------------------------------------------------%

        %-get marker setting-%
        marker = struct();
        marker.size = sData{g}*1.25;
        marker.color = sprintf('rgb(%f,%f,%f)', 255*geoData.BubbleColorList(g ,:));
        marker.line.color = 'rgb(255, 255, 255)';

        %-------------------------------------------------------------------------%

        %-set marker field-%
        obj.data{p}.marker = marker;   

        %-------------------------------------------------------------------------%

        %-ASSOCIATE GEO-AXES LAYOUT-%
        obj.data{p}.geo = sprintf('geo%d', xsource+1);

        %-------------------------------------------------------------------------%

        %-legend-%
        if byGroups
            obj.data{p}.name = group{g};
            obj.data{p}.legendgroup = obj.data{p}.name;
            obj.data{p}.showlegend = true;
        end

        %-------------------------------------------------------------------------%

    end

    %=============================================================================%
    %
    %-SETTING LAYOUT-%
    %
    %=============================================================================%

    %-set domain geo plot-%
    xo = geoData.Position(1);
    yo = geoData.Position(2);
    w = geoData.Position(3);
    h = geoData.Position(4);

    geo.domain.x = min([xo xo + w],1);
    geo.domain.y = min([yo yo + h],1);

    %-----------------------------------------------------------------------------%

    %-setting projection-%
    geo.projection.type = 'mercator';

    %-----------------------------------------------------------------------------%

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

    %-----------------------------------------------------------------------------%

    %-setting latitude axis-%
    geo.lataxis.range = geoData.LatitudeLimits;

    if strcmpi(geoData.GridVisible, 'on')
        geo.lataxis.showgrid = true;
        geo.lataxis.gridwidth = 0.5;
        geo.lataxis.gridcolor = 'rgba(38.250000,38.250000,38.250000,0.150000)';
    end

    %-----------------------------------------------------------------------------%
    
    %-setting longitude axis-%
    geo.lonaxis.range = geoData.LongitudeLimits;

    if strcmpi(geoData.GridVisible, 'on')
        geo.lonaxis.showgrid = true;
        geo.lonaxis.gridwidth = 0.5;
        geo.lonaxis.gridcolor = 'rgba(38.250000,38.250000,38.250000,0.150000)';
    end

    %-----------------------------------------------------------------------------%
    
    %-set map center-%
    geo.center.lat = geoData.MapCenter(1);
    geo.center.lon = geoData.MapCenter(2);

    %-----------------------------------------------------------------------------%
    
    %-set better resolution-%
    geo.resolution = '50';

    %-----------------------------------------------------------------------------%

    %-set geo axes to layout-%
    obj.layout = setfield(obj.layout, sprintf('geo%d', xsource+1), geo);

    %-----------------------------------------------------------------------------%

    %-remove any annotation text-%
    istitle = length(geoData.Title) > 0;
    obj.layout.annotations{1}.text = ' ';
    obj.layout.annotations{1}.showarrow = false;

    %-----------------------------------------------------------------------------%

    %-layout title-%
    if istitle
      obj.layout.annotations{1}.text = sprintf('<b>%s</b>', geoData.Title);
      obj.layout.annotations{1}.xref = 'paper';
      obj.layout.annotations{1}.yref = 'paper';
      obj.layout.annotations{1}.yanchor = 'top';
      obj.layout.annotations{1}.xanchor = 'middle';
      obj.layout.annotations{1}.x = mean(geo.domain.x);
      obj.layout.annotations{1}.y = 0.96;
      obj.layout.annotations{1}.font.color = 'black';
      obj.layout.annotations{1}.font.family = matlab2plotlyfont(geoData.FontName);
      obj.layout.annotations{1}.font.size = 1.5*geoData.FontSize;
    end

    %-----------------------------------------------------------------------------%    

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

        obj.layout.legend.x = geo.domain.x(end) * 0.980;
        obj.layout.legend.y = geo.domain.y(end) * 1.001;
        obj.layout.legend.xanchor = 'left';
        obj.layout.legend.yanchor = 'top';
        obj.layout.legend.itemsizing = 'constant';
        obj.layout.legend.itemwidth = 30;
        obj.layout.legend.tracegroupgap = 0.01;
        obj.layout.legend.traceorder = 'normal';
        obj.layout.legend.valign = 'middle';
    end

    %-----------------------------------------------------------------------------%
end