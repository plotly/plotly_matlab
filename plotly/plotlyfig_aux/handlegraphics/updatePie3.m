function updatePie3(obj,plotIndex)
    
    %-update according to patch or surface-%
    if strcmpi(obj.State.Plot(plotIndex).Class, 'patch')
        updatePatchPie3(obj, plotIndex);
    else
        updateSurfacePie3(obj, plotIndex);
    end
    
    %-hide axis-x-%
    obj.layout.scene.xaxis.title = '';
    obj.layout.scene.xaxis.autotick = false;
    obj.layout.scene.xaxis.zeroline = false;
    obj.layout.scene.xaxis.showline = false;
    obj.layout.scene.xaxis.showticklabels = false;
    obj.layout.scene.xaxis.showgrid = false;
    
    %-hide axis-y-%
    obj.layout.scene.yaxis.title = '';
    obj.layout.scene.yaxis.autotick = false;
    obj.layout.scene.yaxis.zeroline = false;
    obj.layout.scene.yaxis.showline = false;
    obj.layout.scene.yaxis.showticklabels = false;
    obj.layout.scene.yaxis.showgrid = false;
    
    %-hide axis-z-%
    obj.layout.scene.zaxis.title = '';
    obj.layout.scene.zaxis.autotick = false;
    obj.layout.scene.zaxis.zeroline = false;
    obj.layout.scene.zaxis.showline = false;
    obj.layout.scene.zaxis.showticklabels = false;
    obj.layout.scene.zaxis.showgrid = false;
    
    %-put text-%
    obj.data{plotIndex}.hoverinfo = 'text';
    obj.data{plotIndex}.hovertext = obj.PlotOptions.perc;
    
end


%-updatePatchPie3-%

function obj = updatePatchPie3(obj, patchIndex)

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(patchIndex).AssociatedAxis);

%-PATCH DATA STRUCTURE- %
patch_data = get(obj.State.Plot(patchIndex).Handle);

%-get the percentage-%
if ~any(nonzeros(patch_data.ZData))
    t1 = atan2(patch_data.YData(2), patch_data.XData(2));
    t2 = atan2(patch_data.YData(end-1), patch_data.XData(end-1));
    
    a = rad2deg(t2-t1);
    if a < 0
        a = a+360;
    end
    
    obj.PlotOptions.perc = sprintf('%d %%', round(100*a/360));
end

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,axIndex);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

%-------------------------------------------------------------------------%

%-patch xaxis-%
obj.data{patchIndex}.xaxis = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

%-patch yaxis-%
obj.data{patchIndex}.yaxis = ['y' num2str(ysource)];

%-------------------------------------------------------------------------%

%-patch type-%
obj.data{patchIndex}.type = 'scatter3d';

%-------------------------------------------------------------------------%

%-patch x-%
xdata = patch_data.XData;
if isvector(xdata)
    obj.data{patchIndex}.x = [xdata' xdata(1)];
else
    xtemp = reshape(xdata,[],1);
    xnew = [];
    for n = 1:size(xdata,2)
        xnew = [xnew ; xdata(:,n) ; xdata(1,n); NaN];
    end
    obj.data{patchIndex}.x = xnew;
end

%---------------------------------------------------------------------%

%-patch y-%
ydata = patch_data.YData;
if isvector(ydata)
    obj.data{patchIndex}.y = [ydata' ydata(1)];
else
    ytemp = reshape(ydata,[],1);
    ynew = [];
    for n = 1:size(ydata,2)
        ynew = [ynew ; ydata(:,n) ; ydata(1,n); NaN];
    end
    obj.data{patchIndex}.y = ynew;
end

%---------------------------------------------------------------------%

%-patch z-%
zdata = patch_data.ZData;

if isvector(ydata)
    obj.data{patchIndex}.z = [zdata' zdata(1)];
else
    ztemp = reshape(zdata,[],1);
    znew = [];
    for n = 1:size(zdata,2)
        znew = [znew ; zdata(:,n) ; zdata(1,n); NaN];
    end
    obj.data{patchIndex}.z = znew;
end

%---------------------------------------------------------------------%

%-patch name-%
if ~isempty(patch_data.DisplayName)
    obj.data{patchIndex}.name = patch_data.DisplayName;
else
    obj.data{patchIndex}.name = patch_data.DisplayName;
end

%---------------------------------------------------------------------%

%-patch visible-%
obj.data{patchIndex}.visible = strcmp(patch_data.Visible,'on');

%---------------------------------------------------------------------%

%-patch fill-%
%     obj.data{patchIndex}.fill = 'tozeroy';

%-PATCH MODE-%
if ~strcmpi('none', patch_data.Marker) && ~strcmpi('none', patch_data.LineStyle)
    mode = 'lines+markers';
elseif ~strcmpi('none', patch_data.Marker)
    mode = 'markers';
elseif ~strcmpi('none', patch_data.LineStyle)
    mode = 'lines';
else
    mode = 'none';
end

obj.data{patchIndex}.mode = mode;

%---------------------------------------------------------------------%

%-patch marker-%
obj.data{patchIndex}.marker = extractPatchMarker(patch_data);

%---------------------------------------------------------------------%

%-patch line-%
obj.data{patchIndex}.line = extractPatchLine(patch_data);

%---------------------------------------------------------------------%

%-patch fillcolor-%
fill = extractPatchFace(patch_data);

if strcmp(obj.data{patchIndex}.type,'scatter')
    obj.data{patchIndex}.fillcolor = fill.color; 
else
    obj.data{patchIndex}.surfacecolor = fill.color;
end

%---------------------------------------------------------------------%

%-surfaceaxis-%
if strcmp(obj.data{patchIndex}.type,'scatter3d')
    minstd = min([std(patch_data.XData) std(patch_data.YData) std(patch_data.ZData)]);
    ind = find([std(patch_data.XData) std(patch_data.YData) std(patch_data.ZData)] == minstd)-1;
    obj.data{patchIndex}.surfaceaxis = ind; 
end

%-------------------------------------------------------------------------%

%-patch showlegend-%
leg = get(patch_data.Annotation);
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



function obj = updateSurfacePie3(obj, surfaceIndex)

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

%-------------------------------------------------------------------------%

% check for 3D
if any(nonzeros(image_data.ZData))
    
    %-surface type-%
    obj.data{surfaceIndex}.type = 'surface';
    
    %---------------------------------------------------------------------%
    
    %-surface x-%
    obj.data{surfaceIndex}.x = image_data.XData;

    %---------------------------------------------------------------------%
    
    %-surface y-%
    obj.data{surfaceIndex}.y = image_data.YData;
    
    %---------------------------------------------------------------------%
    
    %-surface z-%
    obj.data{surfaceIndex}.z = image_data.ZData;
    
    %---------------------------------------------------------------------%
    
else
    
    %-surface type-%
    obj = updateImage(obj, surfaceIndex);
    
    %-surface x-%
    obj.data{surfaceIndex}.x = image_data.XData(1,:);
    
    %-surface y-%
    obj.data{surfaceIndex}.y = image_data.YData(:,1);
end

%-------------------------------------------------------------------------%

%-image colorscale-%

cmap = figure_data.Colormap;
len = length(cmap)-1;

for c = 1:length(cmap)
    col = 255 * cmap(c, :);
    obj.data{surfaceIndex}.colorscale{c} = { (c-1)/len , ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'  ]  };
end

obj.data{surfaceIndex}.surfacecolor = 255*(image_data.CData-1) / obj.PlotOptions.nbars;
obj.data{surfaceIndex}.cmax = 255;
obj.data{surfaceIndex}.cmin = 0;
obj.layout.scene.aspectmode = 'data';

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

