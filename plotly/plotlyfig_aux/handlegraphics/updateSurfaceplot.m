function obj = updateSurfaceplot(obj, surfaceIndex)

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

%-surface xaxis-%
obj.data{surfaceIndex}.xaxis = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

%-surface yaxis-%
obj.data{surfaceIndex}.yaxis = ['y' num2str(ysource)];

%-------------------------------------------------------------------------%

% check for 3D
if any(nonzeros(image_data.ZData))
    
    %-surface type-%
    if ~isvector(image_data.XData) || ~isvector(image_data.YData)
        obj.data{surfaceIndex}.type = 'surface';
    else
        obj.data{surfaceIndex}.type = 'surface';
    end
    
    %-------------------------------------------------------------------------%
    
    %-surface x-%
    obj.data{surfaceIndex}.x = image_data.XData;
    
    if strcmp(obj.data{surfaceIndex}.type,'scatter3d')
        obj.data{surfaceIndex}.x = reshape(obj.data{surfaceIndex}.x,1,size(obj.data{surfaceIndex}.x,1)*size(obj.data{surfaceIndex}.x,2));
    end
    %-------------------------------------------------------------------------%
    
    %-surface y-%
    obj.data{surfaceIndex}.y = image_data.YData;
    
    if strcmp(obj.data{surfaceIndex}.type,'scatter3d')
        obj.data{surfaceIndex}.y = reshape(obj.data{surfaceIndex}.y,1,size(obj.data{surfaceIndex}.y,1)*size(obj.data{surfaceIndex}.y,2));
    end
    %-------------------------------------------------------------------------%
    
    %-surface z-%
    obj.data{surfaceIndex}.z = image_data.ZData;
    
    if strcmp(obj.data{surfaceIndex}.type,'scatter3d')
        obj.data{surfaceIndex}.z = reshape(image_data.ZData,1,size(image_data.ZData,1)*size(image_data.ZData,2));
    end
    
else
    %-surface type-%
    obj = updateImage(obj, surfaceIndex);
    
    %-surface x-%
    obj.data{surfaceIndex}.x = image_data.XData(1,:);
    
    %-surface y-%
    obj.data{surfaceIndex}.y = image_data.YData(:,1);
end

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
