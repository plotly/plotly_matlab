function obj = updateAxisMultipleYAxes(obj,axIndex,yaxIndex)
    %----UPDATE AXIS DATA/LAYOUT----%

    %-AXIS DATA STRUCTURE-%
    axisData = obj.State.Axis(axIndex).Handle;

    %-STANDARDIZE UNITS-%
    axisUnits = get(axisData, 'Units');
    set(axisData, 'Units', 'normalized');

    if isprop(axisData, "FontUnits")
        fontUnits = get(axisData, 'FontUnits');
        set(axisData, 'FontUnits', 'points');
    end

    xaxis = extractAxisData(obj,axisData, 'X');
    yaxis = extractAxisDataMultipleYAxes(obj, axisData, yaxIndex);

    %-getting and setting position data-%
    axisPosition = get(axisData, 'Position');
    xo = axisPosition(1);
    yo = axisPosition(2);
    w = axisPosition(3);
    h = axisPosition(4);

    if obj.PlotOptions.AxisEqual
        wh = min(axisPosition(3:4));
        w = wh;
        h = wh;
    end

    xaxis.domain = min([xo xo + w],1);
    yaxis.domain = min([yo yo + h],1);

    [xsource, ysource, xoverlay, yoverlay] = findSourceAxis(obj, axIndex, yaxIndex);

    xaxis.anchor = sprintf("y%d", ysource);
    yaxis.anchor = sprintf("x%d", xsource);

    if xoverlay
        xaxis.overlaying = sprintf("x%d", xoverlay);
    end
    if yoverlay
        yaxis.overlaying = sprintf("y%d", yoverlay);
    end

    % update the layout field (do not overwrite source)
    if xsource == axIndex
        obj.layout.(sprintf("xaxis%d", xsource)) = xaxis;
    end

    % update the layout field (do not overwrite source)
    obj.layout.(sprintf("yaxis%d", ysource)) = yaxis;

    %-REVERT UNITS-%
    set(axisData, 'Units', axisUnits);

    if isprop(axisData, "FontUnits")
        set(axisData, 'FontUnits', fontUnits);
    end

    %-do y-axes visible-%
    obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
    plotIndex = obj.PlotOptions.nPlots;

    obj.data{plotIndex}.type = 'scatter';
    obj.data{plotIndex}.xaxis = sprintf("x%d", xsource);
    obj.data{plotIndex}.yaxis = sprintf("y%d", ysource);
end
