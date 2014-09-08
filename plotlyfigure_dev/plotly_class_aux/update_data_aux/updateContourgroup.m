function obj = updateContourgroup(obj,dataIndex)

% z: .................[TODO]
% x: .................[TODO]
% y: .................[TODO]
% name: ...[DONE]
% zauto: .................[TODO]
% zmin: .................[TODO]
% zmax: .................[TODO]
% autocontour: .................[TODO]
% ncontours: .................[TODO]
% contours: .................[TODO]
% line: .................[TODO]
% colorscale: .................[TODO]
% reversescale: .................[TODO]
% showscale: .................[TODO]
% colorbar: .................[TODO]
% opacity: .................[TODO]
% xaxis: ...[DONE]
% yaxis: ...[DONE]
% showlegend: ...[DONE]
% stream: ...[HANDLED BY PLOTLYSTREAM]
% visible: ...[DONE]
% x0: .................[TODO]
% dx: .................[TODO]
% y0: .................[TODO]
% dy: .................[TODO]
% xtype: .................[TODO]
% ytype: .................[TODO]
% type: ...[DONE]


%-FIGURE STRUCTURE-%
figure_data = get(obj.State.Figure.Handle);

%-AXIS STRUCTURE-%
axis_data = get(obj.State.Plot(dataIndex).AssociatedAxis);

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);

%-PLOT DATA STRUCTURE- %
contour_data = get(obj.State.Plot(dataIndex).Handle);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(axIndex) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(axIndex) ';']);

%-------------------------------------------------------------------------%

%-CONTOUR XAXIS-%
obj.data{dataIndex}.xaxis = ['x' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-CONTOUR YAXIS-%
obj.data{dataIndex}.yaxis = ['y' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-CONTOUR DATA TYPE-%
obj.data{dataIndex}.type = 'contour';

%-------------------------------------------------------------------------%

%-CONTOUR Z DATA-%
obj.data{dataIndex}.z = contour_data.ZData;
obj.data{dataIndex}.zauto = true;

%-------------------------------------------------------------------------%

%-CONTOUR X DATA-%
minx = min(min(contour_data.XData));
maxx = max(max(contour_data.XData));
obj.data{dataIndex}.x0 = minx;
obj.data{dataIndex}.dx = (maxx-minx)/size(contour_data.ZData,1);

%-------------------------------------------------------------------------%

%-CONTOUR Y DATA-%
miny = min(min(contour_data.YData));
maxy = max(max(contour_data.YData));
obj.data{dataIndex}.y0 = miny;
obj.data{dataIndex}.dy = (maxy-miny)/size(contour_data.ZData,2);

%-------------------------------------------------------------------------%

%-CONTOUR CONTOURS-%

obj.data{dataIndex}.contours.coloring = 'lines';
obj.data{dataIndex}.contours.start = contour_data.LevelList(1);
obj.data{dataIndex}.contours.size = contour_data.LevelStep;
obj.data{dataIndex}.contours.end = contour_data.LevelList(end);

%-------------------------------------------------------------------------%

%-AUTO CONTOUR-%
obj.data{dataIndex}.autocontour = false;

%-------------------------------------------------------------------------%

%-CONTOUR SHOWLEGEND-%
leg = get(contour_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{dataIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

%-CONTOUR VISIBLE-%
obj.data{dataIndex}.visible = strcmp(contour_data.Visible,'on');

end