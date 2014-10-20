function updateArea(obj,areaIndex)

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
% marker.color - [NOT SUPPORTED IN MATLAB]
% marker.size - [NOT SUPPORTED IN MATLAB]
% marker.line.color - [NOT SUPPORTED IN MATLAB]
% marker.line.width - [NOT SUPPORTED IN MATLAB]
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
obj.data{areaIndex}.visible = strcmp(area_data.Visible,'on');

%-------------------------------------------------------------------------%

%-area x-%
obj.data{areaIndex}.x = area_data.XData;

%-------------------------------------------------------------------------%

%-area y-%
obj.data{areaIndex}.y = area_data.YData;

%-------------------------------------------------------------------------%

%-area name-%
obj.data{areaIndex}.name = area_data.DisplayName;

%-------------------------------------------------------------------------%

%-area fill-%
obj.data{areaIndex}.fill = 'tonexty';

%-----------------------------!STYLE!-------------------------------------%

if ~obj.PlotOptions.Strip
    
%-area line-%
obj.data{areaIndex}.line = extractPatchLine(area_data); 

%-------------------------------------------------------------------------%
    
%-area mode-%
obj.data{areaIndex}.mode = 'lines';

%-------------------------------------------------------------------------%

%-area showlegend-%
leg = get(area_data.Annotation);
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
fill = extractPatchFace(area_data); 
obj.data{areaIndex}.fillcolor = fill.color; 

%-------------------------------------------------------------------------%

end
end



