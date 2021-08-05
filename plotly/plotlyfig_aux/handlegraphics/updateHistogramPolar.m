function obj = updateHistogramPolar(obj,histIndex)

% x:...[DONE]
% y:...[DONE]
% histnorm:...[DONE]
% name:...[DONE]
% autobinx:...[DONE]
% nbinsx:...[DONE]
% xbins:...[DONE]
% autobiny:...[DONE]
% nbinsy:...[DONE]
% ybins:...[DONE]
% text:...[NOT SUPPORTED IN MATLAB]
% error_y:...[HANDLED BY ERRORBARSERIES]
% error_x:...[HANDLED BY ERRORBARSERIES]
% opacity: --- [TODO]
% xaxis:...[DONE]
% yaxis:...[DONE]
% showlegend:...[DONE]
% stream:...[HANDLED BY PLOTLYSTREAM]
% visible:...[DONE]
% type:...[DONE]
% orientation:...[DONE]

% MARKER:
% color: ...[DONE]
% size: ...[NA]
% symbol: ...[NA]
% opacity: ...[TODO]
% sizeref: ...[NA]
% sizemode: ...[NA]
% colorscale: ...[NA]
% cauto: ...[NA]
% cmin: ...[NA]
% cmax: ...[NA]
% outliercolor: ...[NA]
% maxdisplayed: ...[NA]

% MARKER LINE:
% color: ...[DONE]
% width: ...[DONE]
% dash: ...[NA]
% opacity: ...[TODO]
% shape: ...[NA]
% smoothing: ...[NA]
% outliercolor: ...[NA]
% outlierwidth: ...[NA]

%-------------------------------------------------------------------------%

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(histIndex).AssociatedAxis);

%-HIST DATA STRUCTURE- %
hist_data = get(obj.State.Plot(histIndex).Handle);

%-------------------------------------------------------------------------%

%-barpolar type-%
obj.data{histIndex}.type = 'barpolar';

%-------------------------------------------------------------------------%

%-barpolar data-%
binedges = rad2deg(hist_data.BinEdges);
obj.data{histIndex}.theta = binedges(1:end-1) + 0.5*diff(binedges);
obj.data{histIndex}.width = diff(binedges);
obj.data{histIndex}.r = double(hist_data.BinCounts);

%-------------------------------------------------------------------------%

%-hist name-%
obj.data{histIndex}.name = hist_data.DisplayName;

%-------------------------------------------------------------------------%

%-layout barmode-%
obj.layout.barmode = 'group';

%-------------------------------------------------------------------------%

%-hist line width-%
obj.data{histIndex}.marker.line.width = hist_data.LineWidth;

%-------------------------------------------------------------------------%

%-hist opacity-%
if ~ischar(hist_data.FaceAlpha)
    obj.data{histIndex}.opacity = hist_data.FaceAlpha;
end

%-------------------------------------------------------------------------%

obj.data{histIndex}.marker = extractPatchFace(hist_data);

%-------------------------------------------------------------------------%

%-hist visible-%
obj.data{histIndex}.visible = strcmp(hist_data.Visible,'on');

%-------------------------------------------------------------------------%

%-hist showlegend-%
leg = get(hist_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{histIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

end
