function obj = updateAxisMultipleYAxes(obj,axIndex,yaxIndex)
    %----UPDATE AXIS DATA/LAYOUT----%

    %-STANDARDIZE UNITS-%
    axisUnits = obj.State.Axis(axIndex).Handle.Units;
    obj.State.Axis(axIndex).Handle.Units = 'normalized';

    try
        fontUnits = obj.State.Axis(axIndex).Handle.FontUnits;
        obj.State.Axis(axIndex).Handle.FontUnits = 'points';
    catch
        % TODO
    end

    %-AXIS DATA STRUCTURE-%
    axisData = obj.State.Axis(axIndex).Handle;

    xaxis = extractAxisData(obj,axisData, 'X');
    [yaxis, yAxisLim] = extractAxisDataMultipleYAxes(obj, axisData, yaxIndex);

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
    scene.domain.x = min([xo xo + w],1);
    yaxis.domain = min([yo yo + h],1);
    scene.domain.y = min([yo yo + h],1);

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
        obj.layout = setfield(obj.layout, "xaxis" + xsource, xaxis);
    end

    % update the layout field (do not overwrite source)
    obj.layout = setfield(obj.layout, "yaxis" + ysource, yaxis);

    %-REVERT UNITS-%
    obj.State.Axis(axIndex).Handle.Units = axisUnits;

    try
        obj.State.Axis(axIndex).Handle.FontUnits = fontUnits;
    catch
        % TODO
    end

    %-do y-axes visible-%
    obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
    plotIndex = obj.PlotOptions.nPlots;

    obj.data{plotIndex}.type = 'scatter';
    obj.data{plotIndex}.xaxis = "x" + xsource;
    obj.data{plotIndex}.yaxis = "y" + ysource;
end
