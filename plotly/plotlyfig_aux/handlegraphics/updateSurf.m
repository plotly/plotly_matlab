function obj = updateSurf(obj, surfaceIndex)

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(surfaceIndex).AssociatedAxis);

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,axIndex);

%-SURFACE DATA STRUCTURE- %
surfData = get(obj.State.Plot(surfaceIndex).Handle);
figureData = get(obj.State.Figure.Handle);

%-AXIS STRUCTURE-%
axisData = get(ancestor(surfData.Parent,'axes'));

%-GET SCENE-%
eval(['scene = obj.layout.scene' num2str(xsource) ';']);

%-------------------------------------------------------------------------%

%-associate scene-%
obj.data{surfaceIndex}.scene = sprintf('scene%d', xsource);

%-------------------------------------------------------------------------%
    
%-surface type-%
obj.data{surfaceIndex}.type = 'surface';

%---------------------------------------------------------------------%

%-get plot data-%
xData = surfData.XData;
yData = surfData.YData;
zData = surfData.ZData;
cData = surfData.CData;

%---------------------------------------------------------------------%

%-set surface data-%
obj.data{surfaceIndex}.x = xData;
obj.data{surfaceIndex}.y = yData;
obj.data{surfaceIndex}.z = zData;

%---------------------------------------------------------------------%

%-setting grid mesh by default-%

edgeColor = surfData.EdgeColor;

if isnumeric(edgeColor)
    edgeColor = sprintf('rgb(%f,%f,%f)', 255*edgeColor);
elseif strcmpi(edgeColor, 'none')
    edgeColor = 'rgba(1,1,1,0)';
end

% x-direction
xMin = min(xData(:));
xMax = max(xData(:));
xsize = (xMax - xMin) / (size(xData, 2)-1); 
obj.data{surfaceIndex}.contours.x.start = xMin;
obj.data{surfaceIndex}.contours.x.end = xMax;
obj.data{surfaceIndex}.contours.x.size = xsize;
obj.data{surfaceIndex}.contours.x.show = true;
obj.data{surfaceIndex}.contours.x.color = edgeColor;

% y-direction
yMin = min(yData(:));
yMax = max(yData(:));
ysize = (yMax - yMin) / (size(yData, 1)-1);
obj.data{surfaceIndex}.contours.y.start = yMin;
obj.data{surfaceIndex}.contours.y.end = yMax;
obj.data{surfaceIndex}.contours.y.size = ysize;
obj.data{surfaceIndex}.contours.y.show = true;
obj.data{surfaceIndex}.contours.y.color = edgeColor;

%-------------------------------------------------------------------------%

%-set colorscales-%
cMap = figureData.Colormap;

if isnumeric(surfData.FaceColor)
    for n = 1:size(cData, 2)
        for m = 1:size(cData, 1)
            cDataNew(m, n, :) = surfData.FaceColor;
        end
    end

    cData = rgb2ind(cDataNew, cMap);
    obj.data{surfaceIndex}.cmin = 0;
    obj.data{surfaceIndex}.cmax = 255;
end

if size(cData, 3) ~= 1
    cMap = unique( reshape(cData, ...
        [size(cData,1)*size(cData,2), size(cData,3)]), 'rows' );
    cData = rgb2ind(cData, cMap);
end

colorScale = {};
fac = 1/(length(cMap)-1);

for c = 1: length(cMap)
    colorScale{c} = { (c-1)*fac , sprintf('rgb(%f,%f,%f)', 255*cMap(c, :))};
end

obj.data{surfaceIndex}.colorscale = colorScale;

%-surface coloring-%
obj.data{surfaceIndex}.surfacecolor = cData;

%-------------------------------------------------------------------------%

%-surface opacity-%
obj.data{surfaceIndex}.opacity = surfData.FaceAlpha;

%-surface showscale-%
obj.data{surfaceIndex}.showscale = false;

%-------------------------------------------------------------------------%

%-SCENE CONFIGUTATION-%

%-------------------------------------------------------------------------%

%-aspect ratio-%
asr = obj.PlotOptions.AspectRatio;

if ~isempty(asr)
    if ischar(asr)
        scene.aspectmode = asr;
    elseif isvector(ar) && length(asr) == 3
        xar = asr(1);
        yar = asr(2);
        zar = asr(3);
    end
else

    %-define as default-%
    xar = max(xData(:));
    yar = max(yData(:));
    xyar = max([xar, yar]);
    zar = 0.65*xyar;
end

scene.aspectratio.x = 1.1*xyar;
scene.aspectratio.y = 1.0*xyar;
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
    xey = - xyar; if xey>0 xfac = -0.2; else xfac = 0.2; end
    yey = - xyar; if yey>0 yfac = -0.2; else yfac = 0.2; end
    if zar>0 zfac = 0.2; else zfac = -0.2; end
    
    scene.camera.eye.x = xey + xfac*xey; 
    scene.camera.eye.y = yey + yfac*yey;
    scene.camera.eye.z = zar + zfac*zar;
end

%-------------------------------------------------------------------------%

%-scene axis configuration-%

scene.xaxis.range = axisData.XLim;
scene.yaxis.range = axisData.YLim;
scene.zaxis.range = axisData.ZLim;

scene.xaxis.tickvals = axisData.XTick;
scene.xaxis.ticktext = axisData.XTickLabel;

scene.yaxis.tickvals = axisData.YTick;
scene.yaxis.ticktext = axisData.YTickLabel;

scene.zaxis.tickvals = axisData.ZTick;
scene.zaxis.ticktext = axisData.ZTickLabel;

scene.xaxis.zeroline = false;
scene.yaxis.zeroline = false;
scene.zaxis.zeroline = false;

scene.xaxis.showline = true;
scene.yaxis.showline = true;
scene.zaxis.showline = true;

scene.xaxis.tickcolor = 'rgba(0,0,0,1)';
scene.yaxis.tickcolor = 'rgba(0,0,0,1)';
scene.zaxis.tickcolor = 'rgba(0,0,0,1)';

scene.xaxis.ticklabelposition = 'outside';
scene.yaxis.ticklabelposition = 'outside';
scene.zaxis.ticklabelposition = 'outside';

scene.xaxis.title = axisData.XLabel.String;
scene.yaxis.title = axisData.YLabel.String;
scene.zaxis.title = axisData.ZLabel.String;

scene.xaxis.tickfont.size = axisData.FontSize;
scene.yaxis.tickfont.size = axisData.FontSize;
scene.zaxis.tickfont.size = axisData.FontSize;

scene.xaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);
scene.yaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);
scene.zaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);

%-------------------------------------------------------------------------%

%-SET SCENE TO LAYOUT-%
obj.layout = setfield(obj.layout, sprintf('scene%d', xsource), scene);

%-------------------------------------------------------------------------%

%-surface name-%
obj.data{surfaceIndex}.name = surfData.DisplayName;

%-------------------------------------------------------------------------%

%-surface visible-%
obj.data{surfaceIndex}.visible = strcmp(surfData.Visible,'on');

%-------------------------------------------------------------------------%

leg = get(surfData.Annotation);
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
