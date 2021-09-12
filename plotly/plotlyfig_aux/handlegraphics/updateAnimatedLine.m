function updateAnimatedLine(obj,plotIndex)

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
plot_data = get(obj.State.Plot(plotIndex).Handle);

animObjs = obj.State.Plot(plotIndex).AssociatedAxis.Children;

for i=1:numel(animObjs)
    if isequaln(get(animObjs(i)),plot_data)
        animObj = animObjs(i);
    end
end

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,axIndex);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

%-------------------------------------------------------------------------%

%-if polar plot or not-%
treatas = obj.PlotOptions.TreatAs;
ispolar = strcmpi(treatas, 'compass') || strcmpi(treatas, 'ezpolar');

%-------------------------------------------------------------------------%

%-getting data-%
try
    [x,y,z] = getpoints(animObj);
catch
    x=plot_data.XData;
    y=plot_data.YData;
    z=plot_data.ZData;
end

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
obj.data{plotIndex}.visible = strcmp(plot_data.Visible,'on');

%-------------------------------------------------------------------------%

%-scatter x-%

if ispolar
    r = sqrt(x.^2 + y.^2);
    obj.data{plotIndex}.r = r;
else
    obj.data{plotIndex}.x = [x(1) x(1)];
end

%-------------------------------------------------------------------------%

%-scatter y-%
if ispolar
    theta = atan2(x,y);
    obj.data{plotIndex}.theta = -(rad2deg(theta) - 90);
else
    obj.data{plotIndex}.y = [y(1) y(1)];
end

%-------------------------------------------------------------------------%

%-For 3D plots-%
obj.PlotOptions.is3d = false; % by default

numbset = unique(z);
if numel(numbset)>1
    if any(z)
        %-scatter z-%
        obj.data{plotIndex}.z = [z(1) z(1)];
        
        %-overwrite type-%
        obj.data{plotIndex}.type = 'scatter3d';
        
        %-flag to manage 3d plots-%
        obj.PlotOptions.is3d = true;
    end
end

%-------------------------------------------------------------------------%

%-scatter name-%
obj.data{plotIndex}.name = plot_data.DisplayName;

%-------------------------------------------------------------------------%

%-scatter mode-%
if ~strcmpi('none', plot_data.Marker) ...
        && ~strcmpi('none', plot_data.LineStyle)
    mode = 'lines+markers';
elseif ~strcmpi('none', plot_data.Marker)
    mode = 'markers';
elseif ~strcmpi('none', plot_data.LineStyle)
    mode = 'lines';
else
    mode = 'none';
end

obj.data{plotIndex}.mode = mode;

%-------------------------------------------------------------------------%

%-scatter line-%
obj.data{plotIndex}.line = extractLineLine(plot_data);

%-------------------------------------------------------------------------%

%-scatter marker-%
obj.data{plotIndex}.marker = extractLineMarker(plot_data);

%-------------------------------------------------------------------------%

%-scatter showlegend-%
leg = get(plot_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{plotIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

%-Add a temporary tag-%
obj.layout.isAnimation = true;

%-------------------------------------------------------------------------%

%-Create Frames-%
DD = obj.data{plotIndex};

for i = 1:length(x)
    sIdx = i - plot_data.MaximumNumPoints;
    if sIdx < 0
        sIdx=0;
    end
    DD.x=x(sIdx+1:i);
    DD.y=y(sIdx+1:i);
    obj.frames{i}.name = ['f',num2str(i)];
    obj.frames{i}.data{plotIndex} = DD;
end

end