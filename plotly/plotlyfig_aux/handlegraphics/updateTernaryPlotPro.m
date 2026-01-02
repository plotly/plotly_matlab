function obj = updateTernaryPlotPro(obj, ternaryIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(ternaryIndex).AssociatedAxis);

    %-GET DATA STRUCTURES-%
    ternaryData = obj.State.Plot(ternaryIndex).Handle;
    axisData = obj.State.Plot(ternaryIndex).AssociatedAxis;
    figureData = obj.State.Figure.Handle;

    %-CHECK FOR MULTIPLE AXES-%
    xsource = findSourceAxis(obj, axIndex);

    %=====================================================================%
    %
    %-UPDATE TRACE PLOT-%
    %
    %=====================================================================%

    %-get plot data-%
    xData = ternaryData.XData;
    yData = ternaryData.YData;

    %-set trace-%
    for t = 1:size(xData,2)
        %-get new ternaryIndex-%
        if t > 1
            obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
            ternaryIndex = obj.PlotOptions.nPlots;
        end

        %-trace type-%
        obj.data{ternaryIndex}.type = 'scatterternary';
        obj.data{ternaryIndex}.subplot = sprintf('ternary%d', xsource+1);

        %-set mode and properties for trace-%
        if ~strcmpi('none', ternaryData.Marker) && ~strcmpi('none', ternaryData.LineStyle)
            obj.data{ternaryIndex}.mode = 'lines+markers';
            obj.data{ternaryIndex}.marker = extractPatchMarker(ternaryData);

        elseif ~strcmpi('none', ternaryData.Marker)
            obj.data{ternaryIndex}.mode = 'markers';
            obj.data{ternaryIndex}.marker = extractPatchMarker(ternaryData);

        elseif ~strcmpi('none', ternaryData.LineStyle)
            obj.data{ternaryIndex}.mode = 'lines';
            obj.data{ternaryIndex}.line = extractPatchLine(ternaryData);

        else
            obj.data{ternaryIndex}.mode = 'none';
        end

        %-convert from cartesian coordinates to trenary points-%
        yTernData = yData(:,t); yTernData(end+1) = yData(1,t);
        xTernData = xData(:,t); xTernData(end+1) = xData(1,t);

        aData = yTernData/sin(deg2rad(60));
        bData = 1 - xTernData - yTernData*cot(deg2rad(60));

        %-set plot data-%
        obj.data{ternaryIndex}.a = aData;
        obj.data{ternaryIndex}.b = bData;

        %-some trace properties-%
        obj.data{ternaryIndex}.name = ternaryData.DisplayName;
        obj.data{ternaryIndex}.showscale = false;
        obj.data{ternaryIndex}.visible = strcmp(ternaryData.Visible,'on');

        %-trace coloring-%
        faceColor = ternaryData.FaceColor;

        if isnumeric(faceColor)
            fillColor = getStringColor(round(255*faceColor));
        else
            cMap = figureData.Colormap;
            nColors = size(cMap,1);
            switch faceColor
                case 'none'
                    fillColor = 'rgba(0,0,0,0)';
                case {'flat', 'interp'}
                    switch ternaryData.CDataMapping
                        case 'scaled'
                            cMin = axisData.CLim(1);
                            cMax = axisData.CLim(2);
                            if strcmpi(faceColor, 'flat')
                                cData = ternaryData.ZData(1,t);
                            elseif strcmpi(faceColor, 'interp')
                                cData = max(ternaryData.ZData(:,t));
                            end
                            cData = max(min(cData, cMax), cMin);
                            cData = (cData - cMin)/diff(axisData.CLim);
                            cData = 1 + floor( cData*(nColors-1) );
                            fillColor = getStringColor(round(255*cMap(cData,:)));
                        case 'direct'
                            fillColor = getStringColor(round(255*cMap(ternary(1,t),:)));
                    end
            end
        end

        obj.data{ternaryIndex}.fillcolor = fillColor;
        obj.data{ternaryIndex}.fill = 'toself';
        obj.data{ternaryIndex}.showlegend = false;
    end

    %=====================================================================%
    %
    %-UPDATE TERNARY AXES-%
    %
    %=====================================================================%

    %-set domain plot-%
    xo = axisData.Position(1);
    yo = axisData.Position(2);
    w = axisData.Position(3);
    h = axisData.Position(4);

    ternary.domain.x = min([xo xo + w],1);
    ternary.domain.y = min([yo yo + h],1);

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

        labelText = axisData.Children(n).String;
        labelFontColor = getStringColor(round(255*axisData.Children(n).Color));
        labelFontSize = 1.5 * axisData.Children(n).FontSize;
        labelFontFamily = matlab2plotlyfont(axisData.Children(n).FontName);

        ternary.(labelLetter{l} + "axis").title.text = labelText;
        ternary.(labelLetter{l} + "axis").title.font.color = labelFontColor;
        ternary.(labelLetter{l} + "axis").title.font.size = labelFontSize;
        ternary.(labelLetter{l} + "axis").title.font.family = labelFontFamily;
    end

    %-tick settings-%
    t0 = tickIndex(1); t1 = tickIndex(2);
    tick0 = str2num(axisData.Children(t0).String);
    tick1 = str2num(axisData.Children(t1).String);
    dtick = tick1 - tick0;

    tickFontColor = getStringColor(round(255*axisData.Children(t0).Color));
    tickFontSize = 1.0 * axisData.Children(t0).FontSize;
    tickFontFamily = matlab2plotlyfont(axisData.Children(t0).FontName);

    for l = 1:3
        ternary.(labelLetter{l} + "axis").tick0 = tick0;
        ternary.(labelLetter{l} + "axis").dtick = dtick;
        ternary.(labelLetter{l} + "axis").tickfont.color = tickFontColor;
        ternary.(labelLetter{l} + "axis").tickfont.size = tickFontSize;
        ternary.(labelLetter{l} + "axis").tickfont.family = tickFontFamily;
    end

    obj.layout.(sprintf('ternary%d', xsource+1)) = ternary;

    obj.PlotlyDefaults.isTernary = true;
end

function rad = deg2rad(deg)
    rad = deg / 180 * pi;
end
