function updateLineseries(obj,plotIndex)

%----SCATTER FIELDS----%

% x - [DONE]
% y - [DONE]
% r - [HANDLED BY SCATTER]
% t - [HANDLED BY SCATTER]
% mode - [DONE]
% name - [NOT SUPPORTED IN MATLAB]
% text - [DONE]
% error_y - [HANDLED BY ERRORBAR]
% error_x - [NOT SUPPORTED IN MATLAB]
% connectgaps - [NOT SUPPORTED IN MATLAB]
% fill - [HANDLED BY AREA]
% fillcolor - [HANDLED BY AREA]
% opacity --- [TODO]
% textfont - [NOT SUPPORTED IN MATLAB]
% textposition - [NOT SUPPORTED IN MATLAB]
% xaxis [DONE]
% yaxis [DONE]
% showlegend [DONE]
% stream - [HANDLED BY PLOTLYSTREAM]
% visible [DONE]
% type [DONE]

% MARKER
% marler.color - [DONE]
% marker.size - [DONE]
% marker.line.color - [DONE]
% marker.line.width - [DONE]
% marker.line.dash - [NOT SUPPORTED IN MATLAB]
% marker.line.opacity - [NOT SUPPORTED IN MATLAB]
% marker.line.smoothing - [NOT SUPPORTED IN MATLAB]
% marker.line.shape - [NOT SUPPORTED IN MATLAB]
% marker.opacity --- [TODO]
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

%-------------------------------------------------------------------------%

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);

%-PLOT DATA STRUCTURE- %
plotData = get(obj.State.Plot(plotIndex).Handle);

%-CHECK FOR MULTIPLE AXES-%
try
    for yax = 1:2
        yaxIndex(yax) = sum(plotData.Parent.YAxis(yax).Color == plotData.Color);
    end

    [~, yaxIndex] = max(yaxIndex);
    [xsource, ysource] = findSourceAxis(obj, axIndex, yaxIndex);

catch
    [xsource, ysource] = findSourceAxis(obj,axIndex);
end

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

%-------------------------------------------------------------------------%

%-if polar plot or not-%
treatas = obj.PlotOptions.TreatAs;
ispolar = ismember('compass', lower(treatas)) || ismember('ezpolar', lower(treatas));

%-------------------------------------------------------------------------%

%-getting data-%
x = plotData.XData;
y = plotData.YData;

%-------------------------------------------------------------------------%

%-scatter xaxis-%
obj.data{plotIndex}.xaxis = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

%-scatter yaxis-%
obj.data{plotIndex}.yaxis = ['y' num2str(ysource)];

%-------------------------------------------------------------------------%

%-scatter type-%
obj.data{plotIndex}.type = 'scatter';

if ispolar
    obj.data{plotIndex}.type = 'scatterpolar';
end

%-------------------------------------------------------------------------%

%-scatter visible-%
obj.data{plotIndex}.visible = strcmp(plotData.Visible,'on');

%-------------------------------------------------------------------------%

%-scatter x-%

if ispolar
    r = sqrt(x.^2 + y.^2);
    obj.data{plotIndex}.r = r;
else
    obj.data{plotIndex}.x = x;
end

%-------------------------------------------------------------------------%

%-scatter y-%
if ispolar
    theta = atan2(x,y);
    obj.data{plotIndex}.theta = -(rad2deg(theta) - 90);
else
    obj.data{plotIndex}.y = plotData.YData;
end

%-------------------------------------------------------------------------%

%-Fro 3D plots-%
obj.PlotOptions.is3d = false; % by default

if isfield(plotData,'ZData')
    
    numbset = unique(plotData.ZData);
    
    if any(plotData.ZData) && length(numbset)>1
        %-scatter z-%
        obj.data{plotIndex}.z = plotData.ZData;
        
        %-overwrite type-%
        obj.data{plotIndex}.type = 'scatter3d';
        
        %-flag to manage 3d plots-%
        obj.PlotOptions.is3d = true;
    end
end

%-------------------------------------------------------------------------%

%-scatter name-%
obj.data{plotIndex}.name = plotData.DisplayName;

%-------------------------------------------------------------------------%

%-scatter mode-%
if ~strcmpi('none', plotData.Marker) ...
        && ~strcmpi('none', plotData.LineStyle)
    mode = 'lines+markers';
elseif ~strcmpi('none', plotData.Marker)
    mode = 'markers';
elseif ~strcmpi('none', plotData.LineStyle)
    mode = 'lines';
else
    mode = 'none';
end

obj.data{plotIndex}.mode = mode;

%-------------------------------------------------------------------------%

%-scatter line-%
obj.data{plotIndex}.line = extractLineLine(plotData);

%-------------------------------------------------------------------------%

%-scatter marker-%
obj.data{plotIndex}.marker = extractLineMarker(plotData);

%-------------------------------------------------------------------------%

%-scatter showlegend-%
leg = get(plotData.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{plotIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

end