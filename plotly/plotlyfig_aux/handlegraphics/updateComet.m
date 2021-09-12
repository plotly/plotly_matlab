function updateComet(obj,plotIndex)

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
    if strcmpi(animObjs(i).Tag,'tail')
        tail = animObjs(i);
    end
    if strcmpi(animObjs(i).Tag,'body')
        body = animObjs(i);
    end
end

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,axIndex);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

%-------------------------------------------------------------------------%

%-getting data-%
[x,y,z] = getpoints(tail);

%-------------------------------------------------------------------------%

%-scatter xaxis-%
obj.data{plotIndex}.xaxis = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

%-scatter yaxis-%
obj.data{plotIndex}.yaxis = ['y' num2str(ysource)];

%-------------------------------------------------------------------------%

%-scatter type-%
obj.data{plotIndex}.type = 'scatter';

%-------------------------------------------------------------------------%

%-scatter visible-%
obj.data{plotIndex}.visible = strcmp(plot_data.Visible,'on');

%-------------------------------------------------------------------------%

%-scatter x-%
obj.data{plotIndex}.x = x(1);

%-------------------------------------------------------------------------%

%-scatter y-%
obj.data{plotIndex}.y = y(1);

%-------------------------------------------------------------------------%

%-For 3D plots-%
obj.PlotOptions.is3d = false; % by default

numbset = unique(z);
if numel(numbset)>1
    if any(z)
        %-scatter z-%
        obj.data{plotIndex}.z = z(1);
        
        %-overwrite type-%
        obj.data{plotIndex}.type = 'scatter3d';
        
        %-flag to manage 3d plots-%
        obj.PlotOptions.is3d = true;
    end
end

%-------------------------------------------------------------------------%

%-scatter name-%
obj.data{plotIndex}.name = plot_data.Tag;

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

switch(plot_data.Tag)
    case 'head'
        for i = 1:length(x)
            DD.x=[x(i) x(i)];
            DD.y=[y(i) y(i)];
            if obj.PlotOptions.is3d
                DD.z=[z(i) z(i)];
            end
            obj.frames{i}.data{plotIndex} = DD;
            obj.frames{i}.name=['f',num2str(i)];
        end
    case 'body'
        for i = 1:length(x)
            sIdx = i-animObj.MaximumNumPoints;
            if sIdx < 0
                sIdx=0;
            end
            DD.x=x(sIdx+1:i);
            DD.y=y(sIdx+1:i);
            if obj.PlotOptions.is3d
                DD.z=z(sIdx+1:i);
            end
            if i==length(x)
                DD.x=nan;
                DD.y=nan;
                if obj.PlotOptions.is3d
                    DD.z=nan;
                end
            end
            obj.frames{i}.data{plotIndex} = DD;
        end
    case 'tail'
        for i = 1:length(x)
            DD.x=x(1:i);
            DD.y=y(1:i);
            if obj.PlotOptions.is3d
                DD.z=z(1:i);
            end
            if i < body.MaximumNumPoints
                rIdx = i;
            else
                rIdx = body.MaximumNumPoints;
            end
            if i ~= length(x)
                val = nan(rIdx,1);
                DD.x(end-rIdx+1:end)=val;
                DD.y(end-rIdx+1:end)=val;
                if obj.PlotOptions.is3d
                    DD.z(end-rIdx+1:end)=val;
                end
            end
            obj.frames{i}.data{plotIndex} = DD;
        end
end
end