function obj = updateSurfaceplot(obj, surfaceIndex)

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(surfaceIndex).AssociatedAxis);

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,axIndex);

%-SURFACE DATA STRUCTURE- %
image_data = get(obj.State.Plot(surfaceIndex).Handle);
figure_data = get(obj.State.Figure.Handle);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

%-------------------------------------------------------------------------%

%-surface xaxis-%
obj.data{surfaceIndex}.xaxis = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

%-surface yaxis-%
obj.data{surfaceIndex}.yaxis = ['y' num2str(ysource)];

%-------------------------------------------------------------------------%

% check for 3D
if any(nonzeros(image_data.ZData))
    
    %-surface type-%
    obj.data{surfaceIndex}.type = 'surface';
    
    %---------------------------------------------------------------------%
    
    %-surface x-%
    obj.data{surfaceIndex}.x = image_data.XData;

    %---------------------------------------------------------------------%
    
    %-surface y-%
    obj.data{surfaceIndex}.y = image_data.YData;
    
    %---------------------------------------------------------------------%
    
    %-surface z-%
    obj.data{surfaceIndex}.z = image_data.ZData;
    
    %---------------------------------------------------------------------%

    %- setting grid mesh by default -%
    % x-direction
    xmin = min(image_data.XData(:));
    xmax = max(image_data.XData(:));
    xsize = (xmax - xmin) / (size(image_data.XData, 2) - 1); 
    obj.data{surfaceIndex}.contours.x.start = xmin;
    obj.data{surfaceIndex}.contours.x.end = xmax;
    obj.data{surfaceIndex}.contours.x.size = xsize;
    obj.data{surfaceIndex}.contours.x.show = true;
    obj.data{surfaceIndex}.contours.x.color = 'black';
    % y-direction
    ymin = min(image_data.YData(:));
    ymax = max(image_data.YData(:));
    ysize = (ymax - ymin) / (size(image_data.YData, 2));
    obj.data{surfaceIndex}.contours.y.start = ymin;
    obj.data{surfaceIndex}.contours.y.end = ymax;
    obj.data{surfaceIndex}.contours.y.size = ysize;
    obj.data{surfaceIndex}.contours.y.show = true;
    obj.data{surfaceIndex}.contours.y.color = 'black';
    
    
else
    
    %-surface type-%
    obj = updateImage(obj, surfaceIndex);
    
    %-surface x-%
    obj.data{surfaceIndex}.x = image_data.XData(1,:);
    
    %-surface y-%
    obj.data{surfaceIndex}.y = image_data.YData(:,1);
end

%-------------------------------------------------------------------------%

%-image colorscale-%

cmap = figure_data.Colormap;
len = length(cmap)-1;

for c = 1: length(cmap)
    col = 255 * cmap(c, :);
    obj.data{surfaceIndex}.colorscale{c} = { (c-1)/len , ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'  ]  };
end

obj.data{surfaceIndex}.surfacecolor = image_data.CData;

%-------------------------------------------------------------------------%

%-surface name-%
obj.data{surfaceIndex}.name = image_data.DisplayName;

%-------------------------------------------------------------------------%

%-surface showscale-%
obj.data{surfaceIndex}.showscale = false;

%-------------------------------------------------------------------------%

%-surface visible-%
obj.data{surfaceIndex}.visible = strcmp(image_data.Visible,'on');

%-------------------------------------------------------------------------%

leg = get(image_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{surfaceIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

end
