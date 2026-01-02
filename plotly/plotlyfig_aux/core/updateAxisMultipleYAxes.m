function obj = updateAxisMultipleYAxes(obj,axIndex,yaxIndex)
    %----UPDATE AXIS DATA/LAYOUT----%

    %-AXIS DATA STRUCTURE-%
    axisData = obj.State.Axis(axIndex).Handle;

    %-STANDARDIZE UNITS-%
    axisUnits = axisData.Units;
    axisData.Units = 'normalized';

    if isprop(axisData, "FontUnits")
        fontUnits = axisData.FontUnits;
        axisData.FontUnits = 'points';
    end

    xaxis = extractAxisData(obj,axisData, 'X');
    yaxis = extractAxisDataMultipleYAxes(obj, axisData, yaxIndex);

    %-getting and setting position data-%
    xo = axisData.Position(1);
    yo = axisData.Position(2);
    w = axisData.Position(3);
    h = axisData.Position(4);

    if obj.PlotOptions.AxisEqual
        wh = min(axisData.Position(3:4));
        w = wh;
        h = wh;
    end

    xaxis.domain = min([xo xo + w],1);
    yaxis.domain = min([yo yo + h],1);

    [xsource, ysource, xoverlay, yoverlay] = findSourceAxis(obj, axIndex, yaxIndex);

    xaxis.anchor = "y" + ysource;
    yaxis.anchor = "x" + xsource;

    if xoverlay
        xaxis.overlaying = "x" + xoverlay;
    end
    if yoverlay
        yaxis.overlaying = "y" + yoverlay;
    end

    % update the layout field (do not overwrite source)
    if xsource == axIndex
        obj.layout.("xaxis" + xsource) = xaxis;
    end

    % update the layout field (do not overwrite source)
    obj.layout.("yaxis" + ysource) = yaxis;

    %-REVERT UNITS-%
    axisData.Units = axisUnits;

    if isprop(axisData, "FontUnits")
        axisData.FontUnits = fontUnits;
    end

    %-do y-axes visible-%
    obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
    plotIndex = obj.PlotOptions.nPlots;

    obj.data{plotIndex}.type = 'scatter';
    obj.data{plotIndex}.xaxis = "x" + xsource;
    obj.data{plotIndex}.yaxis = "y" + ysource;
end
