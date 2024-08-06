function obj = updateFunctionContour(obj,contourIndex)
    %-FIGURE DATA STRUCTURE-%
    figure_data = obj.State.Figure.Handle;

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(contourIndex).AssociatedAxis);

    %-AXIS DATA STRUCTURE-%
    axis_data = obj.State.Plot(contourIndex).AssociatedAxis;

    %-PLOT DATA STRUCTURE- %
    contour_data = obj.State.Plot(contourIndex).Handle;

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    %-AXIS DATA-%
    xaxis = obj.layout.("xaxis" + xsource);
    yaxis = obj.layout.("yaxis" + ysource);

    %---------------------------------------------------------------------%

    %-contour xaxis and yaxis-%
    obj.data{contourIndex}.xaxis = ['x' num2str(xsource)];
    obj.data{contourIndex}.yaxis = ['y' num2str(ysource)];

    %---------------------------------------------------------------------%

    %-contour name-%
    obj.data{contourIndex}.name = contour_data.DisplayName;

    %---------------------------------------------------------------------%

    %-contour type-%
    obj.data{contourIndex}.type = 'contour';

    %---------------------------------------------------------------------%

    %-setting the plot-%
    xdata = contour_data.XData;
    ydata = contour_data.YData;
    zdata = contour_data.ZData;

    %-contour x data-%
    if ~isvector(xdata)
        obj.data{contourIndex}.x = xdata(1,:);
    else
        obj.data{contourIndex}.x = xdata;
    end

    %-contour y data-%
    if ~isvector(ydata)
        obj.data{contourIndex}.y = ydata(:,1);
    else
        obj.data{contourIndex}.y = ydata;
    end

    %-contour z data-%
    obj.data{contourIndex}.z = zdata;

    %---------------------------------------------------------------------%

    obj.data{contourIndex}.xtype = 'array';
    obj.data{contourIndex}.ytype = 'array';
    obj.data{contourIndex}.visible = strcmp(contour_data.Visible,'on');
    obj.data{contourIndex}.showscale = false;
    obj.data{contourIndex}.zauto = false;
    obj.data{contourIndex}.zmin = axis_data.CLim(1);
    obj.data{contourIndex}.zmax = axis_data.CLim(2);

    %---------------------------------------------------------------------%

    %-colorscale (ASSUMES PATCH CDATAMAP IS 'SCALED')-%
    colormap = figure_data.Colormap;

    for c = 1:size((colormap),1)
        col =  255*(colormap(c,:));
        obj.data{contourIndex}.colorscale{c} = ...
                {(c-1)/(size(colormap,1)-1), sprintf("rgb(%f,%f,%f)", col)};
    end

    %---------------------------------------------------------------------%

    obj.data{contourIndex}.reversescale = false;
    obj.data{contourIndex}.autocontour = false;

    %---------------------------------------------------------------------%

    %-contour contours-%

    %-coloring-%
    switch contour_data.Fill
        case 'off'
            obj.data{contourIndex}.contours.coloring = 'lines';
        case 'on'
            obj.data{contourIndex}.contours.coloring = 'fill';
    end

    %---------------------------------------------------------------------%

    %-contour levels-%
    if length(contour_data.LevelList) > 1
        cstart = contour_data.LevelList(1);
        cend = contour_data.LevelList(end);
        csize = mean(diff(contour_data.LevelList));
    else
        cstart = contour_data.LevelList(1) - 1e-3;
        cend = contour_data.LevelList(end) + 1e-3;
        csize = 2e-3;
    end

    %-start-%
    obj.data{contourIndex}.contours.start = cstart;

    %-end-%
    obj.data{contourIndex}.contours.end = cend;

    %-step-%
    obj.data{contourIndex}.contours.size = csize;

    %---------------------------------------------------------------------%

    if (~strcmp(contour_data.LineStyle,'none'))
        %-contour line colour-%
        if isnumeric(contour_data.LineColor)
            col = 255*contour_data.LineColor;
            obj.data{contourIndex}.line.color = sprintf("rgb(%f,%f,%f)", col);
        else
            obj.data{contourIndex}.line.color = 'rgba(0,0,0,0)';
        end

        %-contour line width-%
        obj.data{contourIndex}.line.width = contour_data.LineWidth;

        %-contour line dash-%
        switch contour_data.LineStyle
            case '-'
                LineStyle = 'solid';
            case '--'
                LineStyle = 'dash';
            case ':'
                LineStyle = 'dot';
            case '-.'
                LineStyle = 'dashdot';
        end
        obj.data{contourIndex}.line.dash = LineStyle;

        %-contour smoothing-%
        obj.data{contourIndex}.line.smoothing = 0;
    else
        %-contours showlines-%
        obj.data{contourIndex}.contours.showlines = false;
    end

    %---------------------------------------------------------------------%

    %-contour showlegend-%

    leg = contour_data.Annotation;
    legInfo = leg.LegendInformation;

    switch legInfo.IconDisplayStyle
        case 'on'
            showleg = true;
        case 'off'
            showleg = false;
    end

    obj.data{contourIndex}.showlegend = showleg;

    %---------------------------------------------------------------------%

    %-axis layout-%
    t = 'linear';
    obj.layout.("xaxis" + xsource).type=t;
    obj.layout.("xaxis" + xsource).autorange=true;
    obj.layout.("xaxis" + xsource).ticktext=axis_data.XTickLabel;
    obj.layout.("xaxis" + xsource).tickvals=axis_data.XTick;

    obj.layout.("yaxis" + xsource).type=t;
    obj.layout.("yaxis" + xsource).autorange=true;
    obj.layout.("yaxis" + xsource).ticktext=axis_data.YTickLabel;
    obj.layout.("yaxis" + xsource).tickvals=axis_data.YTick;
end
