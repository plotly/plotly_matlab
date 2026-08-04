function obj = updatePColor(obj, patchIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(patchIndex).AssociatedAxis);

    %-PCOLOR DATA STRUCTURE- %
    pcolor_data = obj.State.Plot(patchIndex).Handle;
    figure_data = obj.State.Figure.Handle;

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %-pcolor xaxis and yaxis-%
    obj.data{patchIndex}.xaxis = sprintf("x%d", xsource);
    obj.data{patchIndex}.yaxis = sprintf("y%d", ysource);

    %-plot type: heatmap (a flat colored cell grid)-%
    obj.data{patchIndex}.type = 'heatmap';

    %-format data-%
    XData = get(pcolor_data, 'XData');
    YData = get(pcolor_data, 'YData');
    CData = get(pcolor_data, 'CData');

    if isvector(XData)
        [XData, YData] = meshgrid(XData, YData);
    end

    % the last row and column of pcolor's CData are unused (each cell
    % is bounded by its four corner values); a heatmap needs one value
    % per cell
    if size(CData, 1) == size(XData, 1) && size(CData, 2) == size(XData, 2)
        cellData = CData(1:end-1, 1:end-1);
    else
        cellData = CData;
    end
    obj.data{patchIndex}.z = cellData;

    % cell centers along x and y
    xCenter = mean([XData(1, 1:end-1); XData(1, 2:end)]);
    yCenter = mean([YData(1:end-1, 1)'; YData(2:end, 1)']);
    obj.data{patchIndex}.x = xCenter;
    obj.data{patchIndex}.y = yCenter;

    %-coloring-%
    cmap = get(figure_data, 'Colormap');
    len = length(cmap)-1;

    for c = 1:length(cmap)
        col = round(255 * cmap(c, :));
        obj.data{patchIndex}.colorscale{c} = ...
                {(c-1)/len, getStringColor(col)};
    end

    obj.data{patchIndex}.showscale = false;
    obj.data{patchIndex}.zmin = min(CData(:));
    obj.data{patchIndex}.zmax = max(CData(:));

    obj.data{patchIndex}.showlegend = getShowLegend(pcolor_data);
end
