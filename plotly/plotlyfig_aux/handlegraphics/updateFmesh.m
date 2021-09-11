function obj = updateFmesh(obj, surfaceIndex)

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(surfaceIndex).AssociatedAxis);

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,axIndex);

%-SURFACE DATA STRUCTURE- %
meshData = get(obj.State.Plot(surfaceIndex).Handle);
figureData = get(obj.State.Figure.Handle);

%-AXIS STRUCTURE-%
axisData = get(ancestor(meshData.Parent,'axes'));

%-SCENE DATA-%
eval( sprintf('scene = obj.layout.scene%d;', xsource) );

%-------------------------------------------------------------------------%

%-associate scene-%
obj.data{surfaceIndex}.scene = sprintf('scene%d', xsource);

%-------------------------------------------------------------------------%

%-surface xaxis-%
obj.data{surfaceIndex}.xaxis = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%
    
%-surface type-%
obj.data{surfaceIndex}.type = 'scatter3d';
obj.data{surfaceIndex}.mode = 'lines';

%-------------------------------------------------------------------------%

%-get plot data-%
meshDensity = meshData.MeshDensity;
xData = meshData.XData(1:meshDensity^2);
yData = meshData.YData(1:meshDensity^2);
zData = meshData.ZData(1:meshDensity^2);

%-reformat data to mesh-%
xData = reshape(xData, [meshDensity, meshDensity])';
yData = reshape(yData, [meshDensity, meshDensity])';
zData = reshape(zData, [meshDensity, meshDensity])';

xData = [xData; NaN(1, size(xData, 2))];
yData = [yData; NaN(1, size(yData, 2))];
zData = [zData; NaN(1, size(zData, 2))];

xData = [xData; xData(1:end-1,:)'];
yData = [yData; yData(1:end-1,:)'];
zData = [zData; zData(1:end-1,:)'];

xData = [xData; NaN(1, size(xData, 2))];
yData = [yData; NaN(1, size(yData, 2))];
zData = [zData; NaN(1, size(zData, 2))];

xData = [xData(1, :)-0.01; xData];
yData = [yData(1, :)-0.01; yData];
zData = [NaN(1, size(zData, 2)); zData];

xData = [xData(:, 1)-0.01, xData];
yData = [yData(:, 1)-0.01, yData];
zData = [NaN(size(zData, 1), 1), zData];

%-------------------------------------------------------------------------%

%-set data-%
obj.data{surfaceIndex}.x = xData(:);
obj.data{surfaceIndex}.y = yData(:);
obj.data{surfaceIndex}.z = zData(:);

%-------------------------------------------------------------------------%

%-COLORING-%

%-------------------------------------------------------------------------%

%-get colormap-%
cMap = figureData.Colormap;
fac = 1/(length(cMap)-1);
colorScale = {};

for c = 1: length(cMap)
    colorScale{c} = { (c-1)*fac , sprintf('rgb(%f,%f,%f)', 255*cMap(c, :))};
end

%-------------------------------------------------------------------------%

%-get edge color-%
if isnumeric(meshData.EdgeColor)
    cData = sprintf('rgb(%f,%f,%f)', 255*meshData.EdgeColor);

elseif strcmpi(meshData.EdgeColor, 'interp')
    cData = zData(:);
    obj.data{surfaceIndex}.line.colorscale = colorScale;
end

%-set edge color-%
obj.data{surfaceIndex}.line.color = cData;

%-------------------------------------------------------------------------%

%-get face color-%
if isnumeric(meshData.FaceColor)
    cData = sprintf('rgba(%f,%f,%f,0.99)', 255*meshData.FaceColor);

elseif strcmpi(meshData.EdgeColor, 'interp')
    cData = zData(:);
    obj.data{surfaceIndex}.colorscale = colorScale;
end

%-set face color-%
obj.data{surfaceIndex}.surfacecolor = cData;
obj.data{surfaceIndex}.surfaceaxis = 2;

%-------------------------------------------------------------------------%

%-line style-%

obj.data{surfaceIndex}.line.width = 3*meshData.LineWidth;

switch meshData.LineStyle
    case '-'
        obj.data{surfaceIndex}.line.dash = 'solid';
    case '--'
        obj.data{surfaceIndex}.line.dash = 'dash';
    case '-.'
        obj.data{surfaceIndex}.line.dash = 'dashdot';
    case ':'
        obj.data{surfaceIndex}.line.dash = 'dot';
end

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
    xey = - xyar; if xey>0 xfac = 0.0; else xfac = 0.0; end
    yey = - xyar; if yey>0 yfac = -0.3; else yfac = 0.3; end
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
obj.data{surfaceIndex}.name = meshData.DisplayName;

%-------------------------------------------------------------------------%

%-surface showscale-%
obj.data{surfaceIndex}.showscale = false;

%-------------------------------------------------------------------------%

%-surface visible-%
obj.data{surfaceIndex}.visible = strcmp(meshData.Visible,'on');

%-------------------------------------------------------------------------%

leg = get(meshData.Annotation);
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
