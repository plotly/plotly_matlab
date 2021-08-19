function obj = updateContourProjection(obj,contourIndex)

%-FIGURE DATA STRUCTURE-%
figure_data = get(obj.State.Figure.Handle);

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(contourIndex).AssociatedAxis);

%-AXIS DATA STRUCTURE-%
axis_data = get(obj.State.Plot(contourIndex).AssociatedAxis);

%-PLOT DATA STRUCTURE- %
contour_data = get(obj.State.Plot(contourIndex).Handle)

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,axIndex);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

%-------------------------------------------------------------------------%

%-contour xaxis-%
obj.data{contourIndex}.xaxis = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

%-contour yaxis-%
obj.data{contourIndex}.yaxis = ['y' num2str(ysource)];

%-------------------------------------------------------------------------%

%-contour name-%
obj.data{contourIndex}.name = contour_data.DisplayName;

%-------------------------------------------------------------------------%

%-setting the plot-%
xdata = contour_data.XData;
ydata = contour_data.YData;
zdata = contour_data.ZData;

if isvector(zdata)
    
    %-contour type-%
    obj.data{contourIndex}.type = 'contour';
    
    %-contour x data-%
    if ~isvector(x)
        obj.data{contourIndex}.xdata = xdata(1,:);
    else
        obj.data{contourIndex}.xdata = xdata;
    end

    %-contour y data-%
    if ~isvector(y)
        obj.data{contourIndex}.ydata = ydata';
    else
        obj.data{contourIndex}.ydata = ydata';
    end
    
    %-contour z data-%
    obj.data{contourIndex}.z = zdata;
    
else
    
    %-contour type-%
    obj.data{contourIndex}.type = 'surface';
    
    %-contour x and y data
%     [xmesh, ymesh] = meshgrid(xdata, ydata);
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
    
end

%-------------------------------------------------------------------------%

%-contour x type-%

obj.data{contourIndex}.xtype = 'array';

%-------------------------------------------------------------------------%

%-contour y type-%

obj.data{contourIndex}.ytype = 'array';

%-------------------------------------------------------------------------%

%-contour visible-%

obj.data{contourIndex}.visible = strcmp(contour_data.Visible,'on');

%-------------------------------------------------------------------------%

%-contour showscale-%
obj.data{contourIndex}.showscale = false;

%-------------------------------------------------------------------------%

%-zauto-%
obj.data{contourIndex}.zauto = false;

%-------------------------------------------------------------------------%

%-zmin-%
obj.data{contourIndex}.zmin = axis_data.CLim(1);

%-------------------------------------------------------------------------%

%-zmax-%
obj.data{contourIndex}.zmax = axis_data.CLim(2);

%-------------------------------------------------------------------------%

%-colorscale (ASSUMES PATCH CDATAMAP IS 'SCALED')-%
colormap = figure_data.Colormap;

for c = 1:size((colormap),1)
    col =  255*(colormap(c,:));
    obj.data{contourIndex}.colorscale{c} = {(c-1)/(size(colormap,1)-1), ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')']};
end

%-------------------------------------------------------------------------%

%-contour reverse scale-%
obj.data{contourIndex}.reversescale = false;

%-------------------------------------------------------------------------%

%-autocontour-%
obj.data{contourIndex}.autocontour = false;

%-------------------------------------------------------------------------%

%-contour contours-%

%-coloring-%
switch contour_data.Fill
    case 'off'
        obj.data{contourIndex}.contours.coloring = 'lines';
    case 'on'
        obj.data{contourIndex}.contours.coloring = 'fill';
end

%-start-%
obj.data{contourIndex}.contours.start = contour_data.TextList(1);

%-end-%
obj.data{contourIndex}.contours.end = contour_data.TextList(end);

%-step-%
obj.data{contourIndex}.contours.size = diff(contour_data.TextList(1:2));

%-------------------------------------------------------------------------%

if(~strcmp(contour_data.LineStyle,'none'))
    
    %-contour line colour-%
    if isnumeric(contour_data.LineColor)
        col = 255*contour_data.LineColor;
        obj.data{contourIndex}.line.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
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

%-------------------------------------------------------------------------%

%-contour showlegend-%

leg = get(contour_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{contourIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

end
