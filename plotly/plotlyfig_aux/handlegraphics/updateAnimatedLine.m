function updateAnimatedLine(obj,plotIndex)

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);

%-PLOT DATA STRUCTURE- %
plotData = get(obj.State.Plot(plotIndex).Handle);

animObjs = obj.State.Plot(plotIndex).AssociatedAxis.Children;

for i=1:numel(animObjs)
    if isequaln(get(animObjs(i)),plotData)
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
    x = plotData.XData;
    y = plotData.YData;
    z = plotData.ZData;
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
obj.data{plotIndex}.visible = strcmp(plotData.Visible,'on');

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

%-Add a temporary tag-%
obj.layout.isAnimation = true;

%-------------------------------------------------------------------------%

%-Create Frames-%
frameData = obj.data{plotIndex};

for i = 1:length(x)
    sIdx = i - plotData.MaximumNumPoints;
    if sIdx < 0
        sIdx=0;
    end
    frameData.x=x(sIdx+1:i);
    frameData.y=y(sIdx+1:i);
    obj.frames{i}.name = ['f',num2str(i)];
    obj.frames{i}.data{plotIndex} = frameData;
end

end