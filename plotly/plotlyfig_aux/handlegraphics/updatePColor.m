function obj = updatePColor(obj, patchIndex)

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(patchIndex).AssociatedAxis);

%-PCOLOR DATA STRUCTURE- %
pcolor_data = get(obj.State.Plot(patchIndex).Handle);
figure_data = get(obj.State.Figure.Handle);

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,axIndex);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

%-------------------------------------------------------------------------%

%-pcolor xaxis-%
obj.data{patchIndex}.xaxis = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

%-pcolor yaxis-%
obj.data{patchIndex}.yaxis = ['y' num2str(ysource)];

%-------------------------------------------------------------------------%

%-plot type: surface-%
obj.data{patchIndex}.type = 'surface';

%-------------------------------------------------------------------------%

%-format data-%
XData = pcolor_data.XData;
YData = pcolor_data.YData;
ZData = pcolor_data.ZData;
CData = pcolor_data.CData;

xdata = zeros(size(XData, 1)-1*2, size(XData, 2)-1*2); 
ydata = zeros(size(XData, 1)-1*2, size(XData, 2)-1*2); 
zdata = zeros(size(XData, 1)-1*2, size(XData, 2)-1*2); 
cdata = zeros(size(XData, 1)-1*2, size(XData, 2)-1*2); 

for n = 1:size(XData, 2)-1
    for m = 1:size(XData, 1)-1
        
        % get indices
        n1 = 2*(n-1)+1; m1 = 2*(m-1)+1;
        
        % get surface mesh
        xdata(m1:m1+1,n1:n1+1) = XData(m:m+1, n:n+1);
        ydata(m1:m1+1,n1:n1+1) = YData(m:m+1, n:n+1);
        zdata(m1:m1+1,n1:n1+1) = ZData(m:m+1, n:n+1);
        cdata(m1:m1+1,n1:n1+1) = ones(2,2)*CData(m, n);
    end
end

%-------------------------------------------------------------------------%

%-x-data-%
obj.data{patchIndex}.x = xdata; 

%-------------------------------------------------------------------------%

%-y-data-%
obj.data{patchIndex}.y = ydata; 

%-------------------------------------------------------------------------%

%-z-data-%
obj.data{patchIndex}.z = zdata; 

%-------------------------------------------------------------------------%

%-coloring-%
cmap = figure_data.Colormap;
len = length(cmap)-1;

for c = 1: length(cmap)
    col = 255 * cmap(c, :);
    obj.data{patchIndex}.colorscale{c} = { (c-1)/len , ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'  ]  };
end

obj.data{patchIndex}.surfacecolor = cdata;
obj.data{patchIndex}.showscale = false;
obj.data{patchIndex}.cmin = min(CData(:));
obj.data{patchIndex}.cmax = max(CData(:));

%-------------------------------------------------------------------------%

%-aspectratio-%
obj.layout.scene.aspectratio.x = 12;
obj.layout.scene.aspectratio.y = 10;
obj.layout.scene.aspectratio.z = 0.0001;

%-------------------------------------------------------------------------%

%-camera.eye-%
obj.layout.scene.camera.eye.x = 0;
obj.layout.scene.camera.eye.y = -0.5;
obj.layout.scene.camera.eye.z = 14;

%-------------------------------------------------------------------------%

%-hide axis-x-%
obj.layout.scene.xaxis.showticklabels = true;
obj.layout.scene.xaxis.zeroline = false;
obj.layout.scene.xaxis.showgrid = false;
obj.layout.scene.xaxis.title = '';

%-------------------------------------------------------------------------%

%-hide axis-y-%
obj.layout.scene.yaxis.zeroline = false;
obj.layout.scene.yaxis.showgrid = false;
obj.layout.scene.yaxis.showticklabels = true;
obj.layout.scene.yaxis.title = '';

%-------------------------------------------------------------------------%

%-hide axis-z-%
obj.layout.scene.zaxis.title = '';
obj.layout.scene.zaxis.autotick = false;
obj.layout.scene.zaxis.zeroline = false;
obj.layout.scene.zaxis.showline = false;
obj.layout.scene.zaxis.showticklabels = false;
obj.layout.scene.zaxis.showgrid = false;

%-------------------------------------------------------------------------%

%-patch showlegend-%
leg = get(pcolor_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{patchIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

end
