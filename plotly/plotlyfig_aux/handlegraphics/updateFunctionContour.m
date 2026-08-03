function data = updateFunctionContour(obj,contourIndex)
    %-FIGURE DATA STRUCTURE-%
    figure_data = obj.State.Figure.Handle;

    axIndex = obj.getAxisIndex(obj.State.Plot(contourIndex).AssociatedAxis);
    axis_data = obj.State.Plot(contourIndex).AssociatedAxis;
    contour_data = obj.State.Plot(contourIndex).Handle;
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    data.xaxis = "x" + xsource;
    data.yaxis = "y" + ysource;
    data.name = get(contour_data, 'DisplayName');
    data.type = "contour";

    xdata = get(contour_data, 'XData');
    ydata = get(contour_data, 'YData');
    zdata = get(contour_data, 'ZData');

    if ~isvector(xdata)
        data.x = xdata(1,:);
    else
        data.x = xdata;
    end

    if ~isvector(ydata)
        data.y = ydata(:,1);
    else
        data.y = ydata;
    end

    data.z = zdata;

    data.xtype = "array";
    data.ytype = "array";
    data.visible = strcmp(get(contour_data, 'Visible'), "on");
    data.showscale = false;
    data.zauto = false;
    tmpCLim = get(axis_data, 'CLim');
    data.zmin = tmpCLim(1);
    data.zmax = tmpCLim(2);

    %-colorscale (ASSUMES PATCH CDATAMAP IS 'SCALED')-%
    colormap = get(figure_data, 'Colormap');

    for c = 1:size((colormap),1)
        col = round(255*(colormap(c,:)));
        data.colorscale{c} = ...
                {(c-1)/(size(colormap,1)-1), getStringColor(col)};
    end

    data.reversescale = false;
    data.autocontour = false;

    switch get(contour_data, 'Fill')
        case "off"
            data.contours.coloring = "lines";
        case "on"
            data.contours.coloring = "fill";
    end

    if length(get(contour_data, 'LevelList')) > 1
        tmpLevelList = get(contour_data, 'LevelList');
        cstart = tmpLevelList(1);
        cend = tmpLevelList(end);
        csize = mean(diff(get(contour_data, 'LevelList')));
    else
        cstart = tmpLevelList(1) - 1e-3;
        cend = tmpLevelList(end) + 1e-3;
        csize = 2e-3;
    end

    data.contours.start = cstart;
    data.contours.end = cend;
    data.contours.size = csize;

    if ~strcmp(get(contour_data, 'LineStyle'), "none")
        if isnumeric(get(contour_data, 'LineColor'))
            data.line.color = getStringColor(round(255*get(contour_data, 'LineColor')));
        else
            data.line.color = "rgba(0,0,0,0)";
        end

        data.line.width = get(contour_data, 'LineWidth');
        data.line.dash = getLineDash(get(contour_data, 'LineStyle'));
        data.line.smoothing = 0;
    else
        data.contours.showlines = false;
    end

    data.showlegend = getShowLegend(contour_data);

    t = "linear";
    obj.layout.("xaxis" + xsource).type = t;
    obj.layout.("xaxis" + xsource).autorange = true;
    obj.layout.("xaxis" + xsource).ticktext = get(axis_data, 'XTickLabel');
    obj.layout.("xaxis" + xsource).tickvals = get(axis_data, 'XTick');

    obj.layout.("yaxis" + xsource).type = t;
    obj.layout.("yaxis" + xsource).autorange = true;
    obj.layout.("yaxis" + xsource).ticktext = get(axis_data, 'YTickLabel');
    obj.layout.("yaxis" + xsource).tickvals = get(axis_data, 'YTick');
end
