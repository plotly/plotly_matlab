function obj = updateContour3(obj,contourIndex)


%-FIGURE DATA STRUCTURE-%
figure_data = get(obj.State.Figure.Handle);

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(contourIndex).AssociatedAxis);

%-AXIS DATA STRUCTURE-%
axis_data = get(obj.State.Plot(contourIndex).AssociatedAxis);

%-PLOT DATA STRUCTURE- %
contour_data = get(obj.State.Plot(contourIndex).Handle);

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,axIndex);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

%-------------------------------------------------------------------------%

%-contour xaxis-%
obj.data{contourIndex}.xaxis = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

%-contour yaxis-%
obj.data{contourIndex}.yaxis = ['y' num2str(ysource)];

%-------------------------------------------------------------------------%

%-contour name-%
obj.data{contourIndex}.name = contour_data.DisplayName;

%-------------------------------------------------------------------------%

%-setting the plot-%
xdata = contour_data.XData;
ydata = contour_data.YData;
zdata = contour_data.ZData;
    
%---------------------------------------------------------------------%

%-contour type-%
obj.data{contourIndex}.type = 'surface';

%---------------------------------------------------------------------%

%-contour x and y data
if isvector(xdata)
    [xdata, ydata] = meshgrid(xdata, ydata);
end
obj.data{contourIndex}.x = xdata;
obj.data{contourIndex}.y = ydata;

%---------------------------------------------------------------------%

%-contour z data-%
obj.data{contourIndex}.z = zdata;

%---------------------------------------------------------------------%

%-setting for contour lines z-direction-%
if length(contour_data.LevelList) > 1
    zstart = contour_data.TextList(1);
    zend = contour_data.TextList(end);
    zsize = mean(diff(contour_data.TextList));
else
    zstart = contour_data.TextList(1) - 1e-3;
    zend = contour_data.TextList(end) + 1e-3;
    zsize = 2e-3;
end

obj.data{contourIndex}.contours.z.start = zstart;
obj.data{contourIndex}.contours.z.end = zend;
obj.data{contourIndex}.contours.z.size = zsize;
obj.data{contourIndex}.contours.z.show = true;
obj.data{contourIndex}.contours.z.usecolormap = true;
obj.data{contourIndex}.contours.z.width = 2*contour_data.LineWidth;
obj.data{contourIndex}.hidesurface = true;

%---------------------------------------------------------------------%

%-colorscale-%
colormap = figure_data.Colormap;

for c = 1:size((colormap),1)
    col =  255*(colormap(c,:));
    obj.data{contourIndex}.colorscale{c} = {(c-1)/(size(colormap,1)-1), ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')']};
end

%---------------------------------------------------------------------%

%-aspect ratio-%
ar = obj.PlotOptions.AspectRatio;

if ~isempty(ar)
    if ischar(ar)
        obj.layout.scene.aspectmode = ar;
    elseif isvector(ar) && length(ar) == 3
        xar = ar(1);
        yar = ar(2);
        zar = ar(3);
    end
else

    %-define as default-%
    xar = max(xdata(:));
    yar = max(ydata(:));
    zar = 0.7*max([xar, yar]);
end

obj.layout.scene.aspectratio.x = xar;
obj.layout.scene.aspectratio.y = yar;
obj.layout.scene.aspectratio.z = zar;

%---------------------------------------------------------------------%

%-camera eye-%
ey = obj.PlotOptions.CameraEye;

if ~isempty(ey)
    if isvector(ey) && length(ey) == 3
        obj.layout.scene.camera.eye.x = ey(1);
        obj.layout.scene.camera.eye.y = ey(2);
        obj.layout.scene.camera.eye.z = ey(3);
    end
else

    %-define as default-%
    xey = - xar; if xey>0 xfac = -0.2; else xfac = 0.2; end
    yey = - yar; if yey>0 yfac = -0.2; else yfac = 0.2; end
    if zar>0 zfac = 0.2; else zfac = -0.2; end
    
    obj.layout.scene.camera.eye.x = xey + xfac*xey; 
    obj.layout.scene.camera.eye.y = yey + yfac*yey;
    obj.layout.scene.camera.eye.z = zar + zfac*zar;
end

%---------------------------------------------------------------------%

%-zerolines hidded-%
obj.layout.scene.xaxis.zeroline = false;
obj.layout.scene.yaxis.zeroline = false;
obj.layout.scene.zaxis.zeroline = false;

%-------------------------------------------------------------------------%

%-contour visible-%
obj.data{contourIndex}.visible = strcmp(contour_data.Visible,'on');

%-------------------------------------------------------------------------%

%-contour showscale-%
obj.data{contourIndex}.showscale = false;

%-------------------------------------------------------------------------%

%-contour reverse scale-%
obj.data{contourIndex}.reversescale = false;

%-------------------------------------------------------------------------%

%-contour showlegend-%

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

end
