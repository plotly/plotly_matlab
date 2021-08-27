function updatePie3(obj,plotIndex)
    
  %-update according to patch or surface-%
  if strcmpi(obj.State.Plot(plotIndex).Class, 'patch')
      updatePatchPie3(obj, plotIndex);
  else
      updateSurfacePie3(obj, plotIndex);
  end

  %-hide axis-x-%
  obj.PlotOptions.scene.xaxis.title = '';
  obj.PlotOptions.scene.xaxis.autotick = false;
  obj.PlotOptions.scene.xaxis.zeroline = false;
  obj.PlotOptions.scene.xaxis.showline = false;
  obj.PlotOptions.scene.xaxis.showticklabels = false;
  obj.PlotOptions.scene.xaxis.showgrid = false;
  
  %-hide axis-y-%
  obj.PlotOptions.scene.yaxis.title = '';
  obj.PlotOptions.scene.yaxis.autotick = false;
  obj.PlotOptions.scene.yaxis.zeroline = false;
  obj.PlotOptions.scene.yaxis.showline = false;
  obj.PlotOptions.scene.yaxis.showticklabels = false;
  obj.PlotOptions.scene.yaxis.showgrid = false;
  
  %-hide axis-z-%
  obj.PlotOptions.scene.zaxis.title = '';
  obj.PlotOptions.scene.zaxis.autotick = false;
  obj.PlotOptions.scene.zaxis.zeroline = false;
  obj.PlotOptions.scene.zaxis.showline = false;
  obj.PlotOptions.scene.zaxis.showticklabels = false;
  obj.PlotOptions.scene.zaxis.showgrid = false;
  
  %-put text-%
  obj.data{plotIndex}.hoverinfo = 'text';
  obj.data{plotIndex}.hovertext = obj.PlotOptions.perc;

  %-update scene-%
  obj.layout = setfield(obj.layout,['scene' obj.PlotOptions.scene_anchor(end)], obj.PlotOptions.scene);
  obj.data{plotIndex}.scene = obj.PlotOptions.scene_anchor;
  obj.data{plotIndex}.legendgroup = obj.PlotOptions.scene_anchor;

  %-update legend-%
  obj.layout.legend.tracegroupgap = 20;
  obj.layout.legend.traceorder = 'grouped';
  obj.layout.legend.bordercolor = 'rgb(200,200,200)';
  obj.layout.legend.x = 0.8;
  obj.layout.legend.y = 0.5;
  obj.layout.legend.borderwidth = 0.5;
    
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
  eval(['scene = obj.layout.scene' num2str(xsource) ';']);
  obj.PlotOptions.scene_anchor = ['scene' num2str(xsource)];

  %-------------------------------------------------------------------------%

  %-scene to be set-%
  obj.PlotOptions.scene = scene;

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
  % obj.data{patchIndex}.fill = 'tozeroy';

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
  obj.data{patchIndex}.surfacecolor = fill.color;

  if zdata(1) == 0
    obj.data{patchIndex}.line.width = 3;
    obj.data{patchIndex}.line.color = fill.color;
  end

  %---------------------------------------------------------------------%

  %-surfaceaxis-%
  minstd = min([std(patch_data.XData) std(patch_data.YData) std(patch_data.ZData)]);
  ind = find([std(patch_data.XData) std(patch_data.YData) std(patch_data.ZData)] == minstd)-1;
  obj.data{patchIndex}.surfaceaxis = ind;

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
  eval(['scene = obj.layout.scene' num2str(xsource) ';']);
  obj.PlotOptions.scene_anchor = ['scene' num2str(xsource)];

  %-------------------------------------------------------------------------%
      
  %-surface type-%
  obj.data{surfaceIndex}.type = 'surface';
  
  %------------------------------------------------------------------------%
  
  %-surface x-%
  obj.data{surfaceIndex}.x = image_data.XData;

  %------------------------------------------------------------------------%
  
  %-surface y-%
  obj.data{surfaceIndex}.y = image_data.YData;
  
  %------------------------------------------------------------------------%
  
  %-surface z-%
  obj.data{surfaceIndex}.z = image_data.ZData;
  
  %------------------------------------------------------------------------%

  %-image colorscale-%

  cmap = figure_data.Colormap;
  len = length(cmap)-1;

  for c = 1:length(cmap)
    col = 255 * cmap(c, :);
    obj.data{surfaceIndex}.colorscale{c} = { (c-1)/len , ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'  ]  };
  end

  obj.data{surfaceIndex}.surfacecolor = 255*(image_data.CData-1) / (obj.PlotOptions.nbars{xsource} - 1);
  obj.data{surfaceIndex}.cmax = 255;
  obj.data{surfaceIndex}.cmin = 0;

  %------------------------------------------------------------------------%

  %-get data-%
  xdata = image_data.XData;
  ydata = image_data.YData;

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
    xar = max(xdata(:));
    yar = max(ydata(:));
    zar = max([xar, yar]);
  end

  fac1 = 0.75;
  fac2 = 0.175;
  nax = length(obj.PlotOptions.nbars);

  scene.aspectratio.x = xar + fac1*(nax-1)*xar; 
  scene.aspectratio.y = yar + fac1*(nax-1)*yar; 
  scene.aspectratio.z = (zar + fac1*(nax-1)*zar)*fac2; 

  % optional equations
  % scene.aspectratio.x = xar*(1+fac1); 
  % scene.aspectratio.y = yar*(1+fac1); 
  % scene.aspectratio.z = zar*fac2*(1+fac1); 

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
    xey = - xar; if xey>0 xfac = -0.2; else xfac = 0.2; end
    yey = - yar; if yey>0 yfac = -0.2; else yfac = 0.2; end
    if zar>0 zfac = 0.2; else zfac = -0.2; end
    
    scene.camera.eye.x = xey + xfac*xey; 
    scene.camera.eye.y = yey + yfac*yey;
    scene.camera.eye.z = zar + zfac*zar;
  end

  %-------------------------------------------------------------------------%

  %-scene to be set-%
  obj.PlotOptions.scene = scene;

  %-------------------------------------------------------------------------%

  %-surface name-%
  obj.data{surfaceIndex}.name = image_data.DisplayName;
  obj.data{surfaceIndex-1}.name = image_data.DisplayName;

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

  obj.data{surfaceIndex-1}.showlegend = showleg;
  obj.data{surfaceIndex}.showlegend = false;

  %-------------------------------------------------------------------------%
end

