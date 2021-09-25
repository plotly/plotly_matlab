%----UPDATE AXIS DATA/LAYOUT----%

function obj = updateAxis(obj,axIndex)

% title: ...[DONE]
% titlefont:...[DONE]
% range:...[DONE]
% domain:...[DONE]
% type:...[DONE]
% rangemode:...[NOT SUPPORTED IN MATLAB]
% autorange:...[DONE]
% showgrid:...[DONE]
% zeroline:...[DONE]
% showline:...[DONE
% autotick:...[DONE]
% nticks:...[DONE]
% ticks:...[DONE]
% showticklabels:...[DONE]
% tick0:...[DONE]
% dtick:...[DONE]
% ticklen:...[DONE]
% tickwidth:...[DONE]
% tickcolor:...[DONE]
% tickangle:...[NOT SUPPORTED IN MATLAB]
% tickfont:...[DONE]
% tickfont.family...[DONE]
% tickfont.size...[DONE]
% tickfont.color...[DONE]
% tickfont.outlinecolor...[NOT SUPPORTED IN MATLAB]
% exponentformat:...[DONE]
% showexponent:...[NOT SUPPORTED IN MATLAB]
% mirror:...[DONE]
% gridcolor:...[DONE]
% gridwidth:...[DONE]
% zerolinecolor:...[NOT SUPPORTED IN MATLAB]
% zerolinewidth:...[NOT SUPPORTED IN MATLAB]
% linecolor:...[DONE]
% linewidth:...[DONE]
% anchor:...[DONE]
% overlaying:...[DONE]
% side:...[DONE]
% position:...[NOT SUPPORTED IN MATLAB]

%-STANDARDIZE UNITS-%
axisunits = get(obj.State.Axis(axIndex).Handle,'Units');
set(obj.State.Axis(axIndex).Handle,'Units','normalized')

try
    fontunits = get(obj.State.Axis(axIndex).Handle,'FontUnits');
    set(obj.State.Axis(axIndex).Handle,'FontUnits','points')
catch
    % TODO
end

%-AXIS DATA STRUCTURE-%
axis_data = get(obj.State.Axis(axIndex).Handle);

%-------------------------------------------------------------------------%

%-check if headmap axis-%
is_headmap_axis = isfield(axis_data, 'XDisplayData');
obj.PlotOptions.is_headmap_axis = is_headmap_axis;

%-------------------------------------------------------------------------%

%-check if geo-axis-%
isGeoaxis = isfield(axis_data, 'Type') && strcmpi(axis_data.Type, 'geoaxes');
obj.PlotlyDefaults.isGeoaxis = isGeoaxis;

%-------------------------------------------------------------------------%

%-xaxis-%
if is_headmap_axis
    xaxis = extractHeatmapAxisData(obj,axis_data, 'X');
else
    xaxis = extractAxisData(obj,axis_data, 'X');
end

%-------------------------------------------------------------------------%

%-yaxis-%
if is_headmap_axis
    yaxis = extractHeatmapAxisData(obj,axis_data, 'Y');
else
    yaxis = extractAxisData(obj,axis_data, 'Y');
end

%-------------------------------------------------------------------------%

%-getting and setting postion data-%

xo = axis_data.Position(1);
yo = axis_data.Position(2);
w = axis_data.Position(3);
h = axis_data.Position(4);

if obj.PlotOptions.AxisEqual
    wh = min(axis_data.Position(3:4));
    w = wh;
    h = wh;
end

%-------------------------------------------------------------------------%

%-xaxis domain-%
xaxis.domain = min([xo xo + w],1);
scene.domain.x = min([xo xo + w],1);

%-------------------------------------------------------------------------%

%-yaxis domain-%
yaxis.domain = min([yo yo + h],1);
scene.domain.y = min([yo yo + h],1);

%-------------------------------------------------------------------------%

[xsource, ysource, xoverlay, yoverlay] = findSourceAxis(obj,axIndex);

%-------------------------------------------------------------------------%

%-xaxis anchor-%
xaxis.anchor = ['y' num2str(ysource)];

%-------------------------------------------------------------------------%

%-yaxis anchor-%
yaxis.anchor = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

%-xaxis overlaying-%
if xoverlay
    xaxis.overlaying = ['x' num2str(xoverlay)];
end

%-------------------------------------------------------------------------%

%-yaxis overlaying-%
if yoverlay
    yaxis.overlaying = ['y' num2str(yoverlay)];
end

%-------------------------------------------------------------------------%

% update the layout field (do not overwrite source)
if xsource == axIndex
    obj.layout = setfield(obj.layout,['xaxis' num2str(xsource)],xaxis);
    obj.layout = setfield(obj.layout,['scene' num2str(xsource)],scene);
else
    
end

%-------------------------------------------------------------------------%

% update the layout field (do not overwrite source)
if ysource == axIndex
    obj.layout = setfield(obj.layout,['yaxis' num2str(ysource)],yaxis);
else
    
end

%-------------------------------------------------------------------------%

%-REVERT UNITS-%
set(obj.State.Axis(axIndex).Handle,'Units',axisunits);

try
    set(obj.State.Axis(axIndex).Handle,'FontUnits',fontunits);
catch
    % TODO
end
