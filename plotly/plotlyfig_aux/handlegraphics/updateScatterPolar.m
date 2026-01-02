function updateScatterPolar(obj, plotIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);

    %-PLOT DATA STRUCTURE- %
    plotData = obj.State.Plot(plotIndex).Handle;

    %-CHECK FOR MULTIPLE AXES-%
    xsource = findSourceAxis(obj, axIndex);

    %-ASSOCIATE POLAR-AXES LAYOUT-%
    obj.data{plotIndex}.subplot = sprintf('polar%d', xsource+1);

    %-parse plot data-%
    rData = plotData.RData;
    thetaData = rad2deg(plotData.ThetaData);

    thetaData(rData<0) = mod(thetaData(rData<0)+180, 360);
    rData = abs(rData);

    %-scatterpolar trace setting-%
    obj.data{plotIndex}.type = 'scatterpolar';
    obj.data{plotIndex}.mode = 'markers';
    obj.data{plotIndex}.visible = strcmp(plotData.Visible,'on');
    obj.data{plotIndex}.name = plotData.DisplayName;

    %-set scatterpolar data-%
    obj.data{plotIndex}.r = rData;
    obj.data{plotIndex}.theta = thetaData;

    %-trace settings-%
    markerStruct = extractScatterMarker(plotData);

    obj.data{plotIndex}.marker = markerStruct;

    if isscalar(markerStruct.size)
        obj.data{plotIndex}.marker.size = markerStruct.size * 0.2;
    end

    if length(markerStruct.line.color) > 1
        obj.data{plotIndex}.marker.line.color = markerStruct.line.color{1};
    end

    %-legend setting-%
    switch plotData.Annotation.LegendInformation.IconDisplayStyle
        case "on"
            obj.data{plotIndex}.showlegend = true;
        case "off"
            obj.data{plotIndex}.showlegend = false;
    end

    %-set polar axes-%
    updatePolaraxes(obj, plotIndex);
end

%-------------------------------------------------------------------------%
%
%-SET POLAR AXIS-%
%
%-------------------------------------------------------------------------%

function updatePolaraxes(obj, plotIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);

    %-CHECK FOR MULTIPLE AXES-%
    xsource = findSourceAxis(obj, axIndex);

    %-GET DATA STRUCTURES-%
    plotData = obj.State.Plot(plotIndex).Handle;
    axisData = plotData.Parent;
    thetaAxis = axisData.ThetaAxis;
    rAxis = axisData.RAxis;

    %-set domain plot-%
    xo = axisData.Position(1);
    yo = axisData.Position(2);
    w = axisData.Position(3);
    h = axisData.Position(4);

    polarAxis.domain.x = min([xo xo + w], 1);
    polarAxis.domain.y = min([yo yo + h], 1);

    %-setting angular axis-%
    gridColor = getStringColor(round(255*axisData.GridColor), axisData.GridAlpha);
    gridWidth = axisData.LineWidth;
    thetaLim = thetaAxis.Limits;

    polarAxis.angularaxis.linecolor = gridColor;
    polarAxis.angularaxis.ticklen = mean(thetaAxis.TickLength);

    if isnumeric(thetaLim)
        polarAxis.angularaxis.range = thetaLim;
    else
        polarAxis.angularaxis.autorange = true;
    end

    if strcmp(axisData.ThetaGrid, 'on')
        polarAxis.angularaxis.gridwidth = gridWidth;
        polarAxis.angularaxis.gridcolor = gridColor;
    end

    %-set angular axis label-%
    thetaLabel = thetaAxis.Label;

    polarAxis.angularaxis.title.text = thetaLabel.String;
    polarAxis.radialaxis.title.font.family = matlab2plotlyfont(...
            thetaLabel.FontName);
    polarAxis.radialaxis.title.font.size = thetaLabel.FontSize;
    polarAxis.radialaxis.title.font.color = getStringColor( ...
            round(255*thetaLabel.Color));

    %-setting radial axis-%
    rLim = rAxis.Limits;

    polarAxis.radialaxis.showline = false;
    polarAxis.radialaxis.angle = axisData.RAxisLocation+6;
    polarAxis.radialaxis.tickangle = 90-rAxis.TickLabelRotation;
    polarAxis.radialaxis.ticklen = mean(rAxis.TickLength);

    if isnumeric(rLim)
        polarAxis.radialaxis.range = rLim;
    else
        polarAxis.radialaxis.autorange = true;
    end

    if strcmp(axisData.RGrid, 'on')
        polarAxis.radialaxis.gridwidth = gridWidth;
        polarAxis.radialaxis.gridcolor = gridColor;
    end

    %-set radial axis label-%
    rLabel = thetaAxis.Label;

    polarAxis.angularaxis.title.text = 'label';%rLabel.String;
    polarAxis.angularaxis.title.font.family = matlab2plotlyfont(...
            rLabel.FontName);
    polarAxis.angularaxis.title.font.size = rLabel.FontSize;
    polarAxis.angularaxis.title.font.color = getStringColor( ...
            round(255*rLabel.Color));

    %-angular tick labels settings-%
    tickValues = axisData.ThetaTick;
    tickLabels = axisData.ThetaTickLabel;
    showTickLabels = true;

    if ~isempty(tickValues) && tickValues(1) == 0 && tickValues(end) == 360
        tickValues = tickValues(1:end-1);
    end

    if isempty(tickValues)
        showTickLabels = false;
        polarAxis.angularaxis.showticklabels = showTickLabels;
        polarAxis.angularaxis.ticks = '';

    elseif isempty(tickLabels)
        polarAxis.angularaxis.tickvals = tickValues;

    else
        polarAxis.angularaxis.tickvals = tickValues;
        polarAxis.angularaxis.ticktext = tickLabels;
    end

    if showTickLabels
        switch thetaAxis.TickDirection
            case 'in'
                polarAxis.angularaxis.ticks = 'inside';
            case 'out'
                polarAxis.angularaxis.ticks = 'outside';
        end

        %-tick font-%
        polarAxis.angularaxis.tickfont.family = matlab2plotlyfont(...
                thetaAxis.FontName);
        polarAxis.angularaxis.tickfont.size = thetaAxis.FontSize;
        polarAxis.angularaxis.tickfont.color = getStringColor(round(255*thetaAxis.Color));
    end


    %-radial tick labels settings-%
    tickValues = axisData.RTick;
    tickLabels = axisData.RTickLabel;
    showTickLabels = true;

    if isempty(tickValues)
        showTickLabels = false;
        polarAxis.radialaxis.showticklabels = showTickLabels;
        polarAxis.radialaxis.ticks = '';

    elseif isempty(tickLabels)
        polarAxis.radialaxis.tickvals = tickValues;

    else
        polarAxis.radialaxis.tickvals = tickValues;
        polarAxis.radialaxis.ticktext = tickLabels;
    end

    if showTickLabels
        switch rAxis.TickDirection
            case 'in'
                polarAxis.radialaxis.ticks = 'inside';
            case 'out'
                polarAxis.radialaxis.ticks = 'outside';
        end

        %-tick font-%
        polarAxis.radialaxis.tickfont.family = matlab2plotlyfont(...
                rAxis.FontName);
        polarAxis.radialaxis.tickfont.size = rAxis.FontSize;
        polarAxis.radialaxis.tickfont.color = getStringColor(round(255*rAxis.Color));
    end

    obj.layout.(sprintf('polar%d', xsource+1)) = polarAxis;
end
