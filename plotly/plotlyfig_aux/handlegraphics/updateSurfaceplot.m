function obj = updateSurfaceplot(obj, surfaceIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(surfaceIndex).AssociatedAxis);

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %-SURFACE DATA STRUCTURE- %
    image_data = obj.State.Plot(surfaceIndex).Handle;
    figure_data = obj.State.Figure.Handle;

    %-AXIS DATA-%
    xaxis = obj.layout.("xaxis" + xsource);
    yaxis = obj.layout.("yaxis" + ysource);

    %---------------------------------------------------------------------%

    %-surface xaxis and yaxis-%
    obj.data{surfaceIndex}.xaxis = "x" + xsource;
    obj.data{surfaceIndex}.yaxis = "y" + ysource;

    % check for 3D
    if any(nonzeros(image_data.ZData))
        %-surface type-%
        obj.data{surfaceIndex}.type = 'surface';
                
        %-format x an y data-%
        x = image_data.XData;
        y = image_data.YData;
        cdata = image_data.CData;
        if isvector(x)
            [x, y] = meshgrid(x,y);
        end
                
        obj.data{surfaceIndex}.x = x;
        obj.data{surfaceIndex}.y = y;
        obj.data{surfaceIndex}.z = image_data.ZData;
        obj.PlotOptions.Image3D = true;
        obj.PlotOptions.ContourProjection = true;
        
        %- setting grid mesh by default -%
        % x-direction
        xmin = min(x(:));
        xmax = max(x(:));
        xsize = (xmax - xmin) / (size(x, 2)-1); 
        obj.data{surfaceIndex}.contours.x.start = xmin;
        obj.data{surfaceIndex}.contours.x.end = xmax;
        obj.data{surfaceIndex}.contours.x.size = xsize;
        obj.data{surfaceIndex}.contours.x.show = true;
        obj.data{surfaceIndex}.contours.x.color = 'black';
        % y-direction
        ymin = min(y(:));
        ymax = max(y(:));
        ysize = (ymax - ymin) / (size(y, 1)-1);
        obj.data{surfaceIndex}.contours.y.start = ymin;
        obj.data{surfaceIndex}.contours.y.end = ymax;
        obj.data{surfaceIndex}.contours.y.size = ysize;
        obj.data{surfaceIndex}.contours.y.show = true;
        obj.data{surfaceIndex}.contours.y.color = 'black';
    else
        %-surface type-%
        obj = updateImage(obj, surfaceIndex);

        obj.data{surfaceIndex}.x = image_data.XData(1,:);
        obj.data{surfaceIndex}.y = image_data.YData(:,1);
    end

    %---------------------------------------------------------------------%

    %-image colorscale-%
    cmap = figure_data.Colormap;
    len = length(cmap)-1;

    for c = 1: length(cmap)
        col = round(255 * cmap(c, :));
        obj.data{surfaceIndex}.colorscale{c} = ...
                {(c-1)/len, sprintf("rgb(%d,%d,%d)", col)};
    end

    obj.data{surfaceIndex}.surfacecolor = cdata;
    obj.data{surfaceIndex}.name = image_data.DisplayName;
    obj.data{surfaceIndex}.showscale = false;
    obj.data{surfaceIndex}.visible = strcmp(image_data.Visible,'on');

    leg = image_data.Annotation;
    legInfo = leg.LegendInformation;
    switch legInfo.IconDisplayStyle
        case 'on'
            showleg = true;
        case 'off'
            showleg = false;
    end
    obj.data{surfaceIndex}.showlegend = showleg;
end
