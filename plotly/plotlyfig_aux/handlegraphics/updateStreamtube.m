function obj = updateStreamtube(obj, surfaceIndex)
  if strcmpi(obj.State.Plot(surfaceIndex).Class, 'surface')
    updateSurfaceStreamtube(obj, surfaceIndex)
  end
end

function updateSurfaceStreamtube(obj, surfaceIndex)

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(surfaceIndex).AssociatedAxis);

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,axIndex);

%-SURFACE DATA STRUCTURE- %
image_data = get(obj.State.Plot(surfaceIndex).Handle);
figure_data = get(obj.State.Figure.Handle);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

%-------------------------------------------------------------------------%

%-surface xaxis-%
obj.data{surfaceIndex}.xaxis = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

%-surface yaxis-%
obj.data{surfaceIndex}.yaxis = ['y' num2str(ysource)];

    
%---------------------------------------------------------------------%

%-surface type-%
obj.data{surfaceIndex}.type = 'surface';

%---------------------------------------------------------------------%

%-getting plot data-%
x = image_data.XData;
y = image_data.YData;
z = image_data.ZData;
cdata = image_data.CData;

%-playing with level quality-%
quality = obj.PlotOptions.Quality/100;
apply_quality = quality > 0;

if apply_quality
    x = imresize(x, quality);
    y = imresize(y, quality);
    z = imresize(z, quality);
    cdata = imresize(cdata, quality);
end

if ~isempty(obj.PlotOptions.Zmin)
    if any(z < obj.PlotOptions.Zmin)
        return;
    end
end

xymax = 100;
xsize = size(x,2);
ysize = size(x,1);

xsize = min([xsize, xymax]);
ysize = min([ysize, xymax]);
x = imresize(x, [ysize, xsize]);
y = imresize(y, [ysize, xsize]);
z = imresize(z, [ysize, xsize]);
cdata = imresize(cdata, [ysize, xsize]);

%-optional-%
% if isvector(x)
%     [x, y] = meshgrid(x,y);
% end

%---------------------------------------------------------------------%

%-surface x-%
obj.data{surfaceIndex}.x = x;

%---------------------------------------------------------------------%

%-surface y-%
obj.data{surfaceIndex}.y = y;

%---------------------------------------------------------------------%

%-surface z-%
obj.data{surfaceIndex}.z = z;

%---------------------------------------------------------------------%

%-if image comes would a 3D plot-%
obj.PlotOptions.Image3D = true;

%-if contour comes would a ContourProjection-%
obj.PlotOptions.ContourProjection = true;

%---------------------------------------------------------------------%

%- setting grid mesh by default -%
% x-direction
xmin = min(x(:));
xmax = max(x(:));
xsize = (xmax - xmin) / (size(x, 2)-1); 
obj.data{surfaceIndex}.contours.x.start = xmin;
obj.data{surfaceIndex}.contours.x.end = xmax;
obj.data{surfaceIndex}.contours.x.size = xsize;
obj.data{surfaceIndex}.contours.x.show = true;
obj.data{surfaceIndex}.contours.x.color = 'black';
% y-direction
ymin = min(y(:));
ymax = max(y(:));
ysize = (ymax - ymin) / (size(y, 1)-1);
obj.data{surfaceIndex}.contours.y.start = ymin;
obj.data{surfaceIndex}.contours.y.end = ymax;
obj.data{surfaceIndex}.contours.y.size = ysize;
obj.data{surfaceIndex}.contours.y.show = true;
obj.data{surfaceIndex}.contours.y.color = 'black';

%------------------------------------------------------------------------%

%-get data-%

%-aspect ratio-%
ar = obj.PlotOptions.AspectRatio;

if ~isempty(ar)
  if ischar(ar)
    scene.aspectmode = ar;
  elseif isvector(ar) && length(ar) == 3
    xar = ar(1);
    yar = ar(2);
    zar = ar(3);
  end
  else

  %-define as default-%
  xar = 0.5*max(x(:));
  yar = 0.5*max(y(:));
  zar = 0.4*max([xar, yar]);
end

scene.aspectratio.x = xar; 
scene.aspectratio.y = yar; 
scene.aspectratio.z = zar; 

%---------------------------------------------------------------------%

%-camera eye-%
ey = obj.PlotOptions.CameraEye;

if ~isempty(ey)
if isvector(ey) && length(ey) == 3
  scene.camera.eye.x = ey(1);
  scene.camera.eye.y = ey(2);
  scene.camera.eye.z = ey(3);
end
else

%-define as default-%
fac = 0.35;
xey = - xar; if xey>0 xfac = -fac; else xfac = fac; end
yey = - yar; if yey>0 yfac = -fac; else yfac = fac; end
if zar>0 zfac = fac; else zfac = -fac; end

scene.camera.eye.x = xey + xfac*xey; 
scene.camera.eye.y = yey + yfac*yey;
scene.camera.eye.z = zar + zfac*zar;
end

obj.layout = setfield(obj.layout,['scene'], scene);

%-------------------------------------------------------------------------%

%-image colorscale-%

cmap = figure_data.Colormap;
len = length(cmap)-1;

for c = 1: length(cmap)
    col = 255 * cmap(c, :);
    obj.data{surfaceIndex}.colorscale{c} = { (c-1)/len , ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'  ]  };
end

%-------------------------------------------------------------------------%

%-surface coloring-%
obj.data{surfaceIndex}.surfacecolor = cdata;

%-------------------------------------------------------------------------%

%-surface name-%
obj.data{surfaceIndex}.name = image_data.DisplayName;

%-------------------------------------------------------------------------%

%-surface showscale-%
obj.data{surfaceIndex}.showscale = false;

%-------------------------------------------------------------------------%

%-surface visible-%
obj.data{surfaceIndex}.visible = strcmp(image_data.Visible,'on');

%-------------------------------------------------------------------------%

leg = get(image_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{surfaceIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

end
