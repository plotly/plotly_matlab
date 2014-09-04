function obj = updateBarseries(obj,dataIndex)

% x: ...[DONE]
% y: ...[DONE]
% name: ...[DONE]
% orientation: ...[NOT SUPPORTED IN MATLAB]
% text: ...[NOT SUPPORTED IN MATLAB]
% error_y: ...[HANDLED BY ERRORBAR]
% error_x: ...[HANDLED BY ERRORBAR]
% opacity: ...[DONE]
% xaxis: ...[DONE]
% yaxis: ...[DONE]
% showlegend: ...[DONE]
% stream: ...[HANDLED BY PLOTLY STREAM]
% visible: ...[DONE]
% type: ...[DONE]
% r: ...[NA]
% t: ...[NA]
% textfont: ...[NA]

% MARKER:
% color: .............[TODO]
% size: ...[NA]
% symbol: ...[NA]
% opacity: ...[NA]
% sizeref: ...[NA]
% sizemode: ...[NA]
% colorscale: ...[NA]
% cauto: ...[NA]
% cmin: ...[NA]
% cmax: ...[NA]
% outliercolor: ...[NA]
% maxdisplayed: ...[NA]

% MARKER LINE:
% color: ........[TODO]
% width: ...[DONE]
% dash: ...[NA]
% opacity: ...[NA]
% shape: ...[NA]
% smoothing: ...[NA]
% outliercolor: ...[NA]
% outlierwidth: ...[NA]

% LINE:
% color: ........[N/A]
% width: ...[NA]
% dash: ...[NA]
% opacity: ...[NA]
% shape: ...[NA]
% smoothing: ...[NA]
% outliercolor: ...[NA]
% outlierwidth: ...[NA]


%-------------------------------------------------------------------------%

%-FIGURE STRUCTURE-%
figure_data = get(obj.State.Figure.Handle);

%-AXIS STRUCTURE-%
axis_data = get(obj.State.Plot(dataIndex).AssociatedAxis);

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);

%-BAR DATA STRUCTURE- %
bar_data = get(obj.State.Plot(dataIndex).Handle);

%-BAR CHILD (PATCH) DATA STRUCTURE- %
bar_child_data = get(bar_data.Children(1));

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(axIndex) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(axIndex) ';']);

%-------------------------------------------------------------------------%

%-BAR XAXIS-%
obj.data{dataIndex}.xaxis = ['x' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-BAR YAXIS-%
obj.data{dataIndex}.yaxis = ['y' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-BAR TYPE-%
obj.data{dataIndex}.type = 'bar';

%-------------------------------------------------------------------------%

%-bar x data-%
obj.data{dataIndex}.x = bar_data.XData;

%-------------------------------------------------------------------------%

%-bar y data-%
obj.data{dataIndex}.y = bar_data.YData;

%-------------------------------------------------------------------------%

%-bar name-%
obj.data{dataIndex}.name = bar_data.DisplayName;

%-------------------------------------------------------------------------%

%-layout barmode-%
switch bar_data.BarLayout
    case 'grouped'
        obj.layout.barmode = 'group';
    case 'stacked'
        obj.layout.barmode = 'stack';
end

%-------------------------------------------------------------------------%

%-layout bargap-%
obj.layout.bargap = 1-bar_data.BarWidth;

%-------------------------------------------------------------------------%

%-bar line width-%
bobj.data{dataIndex}.marker.line.width = bar_child_data.LineWidth;

%-------------------------------------------------------------------------%

%-BAR SHOWLEGEND-%
leg = get(bar_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{dataIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

%-bar visible-%
obj.data{dataIndex}.visible = strcmp(bar_data.Visible,'on');

%-------------------------------------------------------------------------%

%-bar opacity-%
if ~ischar(bar_child_data.FaceAlpha)
    obj.data{dataIndex}.opacity = bar_child_data.FaceAlpha;
end

%-------------------------------------------------------------------------%

%-bar face color-%

%-bar edge color-%








%     m_child = get(d.Children(1));
%     if isfield(m_child, 'CData')
%         color_ref = m_child.CData;
%     else
%         color_ref = m_child.Color;
%     end
%
%     color_field=[];
%     if isfield(d, 'Color')
%         color_field = d.Color;
%     else
%         if isfield(d, 'EdgeColor')
%             color_field = d.EdgeColor;
%         end
%     end
%     colors = setColorProperty(color_field, color_ref, CLim, colormap,d);
%     if numel(colors{1})>0
%         data.marker.line.color = colors{1};
%     end
%
%     color_field=[];
%     if isfield(d, 'Color')
%         color_field = d.Color;
%     else
%         if isfield(d, 'FaceColor')
%             color_field = d.FaceColor;
%         end
%     end
%     colors = setColorProperty(color_field, color_ref, CLim, colormap,d);
%     if numel(colors{1})>0
%         data.marker.color = colors{1};
%     end

end
