%----UPDATE AXIS DATA/LAYOUT----%

function obj = updateAxisMultipleYAxes(obj,axIndex,yaxIndex)

    %-STANDARDIZE UNITS-%
    axisUnits = get(obj.State.Axis(axIndex).Handle,'Units');
    set(obj.State.Axis(axIndex).Handle,'Units','normalized')

    try
        fontUnits = get(obj.State.Axis(axIndex).Handle,'FontUnits');
        set(obj.State.Axis(axIndex).Handle,'FontUnits','points')
    catch
        % TODO
    end

    %-AXIS DATA STRUCTURE-%
    axisData = get(obj.State.Axis(axIndex).Handle);

    %-------------------------------------------------------------------------%

    %-xaxis-%
    xaxis = extractAxisData(obj,axisData, 'X');

    %-------------------------------------------------------------------------%

    %-yaxis-%
    [yaxis, yAxisLim] = extractAxisDataMultipleYAxes(obj, axisData, yaxIndex);

    %-------------------------------------------------------------------------%

    %-getting and setting postion data-%

    xo = axisData.Position(1);
    yo = axisData.Position(2);
    w = axisData.Position(3);
    h = axisData.Position(4);

    if obj.PlotOptions.AxisEqual
        wh = min(axisData.Position(3:4));
        w = wh;
        h = wh;
    end

    %-------------------------------------------------------------------------%

    %-xaxis domain-%
    xaxis.domain = min([xo xo + w],1);
    scene.domain.x = min([xo xo + w],1);

    %-------------------------------------------------------------------------%

    %-yaxis domain-%
    yaxis.domain = min([yo yo + h],1);
    scene.domain.y = min([yo yo + h],1);

    %-------------------------------------------------------------------------%

    [xsource, ysource, xoverlay, yoverlay] = findSourceAxis(obj, axIndex, yaxIndex);

    %-------------------------------------------------------------------------%

    %-xaxis anchor-%
    xaxis.anchor = ['y' num2str(ysource)];

    %-------------------------------------------------------------------------%

    %-yaxis anchor-%
    yaxis.anchor = ['x' num2str(xsource)];

    %-------------------------------------------------------------------------%

    %-xaxis overlaying-%
    if xoverlay
        xaxis.overlaying = ['x' num2str(xoverlay)];
    end

    %-------------------------------------------------------------------------%

    %-yaxis overlaying-%
    if yoverlay
        yaxis.overlaying = ['y' num2str(yoverlay)];
    end

    %-------------------------------------------------------------------------%

    % update the layout field (do not overwrite source)
    if xsource == axIndex
        obj.layout = setfield(obj.layout,['xaxis' num2str(xsource)],xaxis);
    end

    %-------------------------------------------------------------------------%

    % update the layout field (do not overwrite source)
    obj.layout = setfield(obj.layout,['yaxis' num2str(ysource)],yaxis);

    %-------------------------------------------------------------------------%

    %-REVERT UNITS-%
    set(obj.State.Axis(axIndex).Handle,'Units',axisUnits);

    try
        set(obj.State.Axis(axIndex).Handle,'FontUnits',fontUnits);
    catch
        % TODO
    end

    %-------------------------------------------------------------------------%

    %-do y-axes visibles-%
    obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
    plotIndex = obj.PlotOptions.nPlots;

    obj.data{plotIndex}.type = 'scatter';
    obj.data{plotIndex}.xaxis = ['x' num2str(xsource)];
    obj.data{plotIndex}.yaxis = ['y' num2str(ysource)];

    %-------------------------------------------------------------------------%    
end
