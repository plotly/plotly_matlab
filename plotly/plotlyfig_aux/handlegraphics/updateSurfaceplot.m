function data = updateSurfaceplot(obj, surfaceIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(surfaceIndex).AssociatedAxis);

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %-SURFACE DATA STRUCTURE- %
    image_data = obj.State.Plot(surfaceIndex).Handle;
    figure_data = obj.State.Figure.Handle;

    %-surface xaxis and yaxis-%
    data.xaxis = "x" + xsource;
    data.yaxis = "y" + ysource;

    % check for 3D
    if any(nonzeros(image_data.ZData))
        data.type = "surface";

        %-format x an y data-%
        x = image_data.XData;
        y = image_data.YData;
        cdata = image_data.CData;
        if isvector(x)
            [x, y] = meshgrid(x,y);
        end

        data.x = x;
        data.y = y;
        data.z = image_data.ZData;
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
        data.x = image_data.XData(1,:);
        data.y = image_data.YData(:,1);
    end

    cmap = figure_data.Colormap;
    len = length(cmap)-1;

    for c = 1: length(cmap)
        col = round(255 * cmap(c, :));
        data.colorscale{c} = {(c-1)/len, getStringColor(col)};
    end

    data.surfacecolor = cdata;
    data.name = image_data.DisplayName;
    data.showscale = false;
    data.visible = image_data.Visible == "on";

    switch image_data.Annotation.LegendInformation.IconDisplayStyle
        case "on"
            data.showlegend = true;
        case "off"
            data.showlegend = false;
    end
end
