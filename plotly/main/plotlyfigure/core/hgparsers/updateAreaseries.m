function updateAreaseries(obj,areaIndex)

%----AREA FIELDS----%

% x - [DONE]
% y - [DONE]
% r - [HANDLED BY SCATTER]
% t - [HANDLED BY SCATTER]
% mode - [DONE]
% name - [DONE]
% text - [NOT SUPPORTED IN MATLAB]
% error_y - [HANDLED BY ERRORBAR]
% error_x - [HANDLED BY ERRORBAR]
% connectgaps - [NOT SUPPORTED IN MATLAB]
% fill - [HANDLED BY AREA]
% fillcolor - [HANDLED BY AREA]
% opacity - [NOT SUPPORTED IN MATLAB]
% textfont - [NOT SUPPORTED IN MATLAB]
% textposition - [NOT SUPPORTED IN MATLAB]
% xaxis [DONE]
% yaxis [DONE]
% showlegend [DONE]
% stream - [HANDLED BY PLOTLYSTREAM]
% visible [DONE]
% type [DONE]

% MARKER
% marker.color - [DONE]
% marker.size - [DONE]
% marker.line.color - [DONE]
% marker.line.width - [DONE]
% marker.line.dash - [NOT SUPPORTED IN MATLAB]
% marker.line.opacity - [NOT SUPPORTED IN MATLAB]
% marker.line.smoothing - [NOT SUPPORTED IN MATLAB]
% marker.line.shape - [NOT SUPPORTED IN MATLAB]
% marker.opacity - [NOT SUPPORTED IN MATLAB]
% marker.colorscale - [NOT SUPPORTED IN MATLAB]
% marker.sizemode - [NOT SUPPORTED IN MATLAB]
% marker.sizeref - [NOT SUPPORTED IN MATLAB]
% marker.maxdisplayed - [NOT SUPPORTED IN MATLAB]

% LINE

% line.color - [DONE]
% line.width - [DONE]
% line.dash - [DONE]
% line.opacity --- [TODO]
% line.smoothing - [NOT SUPPORTED IN MATLAB]
% line.shape - [NOT SUPPORTED IN MATLAB]

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(areaIndex).AssociatedAxis);

%-AREA DATA STRUCTURE- %
area_data = get(obj.State.Plot(areaIndex).Handle);

%-AREA CHILD DATA STRUCTURE- %
area_child_data = get(area_data.Children(1));

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,axIndex);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

%-------------------------------------------------------------------------%

%-area xaxis-%
obj.data{areaIndex}.xaxis = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

%-area yaxis-%
obj.data{areaIndex}.yaxis = ['y' num2str(ysource)];

%-------------------------------------------------------------------------%

%-area type-%
obj.data{areaIndex}.type = 'scatter';

%-------------------------------------------------------------------------%

%-area visible-%
obj.data{areaIndex}.visible = strcmp(area_child_data.Visible,'on');

%-------------------------------------------------------------------------%

%-area x-%
obj.data{areaIndex}.x = area_data.XData;

%-------------------------------------------------------------------------%

%-area y-%
ydata = area_child_data.YData;
obj.data{areaIndex}.y = ydata(2:(numel(ydata)-1)/2+1)';

%-------------------------------------------------------------------------%

%-area name-%
obj.data{areaIndex}.name = area_child_data.DisplayName;

%-------------------------------------------------------------------------%

%-area fill-%
obj.data{areaIndex}.fill = 'tonexty';

%-----------------------------!STYLE!-------------------------------------%

if ~obj.PlotOptions.Strip
    
%-area line-%
obj.data{areaIndex}.line = extractPatchLine(area_child_data); 

%-------------------------------------------------------------------------%
    
%-area mode-%
if ~strcmpi('none', area_child_data.Marker) && ~strcmpi('none', area_child_data.LineStyle)
    mode = 'lines+markers';
elseif ~strcmpi('none', area_child_data.Marker)
    mode = 'markers';
elseif ~strcmpi('none', area_child_data.LineStyle)
    mode = 'lines';
else
    mode = 'none';
end

obj.data{areaIndex}.mode = mode;

%-------------------------------------------------------------------------%

%-area marker-%
obj.data{areaIndex}.marker = extractPatchMarker(area_child_data); 

%-------------------------------------------------------------------------%

%-area showlegend-%
leg = get(area_child_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{areaIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

%-area fillcolor-%
fill = extractPatchFace(area_child_data); 
obj.data{areaIndex}.fillcolor = fill.color; 

%-------------------------------------------------------------------------%

end
end



