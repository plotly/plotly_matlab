function obj = updateContourgroup(obj,contourIndex)

% z: ...[DONE]
% x: ...[DONE]
% y: ...[DONE]
% name: ...[DONE]
% zauto: ...[DONE]
% zmin: ...[DONE]
% zmax: ...[DONE]
% autocontour: ...[DONE]
% ncontours: ...[N/A]
% contours: ...[DONE]
% colorscale: ...[DONE]
% reversescale: ...[DONE]
% showscale: ...[DONE]
% colorbar: ...[DONE]
% opacity: ...[NOT SUPPORTED IN MATLAB]
% xaxis: ...[DONE]
% yaxis: ...[DONE]
% showlegend: ...[DONE]
% stream: ...[HANDLED BY PLOTLYSTREAM]
% visible: ...[DONE]
% x0: ...[DONE]
% dx: ...[DONE]
% y0: ...[DONE]
% dy: ...[DONE]
% xtype: ...[DONE]
% ytype: ...[DONE]
% type: ...[DONE]

% line: ...[DONE]
% color: ...[DONE]
% width: ...[DONE]
% dash: ...[DONE]
% opacity: ...[NOT SUPPORTED IN MATLAB]
% shape: ...[NOT SUPPORTED IN MATLAB]
% smoothing: ...[DONE]
% outliercolor: ...[N/A]
% outlierwidth: ...[N/A]

%-FIGURE DATA STRUCTURE-%
figure_data = get(obj.State.Figure.Handle); 

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(contourIndex).AssociatedAxis);

%-AXIS DATA STRUCTURE-%
axis_data = get(obj.State.Plot(contourIndex).AssociatedAxis);

%-PLOT DATA STRUCTURE- %
contour_data = get(obj.State.Plot(contourIndex).Handle);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(axIndex) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(axIndex) ';']);

%-------------------------------------------------------------------------%

%-CONTOUR DATA TYPE-%
obj.data{contourIndex}.type = 'contour';

%-------------------------------------------------------------------------%

%-CONTOUR XAXIS-%
obj.data{contourIndex}.xaxis = ['x' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-CONTOUR YAXIS-%
obj.data{contourIndex}.yaxis = ['y' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-CONTOUR NAME-%
obj.data{contourIndex}.name = contour_data.DisplayName;

%-------------------------------------------------------------------------%

%-CONTOUR X DATA-%
if isvector(contour_data.XData)
    obj.data{contourIndex}.xtype = 'array';
    obj.data{contourIndex}.x = contour_data.XData(1):contour_data.XData(end);
else
    obj.data{contourIndex}.xtype = 'scaled';
    minx = min(min(contour_data.XData));
    maxx = max(max(contour_data.XData));
    obj.data{contourIndex}.x0 = minx;
    obj.data{contourIndex}.dx = (maxx-minx)/size(contour_data.ZData,1);
end

%-------------------------------------------------------------------------%

%-CONTOUR Y DATA-%
if isvector(contour_data.YData)
    obj.data{contourIndex}.ytype = 'array';
    obj.data{contourIndex}.y = contour_data.YData(1):contour_data.YData(end);
else
    obj.data{contourIndex}.ytype = 'scaled';
    miny = min(min(contour_data.YData));
    maxy = max(max(contour_data.YData));
    obj.data{contourIndex}.y0 = miny;
    obj.data{contourIndex}.dy = (maxy-miny)/size(contour_data.ZData,2);
end
%-------------------------------------------------------------------------%

%-CONTOUR Z DATA-%
obj.data{contourIndex}.z = contour_data.ZData;

%-------------------------------------------------------------------------%

%-ZAUTO-%

obj.data{contourIndex}.zauto = false; 

%-------------------------------------------------------------------------%

%-ZMIN-%

obj.data{contourIndex}.zmin = axis_data.CLim(1); 

%-------------------------------------------------------------------------%

%-ZMAX-%

obj.data{contourIndex}.zmax = axis_data.CLim(2); 

%-------------------------------------------------------------------------%

%-COLORSCALE (ASSUMES PATCH CDATAMAP IS 'SCALED')-%

colormap = figure_data.Colormap; 

for c = 1:length(colormap)
    col =  255*(colormap(c,:)); 
    obj.data{contourIndex}.colorscale{c} = {(c-1)/length(colormap), ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')']};
end

%-------------------------------------------------------------------------%

%-CONTOUR REVERSE SCALE-%
obj.data{contourIndex}.reversescale = false; 

%-------------------------------------------------------------------------%

%-AUTO CONTOUR-%
 
obj.data{contourIndex}.autocontour = false;

%-------------------------------------------------------------------------%

%-CONTOUR CONTOURS-%

%-COLORING-%

switch contour_data.Fill
    case 'off'
        obj.data{contourIndex}.contours.coloring = 'lines'; 
    case 'on'
        obj.data{contourIndex}.contours.coloring = 'fill';
end
        
%-START-%

obj.data{contourIndex}.contours.start = contour_data.LevelList(1);

%-STEP-%

obj.data{contourIndex}.contours.size = contour_data.LevelStep;

%-END-%

obj.data{contourIndex}.contours.end = contour_data.LevelList(end);

%-------------------------------------------------------------------------%

if(~strcmp(contour_data.LineStyle,'none'))
    
    %-CONTOUR LINE COLOR-%
    
    if isnumeric(contour_data.LineColor)
        col = 255*contour_data.LineColor;
        obj.data{contourIndex}.line.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')']; 
    else
        obj.data{contourIndex}.line.color = 'rgba(0,0,0,0)'; 
    end
    
    
    %-CONTOUR LINE WIDTH-%
    
    obj.data{contourIndex}.line.width = contour_data.LineWidth;
    
    %-CONTOUR LINE DASH-%
    
    switch contour_data.LineStyle
        case '-'
            LineStyle = 'solid';
        case '--'
            LineStyle = 'dash';
        case ':'
            LineStyle = 'dot';
        case '-.'
            LineStyle = 'dashdot';
    end
    
    obj.data{contourIndex}.line.dash = LineStyle;
    
    %-CONTOURS SMOOTHING-%
    obj.data{contourIndex}.line.smoothing = 0; 
    
else
  
    %-CONTOURS SHOWLINES-%
    obj.data{contourIndex}.contours.showlines = false; 
    
end

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

obj.data{contourIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

%-CONTOUR SHOWSCALE-%

obj.data{contourIndex}.showscale = false;

%-------------------------------------------------------------------------%

%-CONTOUR VISIBLE-%

obj.data{contourIndex}.visible = strcmp(contour_data.Visible,'on');

end
