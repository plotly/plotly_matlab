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
axisUnits = get(obj.State.Axis(axIndex).Handle,'Units');
set(obj.State.Axis(axIndex).Handle,'Units','normalized')

try
    fontUnits = get(obj.State.Axis(axIndex).Handle,'FontUnits');
    set(obj.State.Axis(axIndex).Handle,'FontUnits','points')
catch
    % TODO
end

%-AXIS DATA STRUCTURE-%
axisData = get(obj.State.Axis(axIndex).Handle);

%-------------------------------------------------------------------------%

%-check if headmap axis-%
is_headmap_axis = isfield(axisData, 'XDisplayData');
obj.PlotOptions.is_headmap_axis = is_headmap_axis;

%-------------------------------------------------------------------------%

%-check if geo-axis-%
isGeoaxis = isfield(axisData, 'Type') && strcmpi(axisData.Type, 'geoaxes');
obj.PlotlyDefaults.isGeoaxis = isGeoaxis;

%-------------------------------------------------------------------------%

%-xaxis-%
if is_headmap_axis
    xaxis = extractHeatmapAxisData(obj,axisData, 'X');
    xExponentFormat = 0;
else
    [xaxis, xExponentFormat] = extractAxisData(obj,axisData, 'X');
end

%-------------------------------------------------------------------------%

%-yaxis-%
if is_headmap_axis
    yaxis = extractHeatmapAxisData(obj,axisData, 'Y');
    yExponentFormat = 0;
else
    [yaxis, yExponentFormat] = extractAxisData(obj,axisData, 'Y');
end

%-------------------------------------------------------------------------%

%-get position data-%
axisPos = axisData.Position .* obj.PlotOptions.DomainFactor;
if obj.PlotOptions.AxisEqual, axisPos(3:4) = min(axisPos(3:4)); end

%-------------------------------------------------------------------------%

%-xaxis domain-%
xaxis.domain = min([axisPos(1) sum(axisPos([1,3]))], 1);
scene.domain.x = xaxis.domain;

%-------------------------------------------------------------------------%

%-yaxis domain-%
yaxis.domain = min([axisPos(2) sum(axisPos([2,4]))], 1);
scene.domain.y = yaxis.domain;

%-------------------------------------------------------------------------%

%-get source axis-%
[xsource, ysource, xoverlay, yoverlay] = findSourceAxis(obj,axIndex);

%-------------------------------------------------------------------------%

%-set exponent format-%
anIndex = obj.State.Figure.NumTexts;

if yExponentFormat ~= 0
    anIndex = anIndex + 1;
    exponentText = sprintf('x10^%d', yExponentFormat);

    obj.layout.annotations{anIndex}.text = exponentText;
    obj.layout.annotations{anIndex}.xref = ['x' num2str(xsource)];
    obj.layout.annotations{anIndex}.yref = ['y' num2str(ysource)];
    obj.layout.annotations{anIndex}.xanchor = 'left';
    obj.layout.annotations{anIndex}.yanchor = 'bottom';
    obj.layout.annotations{anIndex}.font.size = yaxis.tickfont.size;
    obj.layout.annotations{anIndex}.font.color = yaxis.tickfont.color;
    obj.layout.annotations{anIndex}.font.family = yaxis.tickfont.family;
    obj.layout.annotations{anIndex}.showarrow = false;

    if isfield(xaxis, 'range') && isfield(yaxis, 'range')
        obj.layout.annotations{anIndex}.x = min(xaxis.range);
        obj.layout.annotations{anIndex}.y = max(yaxis.range);
    end
end

if xExponentFormat ~= 0
    anIndex = anIndex + 1;
    exponentText = sprintf('x10^%d', xExponentFormat);

    obj.layout.annotations{anIndex}.text = exponentText;
    obj.layout.annotations{anIndex}.xref = ['x' num2str(xsource)];
    obj.layout.annotations{anIndex}.yref = ['y' num2str(ysource)];
    obj.layout.annotations{anIndex}.xanchor = 'left';
    obj.layout.annotations{anIndex}.yanchor = 'bottom';
    obj.layout.annotations{anIndex}.font.size = xaxis.tickfont.size;
    obj.layout.annotations{anIndex}.font.color = xaxis.tickfont.color;
    obj.layout.annotations{anIndex}.font.family = xaxis.tickfont.family;
    obj.layout.annotations{anIndex}.showarrow = false;

    if isfield(xaxis, 'range') && isfield(yaxis, 'range')
        obj.layout.annotations{anIndex}.x = max(xaxis.range);
        obj.layout.annotations{anIndex}.y = min(yaxis.range);
    end
end

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
end

%-------------------------------------------------------------------------%

% update the layout field (do not overwrite source)
if ysource == axIndex
    obj.layout = setfield(obj.layout,['yaxis' num2str(ysource)],yaxis);
end

%-------------------------------------------------------------------------%

%-REVERT UNITS-%
set(obj.State.Axis(axIndex).Handle,'Units',axisUnits);

try
    set(obj.State.Axis(axIndex).Handle,'FontUnits',fontUnits);
catch
    % TODO
end
