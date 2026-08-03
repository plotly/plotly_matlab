function data = updatePolarplot(obj, plotIndex)

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);

    %-PLOT DATA STRUCTURE- %
    plotData = obj.State.Plot(plotIndex).Handle;

    %-CHECK FOR MULTIPLE AXES-%
    xsource = findSourceAxis(obj, axIndex);

    %-ASSOCIATE POLAR-AXES LAYOUT-%
    data.subplot = sprintf('polar%d', xsource+1);

    %-parse plot data-%
    rData = get(plotData, 'RData');
    thetaData = rad2deg(get(plotData, 'ThetaData'));

    thetaData(rData<0) = mod(thetaData(rData<0)+180, 360);
    rData = abs(rData);

    %-scatterpolar trace setting-%
    data.type = 'scatterpolar';
    data.visible = strcmp(get(plotData, 'Visible'),'on');
    data.name = get(plotData, 'DisplayName');

    %-set scatterpolar data-%
    data.r = rData;
    data.theta = thetaData;

    %-trace settings-%
    if ~strcmpi('none', get(plotData, 'Marker')) ...
            && ~strcmpi('none', get(plotData, 'LineStyle'))
        data.mode = 'lines+markers';
    elseif ~strcmpi('none', get(plotData, 'Marker'))
        data.mode = 'markers';
    elseif ~strcmpi('none', get(plotData, 'LineStyle'))
        data.mode = 'lines';
    else
        data.mode = 'none';
    end

    data.marker = extractLineMarker(plotData);
    data.line = extractLineLine(plotData);
    if isfield(data.line, "width")
        data.line.width = 2 * data.line.width;
    end

    data.showlegend = getShowLegend(plotData);

    %-set polar axes-%
    updatePolaraxes(obj, plotIndex)
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
    axisData = get(plotData, 'Parent');
    thetaAxis = get(axisData, 'ThetaAxis');
    rAxis = get(axisData, 'RAxis');

    %-set domain plot-%
    tmpPosition = get(axisData, 'Position');
    xo = tmpPosition(1);
    yo = tmpPosition(2);
    w = tmpPosition(3);
    h = tmpPosition(4);

    polarAxis.domain.x = min([xo xo + w], 1);
    polarAxis.domain.y = min([yo yo + h], 1);

    %-setting angular axis-%
    gridColor = getStringColor( ...
            round(255*get(axisData, 'GridColor')), get(axisData, 'GridAlpha'));
    gridWidth = get(axisData, 'LineWidth');
    thetaLim = get(thetaAxis, 'Limits');

    polarAxis.angularaxis.linecolor = gridColor;
    polarAxis.angularaxis.ticklen = mean(get(thetaAxis, 'TickLength'));

    if isnumeric(thetaLim)
        polarAxis.angularaxis.range = thetaLim;
    else
        polarAxis.angularaxis.autorange = true;
    end

    if strcmp(get(axisData, 'ThetaGrid'), 'on')
        polarAxis.angularaxis.gridwidth = gridWidth;
        polarAxis.angularaxis.gridcolor = gridColor;
    end

    %-set angular axis label-%
    thetaLabel = get(thetaAxis, 'Label');

    polarAxis.angularaxis.title.text = get(thetaLabel, 'String');
    polarAxis.radialaxis.title.font.family = matlab2plotlyfont(...
            get(thetaLabel, 'FontName'));
    polarAxis.radialaxis.title.font.size = get(thetaLabel, 'FontSize');
    polarAxis.radialaxis.title.font.color = getStringColor( ...
            round(255*get(thetaLabel, 'Color')));

    %-setting radial axis-%
    rLim = get(rAxis, 'Limits');

    polarAxis.radialaxis.showline = false;
    polarAxis.radialaxis.angle = get(axisData, 'RAxisLocation')+6;
    polarAxis.radialaxis.tickangle = 90-get(rAxis, 'TickLabelRotation');
    polarAxis.radialaxis.ticklen = mean(get(rAxis, 'TickLength'));

    if isnumeric(rLim)
        polarAxis.radialaxis.range = rLim;
    else
        polarAxis.radialaxis.autorange = true;
    end

    if strcmp(get(axisData, 'RGrid'), 'on')
        polarAxis.radialaxis.gridwidth = gridWidth;
        polarAxis.radialaxis.gridcolor = gridColor;
    end

    %-set radial axis label-%
    rLabel = get(thetaAxis, 'Label');

    polarAxis.angularaxis.title.text = 'label';%rLabel.String;
    polarAxis.angularaxis.title.font.family = matlab2plotlyfont(...
            get(rLabel, 'FontName'));
    polarAxis.angularaxis.title.font.size = get(rLabel, 'FontSize');
    polarAxis.angularaxis.title.font.color = getStringColor( ...
            round(255*get(rLabel, 'Color')));

    %-angular tick labels settings-%
    tickValues = get(axisData, 'ThetaTick');
    tickLabels = get(axisData, 'ThetaTickLabel');
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
        switch get(thetaAxis, 'TickDirection')
            case 'in'
                polarAxis.angularaxis.ticks = 'inside';
            case 'out'
                polarAxis.angularaxis.ticks = 'outside';
        end

        %-tick font-%
        polarAxis.angularaxis.tickfont.family = matlab2plotlyfont(...
                get(thetaAxis, 'FontName'));
        polarAxis.angularaxis.tickfont.size = get(thetaAxis, 'FontSize');
        polarAxis.angularaxis.tickfont.color = getStringColor( ...
                round(255*get(thetaAxis, 'Color')));
    end

    %-radial tick labels settings-%
    tickValues = get(axisData, 'RTick');
    tickLabels = get(axisData, 'RTickLabel');
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
        switch get(rAxis, 'TickDirection')
            case 'in'
                polarAxis.radialaxis.ticks = 'inside';
            case 'out'
                polarAxis.radialaxis.ticks = 'outside';
        end

        %-tick font-%
        polarAxis.radialaxis.tickfont.family = matlab2plotlyfont(...
                get(rAxis, 'FontName'));
        polarAxis.radialaxis.tickfont.size = get(rAxis, 'FontSize');
        polarAxis.radialaxis.tickfont.color = getStringColor( ...
                round(255*get(rAxis, 'Color')));
    end

    obj.layout.(sprintf('polar%d', xsource+1)) = polarAxis;
end
