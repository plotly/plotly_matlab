function updateOnlyAxes(obj, plotIndex)

    %-------------------------------------------------------------------------%

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj, axIndex);

    %-ASSOCIATE AXIS LAYOUT-%
    obj.data{plotIndex}.xaxis = sprintf('x%d', xsource);
    obj.data{plotIndex}.yaxis = sprintf('y%d', ysource);

    %-------------------------------------------------------------------------%

    %-set scatter trace-%
    obj.data{plotIndex}.type = 'scatter';
    obj.data{plotIndex}.mode = 'none';

    %-------------------------------------------------------------------------%

    %-set empty data-%
    obj.data{plotIndex}.x = [];
    obj.data{plotIndex}.y = [];

    %-------------------------------------------------------------------------%
end