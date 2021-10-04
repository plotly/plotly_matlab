function obj = updateTernaryPlot(obj, ternaryIndex)

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(ternaryIndex).AssociatedAxis);

    %-GET DATA STRUCTURES-%
    ternaryData = get(obj.State.Plot(ternaryIndex).Handle);
    axisData = get(obj.State.Plot(ternaryIndex).AssociatedAxis);
    figureData = get(obj.State.Figure.Handle);

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj, axIndex);

    %-ASSOCIATE TERNARY-AXES WITH LAYOUT-%
    obj.data{ternaryIndex}.subplot = sprintf('ternary%d', xsource+1);

    %=========================================================================%
    %
    %-UPDATE TRACE PLOT-%
    %
    %=========================================================================%

    %-set trace-%
    obj.data{ternaryIndex}.type = 'scatterternary';

    if ~strcmpi('none', ternaryData.Marker) && ~strcmpi('none', ternaryData.LineStyle)
        obj.data{ternaryIndex}.mode = 'lines+markers';
    elseif ~strcmpi('none', ternaryData.Marker)
        obj.data{ternaryIndex}.mode = 'markers';
    elseif ~strcmpi('none', ternaryData.LineStyle)
        obj.data{ternaryIndex}.mode = 'lines';
    else
        obj.data{ternaryIndex}.mode = 'none';
    end

    %-------------------------------------------------------------------------%

    %-get plot data-%
    xData = ternaryData.XData;
    yData = ternaryData.YData;

    %-convert from cartesian coordinates to trenary points-%
    aData = yData/sin(deg2rad(60));
    bData = 1 - xData - yData*cot(deg2rad(60));

    %-set plot data-%
    obj.data{ternaryIndex}.a = aData;
    obj.data{ternaryIndex}.b = bData;

    %-------------------------------------------------------------------------%

    %-trace line settings-%
    obj.data{ternaryIndex}.line = extractLineLine(ternaryData);
    obj.data{ternaryIndex}.marker = extractLineMarker(ternaryData);
    obj.data{ternaryIndex}.marker.line.width = 2.00 * obj.data{ternaryIndex}.marker.line.width;

    obj.data{ternaryIndex}.name = ternaryData.DisplayName;
    obj.data{ternaryIndex}.showscale = false;
    obj.data{ternaryIndex}.visible = strcmp(ternaryData.Visible,'on');

    %-------------------------------------------------------------------------%

    %-legend-%
    leg = get(ternaryData.Annotation);
    legInfo = get(leg.LegendInformation);

    switch legInfo.IconDisplayStyle
        case 'on'
            showleg = true;
        case 'off'
            showleg = false;
    end

    obj.data{ternaryIndex}.showlegend = showleg;

    %=========================================================================%
    %
    %-UPDATE TERNARY AXES-%
    %
    %=========================================================================%

    %-set domain plot-%
    xo = axisData.Position(1);
    yo = axisData.Position(2);
    w = axisData.Position(3);
    h = axisData.Position(4);

    ternary.domain.x = min([xo xo + w],1);
    ternary.domain.y = min([yo yo + h],1);

    %-----------------------------------------------------------------------------%

    %-label settings-%
    l = 1; t = 1;
    labelLetter = {'b', 'a', 'c'};

    for n = 1:length(axisData.Children)
        if strcmpi(axisData.Children(n).Type, 'text')
            stringText = axisData.Children(n).String;

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
        patterText = sprintf('ternary.%saxis.title', labelLetter{l});

        labelText = axisData.Children(n).String;
        labelFontColor = sprintf('rgb(%f,%f,%f)', axisData.Children(n).Color);
        labelFontSize = 1.5 * axisData.Children(n).FontSize;
        labelFontFamily = matlab2plotlyfont(axisData.Children(n).FontName);

        eval(sprintf('%s.text = labelText;', patterText));
        eval(sprintf('%s.font.color = labelFontColor;', patterText));
        eval(sprintf('%s.font.size = labelFontColor;', patterText));
        eval(sprintf('%s.font.family = labelFontFamily;', patterText));
    end

    %-----------------------------------------------------------------------------%

    %-tick settings-%
    t0 = tickIndex(1); t1 = tickIndex(2);
    tick0 = str2num(axisData.Children(t0).String);
    tick1 = str2num(axisData.Children(t1).String);
    dtick = tick1 - tick0;
    
    tickFontColor = sprintf('rgb(%f,%f,%f)', axisData.Children(t0).Color);
    tickFontSize = 1.0 * axisData.Children(t0).FontSize;
    tickFontFamily = matlab2plotlyfont(axisData.Children(t0).FontName);

    for l = 1:3
        patterText = sprintf('ternary.%saxis', labelLetter{l});

        eval(sprintf('%s.tick0 = tick0;', patterText));
        eval(sprintf('%s.dtick = dtick;', patterText));
        eval(sprintf('%s.tickfont.color = tickFontColor;', patterText));
        eval(sprintf('%s.tickfont.size = tickFontSize;', patterText));
        eval(sprintf('%s.tickfont.family = tickFontFamily;', patterText));
    end

    %-----------------------------------------------------------------------------%

    %-set ternary axes to layout-%
    obj.layout = setfield(obj.layout, sprintf('ternary%d', xsource+1), ternary);

    %-----------------------------------------------------------------------------%

    obj.PlotlyDefaults.isTernary = true;

    %-----------------------------------------------------------------------------%

end

function rad = deg2rad(deg)
    rad = deg / 180 * pi;
end
