function obj = updateTernaryPlot(obj, ternaryIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(ternaryIndex).AssociatedAxis);

    %-GET DATA STRUCTURES-%
    ternaryData = obj.State.Plot(ternaryIndex).Handle;
    axisData = obj.State.Plot(ternaryIndex).AssociatedAxis;

    %-CHECK FOR MULTIPLE AXES-%
    xsource = findSourceAxis(obj, axIndex);

    %-ASSOCIATE TERNARY-AXES WITH LAYOUT-%
    obj.data{ternaryIndex}.subplot = sprintf('ternary%d', xsource+1);

    %=====================================================================%
    %
    %-UPDATE TRACE PLOT-%
    %
    %=====================================================================%

    %-set trace-%
    obj.data{ternaryIndex}.type = 'scatterternary';

    if ~strcmpi('none', get(ternaryData, 'Marker')) && ~strcmpi('none', get(ternaryData, 'LineStyle'))
        obj.data{ternaryIndex}.mode = 'lines+markers';
    elseif ~strcmpi('none', get(ternaryData, 'Marker'))
        obj.data{ternaryIndex}.mode = 'markers';
    elseif ~strcmpi('none', get(ternaryData, 'LineStyle'))
        obj.data{ternaryIndex}.mode = 'lines';
    else
        obj.data{ternaryIndex}.mode = 'none';
    end

    %-get plot data-%
    xData = get(ternaryData, 'XData');
    yData = get(ternaryData, 'YData');

    %-convert from cartesian coordinates to trenary points-%
    aData = yData/sin(deg2rad(60));
    bData = 1 - xData - yData*cot(deg2rad(60));

    %-set plot data-%
    obj.data{ternaryIndex}.a = aData;
    obj.data{ternaryIndex}.b = bData;

    %-trace line settings-%
    obj.data{ternaryIndex}.line = extractLineLine(ternaryData);
    obj.data{ternaryIndex}.marker = extractLineMarker(ternaryData);
    obj.data{ternaryIndex}.marker.line.width = 2.00 * obj.data{ternaryIndex}.marker.line.width;

    obj.data{ternaryIndex}.name = get(ternaryData, 'DisplayName');
    obj.data{ternaryIndex}.showscale = false;
    obj.data{ternaryIndex}.visible = strcmp(get(ternaryData, 'Visible'),'on');

    obj.data{ternaryIndex}.showlegend = getShowLegend(ternaryData);

    %=====================================================================%
    %
    %-UPDATE TERNARY AXES-%
    %
    %=====================================================================%

    %-set domain plot-%
    ternaryPosition = get(axisData, 'Position');
    xo = ternaryPosition(1);
    yo = ternaryPosition(2);
    w = ternaryPosition(3);
    h = ternaryPosition(4);

    ternary.domain.x = min([xo xo + w],1);
    ternary.domain.y = min([yo yo + h],1);

    %-label settings-%
    l = 1; t = 1;
    labelLetter = {'b', 'a', 'c'};

    ternaryChildren = get(axisData, 'Children');
    for n = 1:length(ternaryChildren)
        if strcmpi(get(ternaryChildren(n), 'Type'), 'text')
            stringText = get(ternaryChildren(n), 'String');
            if any(isletter(stringText))
                labelIndex(l) = n;
                l = l + 1;
            else
                tickIndex(t) = n;
                t = t + 1;
            end
        end
    end

    for l = 1:length(labelIndex)
        n = labelIndex(l);

        labelText = get(ternaryChildren(n), 'String');
        labelFontColor = getStringColor(round(255*get(ternaryChildren(n), 'Color')));
        labelFontSize = 1.5 * get(ternaryChildren(n), 'FontSize');
        labelFontFamily = matlab2plotlyfont(get(ternaryChildren(n), 'FontName'));

        ternary.(sprintf('%saxis', labelLetter{l})).title.text = labelText;
        ternary.(sprintf('%saxis', labelLetter{l})).title.font.color = labelFontColor;
        ternary.(sprintf('%saxis', labelLetter{l})).title.font.size = labelFontSize;
        ternary.(sprintf('%saxis', labelLetter{l})).title.font.family = labelFontFamily;
    end

    %-tick settings-%
    t0 = tickIndex(1); t1 = tickIndex(2);
    tick0 = str2num(get(ternaryChildren(t0), 'String'));
    tick1 = str2num(get(ternaryChildren(t1), 'String'));
    dtick = tick1 - tick0;

    tickFontColor = getStringColor(round(255*get(ternaryChildren(t0), 'Color')));
    tickFontSize = 1.0 * get(ternaryChildren(t0), 'FontSize');
    tickFontFamily = matlab2plotlyfont(get(ternaryChildren(t0), 'FontName'));

    for l = 1:3
        ternary.(sprintf('%saxis', labelLetter{l})).tick0 = tick0;
        ternary.(sprintf('%saxis', labelLetter{l})).dtick = dtick;
        ternary.(sprintf('%saxis', labelLetter{l})).tickfont.color = tickFontColor;
        ternary.(sprintf('%saxis', labelLetter{l})).tickfont.size = tickFontSize;
        ternary.(sprintf('%saxis', labelLetter{l})).tickfont.family = tickFontFamily;
    end

    obj.layout.(sprintf('ternary%d', xsource+1)) = ternary;

    obj.PlotlyDefaults.isTernary = true;
end

function rad = deg2rad(deg)
    rad = deg / 180 * pi;
end
