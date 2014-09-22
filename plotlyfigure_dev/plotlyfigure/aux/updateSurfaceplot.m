function obj = updateSurfaceplot(obj, surfaceIndex)

%-FIGURE STRUCTURE-%
figure_data = get(obj.State.Figure.Handle);

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(surfaceIndex).AssociatedAxis);

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,axIndex);

%-SURFACE DATA STRUCTURE- %
image_data = get(obj.State.Plot(surfaceIndex).Handle);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

%-------------------------------------------------------------------------%

%-SURFACE XAXIS-%
obj.data{surfaceIndex}.xaxis = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

%-SURFACE YAXIS-%
obj.data{surfaceIndex}.yaxis = ['y' num2str(ysource)];

%-------------------------------------------------------------------------%

%-SURFACE TYPE-%
obj.data{surfaceIndex}.type = 'scatter3d';

%-------------------------------------------------------------------------%

%-SURFACE X-%
if isvector(image_data.XData)
    obj.data{surfaceIndex}.x = repmat(image_data.XData,size(image_data.ZData,1),1);
else
    obj.data{surfaceIndex}.x = image_data.XData;
end

obj.data{surfaceIndex}.x = reshape(obj.data{surfaceIndex}.x,1,size(obj.data{surfaceIndex}.x,1)*size(obj.data{surfaceIndex}.x,2));

%-------------------------------------------------------------------------%

%-SURFACE Y-%
if isvector(image_data.YData)
    obj.data{surfaceIndex}.y = repmat(image_data.YData,size(image_data.ZData,2),1);
else
    obj.data{surfaceIndex}.y = image_data.YData; 
end

obj.data{surfaceIndex}.y = reshape(obj.data{surfaceIndex}.y,1,size(obj.data{surfaceIndex}.y,1)*size(obj.data{surfaceIndex}.y,2));


%-------------------------------------------------------------------------%

%-SURFACE Z-%
obj.data{surfaceIndex}.z = reshape(image_data.ZData,1,size(image_data.ZData,1)*size(image_data.ZData,2));

%-------------------------------------------------------------------------%

%-SURFACE NAME-%
obj.data{surfaceIndex}.name = image_data.DisplayName;

%-------------------------------------------------------------------------%

%-SURFACE SHOWSCALE-%
obj.data{surfaceIndex}.showscale = false;

%-------------------------------------------------------------------------%

%-SURFACE VISIBLE-%
obj.data{surfaceIndex}.visible = strcmp(image_data.Visible,'on');

%-------------------------------------------------------------------------%

%-SURFACE REVERSE SCALE-%
obj.data{surfaceIndex}.reversecale = false;

%-------------------------------------------------------------------------%

if ~ obj.PlotOptions.Strip
    
    %-SURFACE SHOWLEGEND-%
    leg = get(image_data.Annotation);
    legInfo = get(leg.LegendInformation);
    
    switch legInfo.IconDisplayStyle
        case 'on'
            showleg = true;
        case 'off'
            showleg = false;
    end
    
    obj.data{surfaceIndex}.showlegend = showleg;
end
%-------------------------------------------------------------------------%

end
