function obj = updateContourProjection(obj,contourIndex)
    %-FIGURE DATA STRUCTURE-%
    figure_data = obj.State.Figure.Handle;

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(contourIndex).AssociatedAxis);

    %-PLOT DATA STRUCTURE- %
    contour_data = obj.State.Plot(contourIndex).Handle;

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    obj.data{contourIndex}.xaxis = "x" + xsource;
    obj.data{contourIndex}.yaxis = "y" + ysource;
    obj.data{contourIndex}.name = contour_data.DisplayName;

    %-setting the plot-%
    xdata = contour_data.XData;
    ydata = contour_data.YData;
    zdata = contour_data.ZData;

    %-contour type-%
    obj.data{contourIndex}.type = 'surface';

    %-contour x and y data
    obj.data{contourIndex}.x = xdata;
    obj.data{contourIndex}.y = ydata;

    %-contour z data-%
    obj.data{contourIndex}.z = zdata;%-2*ones(size(zdata));

    %-setting for contour lines z-direction-%
    obj.data{contourIndex}.contours.z.start = contour_data.LevelList(1);
    obj.data{contourIndex}.contours.z.end = contour_data.LevelList(end);
    obj.data{contourIndex}.contours.z.size = contour_data.LevelStep;
    obj.data{contourIndex}.contours.z.show = true;
    obj.data{contourIndex}.contours.z.usecolormap = true;
    obj.data{contourIndex}.hidesurface = true;
    obj.data{contourIndex}.surfacecolor = zdata;

    obj.data{contourIndex}.contours.z.project.x = true;
    obj.data{contourIndex}.contours.z.project.y = true;
    obj.data{contourIndex}.contours.z.project.z = true;

    obj.data{contourIndex}.visible = strcmp(contour_data.Visible,'on');
    obj.data{contourIndex}.showscale = false;

    %-colorscale (ASSUMES PATCH CDATAMAP IS 'SCALED')-%
    colormap = figure_data.Colormap;

    for c = 1:size((colormap),1)
        col = round(255*(colormap(c,:)));
        obj.data{contourIndex}.colorscale{c} = ...
                {(c-1)/(size(colormap,1)-1), getStringColor(col)};
    end

    %-contour reverse scale-%
    obj.data{contourIndex}.reversescale = false;

    %-aspect ratio-%
    ar = obj.PlotOptions.AspectRatio;

    if ~isempty(ar)
        if ischar(ar)
            obj.layout.scene.aspectmode = ar;
        elseif isvector(ar) && length(ar) == 3
            zar = ar(3);
        end
    else
        %-define as default-%
        xar = max(xdata(:));
        yar = max(ydata(:));
        xyar = max([xar, yar]);
        zar = 0.6*xyar;
    end

    obj.layout.scene.aspectratio.x = xyar;
    obj.layout.scene.aspectratio.y = xyar;
    obj.layout.scene.aspectratio.z = zar;

    %-camera eye-%
    ey = obj.PlotOptions.CameraEye;

    if ~isempty(ey)
        if isvector(ey) && length(ey) == 3
            obj.layout.scene.camera.eye.x = ey(1);
            obj.layout.scene.camera.eye.y = ey(2);
            obj.layout.scene.camera.eye.z = ey(3);
        end
    else
        %-define as default-%
        xey = - xyar;
        if xey>0
            xfac = -0.2;
        else
            xfac = 0.2;
        end
        yey = - xyar;
        if yey>0
            yfac = -0.2;
        else
            yfac = 0.2;
        end
        if zar>0
            zfac = 0.2;
        else
            zfac = -0.2;
        end

        obj.layout.scene.camera.eye.x = xey + xfac*xey;
        obj.layout.scene.camera.eye.y = yey + yfac*yey;
        obj.layout.scene.camera.eye.z = zar + zfac*zar;
    end

    switch contour_data.Annotation.LegendInformation.IconDisplayStyle
        case "on"
            obj.data{contourIndex}.showlegend = true;
        case "off"
            obj.data{contourIndex}.showlegend = false;
    end
end
