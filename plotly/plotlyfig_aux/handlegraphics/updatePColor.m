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

%-handle vertices-%
xdata = []; ydata = []; zdata = []; cdata = [];

for n = 1:size(pcolor_data.XData, 2)-1
    for m = 1:size(pcolor_data.XData, 1)-1
        xdata = [xdata pcolor_data.XData(m:m+1, n:n+1) NaN(2,1)];
        ydata = [ydata pcolor_data.YData(m:m+1, n:n+1) NaN(2,1)];
        zdata = [zdata pcolor_data.ZData(m:m+1, n:n+1) NaN(2,1)];
        cdata = [cdata ones(2,3)*pcolor_data.CData(m, n)];
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

%-colorscale to map-%
cmap = figure_data.Colormap;
len = length(cmap)-1;

for c = 1: length(cmap)
    col = 255 * cmap(c, :);
    obj.data{patchIndex}.colorscale{c} = { (c-1)/len , ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'  ]  };
end

obj.data{patchIndex}.surfacecolor = cdata;
obj.data{patchIndex}.showscale = false;

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

%-------------------------------------------------------------------------%

%-hide axis-y-%
obj.layout.scene.yaxis.zeroline = false;
obj.layout.scene.yaxis.showgrid = false;
obj.layout.scene.yaxis.showticklabels = true;

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
