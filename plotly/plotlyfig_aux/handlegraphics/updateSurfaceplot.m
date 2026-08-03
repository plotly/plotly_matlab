function data = updateSurfaceplot(obj, surfaceIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(surfaceIndex).AssociatedAxis);

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %-SURFACE DATA STRUCTURE- %
    image_data = obj.State.Plot(surfaceIndex).Handle;
    figure_data = obj.State.Figure.Handle;

    %-surface xaxis and yaxis-%
    data.xaxis = sprintf("x%d", xsource);
    data.yaxis = sprintf("y%d", ysource);

    % check for 3D
    if any(nonzeros(get(image_data, 'ZData')))
        data.type = "surface";

        %-format x an y data-%
        x = get(image_data, 'XData');
        y = get(image_data, 'YData');
        cdata = get(image_data, 'CData');
        if isvector(x)
            [x, y] = meshgrid(x,y);
        end

        data.x = x;
        data.y = y;
        data.z = get(image_data, 'ZData');
        obj.PlotOptions.Image3D = true;
        obj.PlotOptions.ContourProjection = true;

        data.contours = struct( ...
            "x", struct( ...
                "start", min(x(:)), ...
                "end", max(x(:)), ...
                "size", rangeLength(x(:)) / (size(x, 2)-1), ...
                "show", true, ...
                "color", "black" ...
            ), ...
            "y", struct( ...
                "start", min(y(:)), ...
                "end", max(y(:)), ...
                "size", rangeLength(y(:)) / (size(y, 1)-1), ...
                "show", true, ...
                "color", "black" ...
            ) ...
        );
    else
        data = updateImage(obj, surfaceIndex);
        tmpXData = get(image_data, 'XData');
        data.x = tmpXData(1,:);
        tmpYData = get(image_data, 'YData');
        data.y = tmpYData(:,1);
    end

    cmap = get(figure_data, 'Colormap');
    len = length(cmap)-1;

    for c = 1: length(cmap)
        col = round(255 * cmap(c, :));
        data.colorscale{c} = {(c-1)/len, getStringColor(col)};
    end

    data.surfacecolor = cdata;
    data.name = get(image_data, 'DisplayName');
    data.showscale = false;
    data.visible = strcmp(get(image_data, 'Visible'), "on");

    data.showlegend = getShowLegend(image_data);
end
