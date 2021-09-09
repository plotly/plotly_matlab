function obj = updateStem3(obj,dataIndex)

  %-------------------------------------------------------------------------%

  %-AXIS INDEX-%
  axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);

  %-PLOT DATA STRUCTURE- %
  data = get(obj.State.Plot(dataIndex).Handle);

  %-CHECK FOR MULTIPLE AXES-%
  [xsource, ysource] = findSourceAxis(obj,axIndex);

  %------------------------------------------------------------------------%

  %-get coordenate x,y,z data-%
  xdata = data.XData;
  ydata = data.YData;
  zdata = data.ZData;
  npoints = length(xdata);

  %------------------------------------------------------------------------%

  %-check if stem3-%
  isstem3 = ~isempty(zdata);

  %------------------------------------------------------------------------%

  %-SCENE-%
  if isstem3
    eval(['scene = obj.layout.scene' num2str(xsource) ';']);
  else
    eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
    eval(['yaxis = obj.layout.yaxis' num2str(xsource) ';']);
  end

  %-------------------------------------------------------------------------%

  %-scatter3d scene-%
  if isstem3
    stem_data.scene = sprintf('scene%d', xsource);
  else
    stem_data.xaxis = sprintf('x%d', xsource);
    stem_data.yaxis = sprintf('y%d', xsource);
  end

  %------------------------------------------------------------------------%

  %-scatter3d type-%
  if isstem3
    stem_data.type = 'scatter3d';
  else
    stem_data.type = 'scatter';
  end

  %-------------------------------------------------------------------------%

  %-scatter3d visible-%
  stem_data.visible = strcmp(data.Visible,'on');

  %-------------------------------------------------------------------------%

  %-scatter3d name-%
  stem_data.name = data.DisplayName;

  %------------------------------------------------------------------------%

  %-scatter mode-%
  stem_data.mode = 'lines+markers';

  %------------------------------------------------------------------------%

  %-allocated space for extended data-%
  xdata_extended = zeros(3*npoints, 1); 
  ydata_extended = zeros(3*npoints, 1);

  if isstem3
    zdata_extended = zeros(3*npoints, 1);
  end

  %-format data-%
  m = 1; 
  for n = 1:npoints
    %-x data-%
    xdata_extended(m) = xdata(n); 
    xdata_extended(m+1) = xdata(n); 
    xdata_extended(m+2) = nan; 

    %-y data-%
    ydata_extended(m) = 0;
    if isstem3 
      ydata_extended(m) = ydata(n); 
    end
    ydata_extended(m+1) = ydata(n); 
    ydata_extended(m+2) = nan; 

    %-z data-%
    if isstem3
      zdata_extended(m) = 0;
      zdata_extended(m+1) = zdata(n); 
      zdata_extended(m+2) = nan; 
    end

    m = m + 3; 
  end

  %------------------------------------------------------------------------%

  %-scatter3d line-%
  stem_data.line = extractLineLine(data);

  %-------------------------------------------------------------------------%

  %-scatter3d marker-%
  stem_data.marker = extractLineMarker(data);

  %-------------------------------------------------------------------------%

  if isstem3

    %-fix marker symbol-% 
    symbol = stem_data.marker.symbol;

    if strcmpi(symbol, 'asterisk-open') || strcmpi(symbol, 'cross-thin-open')
      stem_data.marker.symbol = 'cross';
    end

    stem_data.marker.size = stem_data.marker.size * 0.6;

    %-fix dash line-% 
    dash = stem_data.line.dash;

    if strcmpi(dash, 'dash')
      stem_data.line.dash = 'dot';
    end
  end

  %-------------------------------------------------------------------------%

  %-hide every other marker-%
  markercolor = cell(3*npoints,1);
  linecolor = cell(3*npoints,1);
  hidecolor = 'rgba(0,0,0,0)';

  linecolor(1:3:3*npoints) = {hidecolor};
  markercolor(1:3:3*npoints) = {hidecolor};

  try
    linecolor(2:3:3*npoints) = {stem_data.marker.line.color};
    markercolor(2:3:3*npoints) = {stem_data.marker.color};
  catch
    linecolor(2:3:3*npoints) = {stem_data.marker.color};
    markercolor(2:3:3*npoints) = {hidecolor};
  end
  
  linecolor(3:3:3*npoints) = {hidecolor};
  markercolor(3:3:3*npoints) = {hidecolor};

  %-add new marker/line colors-%
  stem_data.marker.color = markercolor;
  stem_data.marker.line.color = linecolor;

  stem_data.marker.line.width = stem_data.marker.line.width * 2;
  stem_data.line.width = stem_data.line.width * 2;

  %------------------------------------------------------------------------%

  %-set x y z data-%
  stem_data.x = xdata_extended; 
  stem_data.y = ydata_extended;

  if isstem3
    stem_data.z = zdata_extended; 
  end

  %------------------------------------------------------------------------%

  %-set plotly data-%
  obj.data{dataIndex} = stem_data;

  %------------------------------------------------------------------------%

  %-SETTING SCENE-%

  if isstem3
    %-aspect ratio-%
    asr = obj.PlotOptions.AspectRatio;

    if ~isempty(asr)
      if ischar(asr)
        scene.aspectmode = asr;
      elseif isvector(asr) && length(asr) == 3
        xar = asr(1);
        yar = asr(2);
        zar = asr(3);
      end
    else

        %-define as default-%
        xar = max(xdata(:));
        yar = max(ydata(:));
        xyar = max([xar, yar]);
        xar = xyar; yar = xyar;
        zar = 0.7*max([xar, yar]);
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
        xey = - xar; if xey>0 xfac = 0.2; else xfac = -0.2; end
        yey = - yar; if yey>0 yfac = -0.2; else yfac = 0.2; end
        if zar>0 zfac = 0.2; else zfac = -0.2; end
        
        scene.camera.eye.x = xey + xfac*xey; 
        scene.camera.eye.y = yey + yfac*yey;
        scene.camera.eye.z = zar + zfac*zar;
    end

    %---------------------------------------------------------------------%

    %-zerolines hidded-%
    scene.xaxis.zeroline = false;
    scene.yaxis.zeroline = false;
    scene.zaxis.zeroline = false;

    scene.xaxis.linecolor = 'rgba(0,0,0,0.8)';
    scene.yaxis.linecolor = 'rgba(0,0,0,0.8)';
    scene.zaxis.linecolor = 'rgba(0,0,0,0.5)';

    scene.xaxis.ticklen = 5;
    scene.yaxis.ticklen = 5;
    scene.zaxis.ticklen = 5;

    scene.xaxis.tickcolor = 'rgba(0,0,0,0.8)';
    scene.yaxis.tickcolor = 'rgba(0,0,0,0.8)';
    scene.zaxis.tickcolor = 'rgba(0,0,0,0.8)';

    scene.xaxis.range = data.Parent.XLim;
    scene.yaxis.range = data.Parent.YLim;
    scene.zaxis.range = data.Parent.ZLim;

    scene.xaxis.tickvals = data.Parent.XTick;
    scene.yaxis.tickvals = data.Parent.YTick;
    scene.zaxis.tickvals = data.Parent.ZTick;

    scene.xaxis.title = data.Parent.XLabel.String;
    scene.yaxis.title = data.Parent.YLabel.String;
    scene.zaxis.title = data.Parent.ZLabel.String;

    %-update scene-%
    obj.layout = setfield(obj.layout, sprintf('scene%d', xsource), scene);

  else
    yaxis.zeroline = true;

    xaxis.linecolor = 'rgba(0,0,0,0.4)';
    yaxis.linecolor = 'rgba(0,0,0,0.4)';

    xaxis.tickcolor = 'rgba(0,0,0,0.4)';
    yaxis.tickcolor = 'rgba(0,0,0,0.4)';

    xaxis.tickvals = data.Parent.XTick;
    yaxis.tickvals = data.Parent.YTick;

    xaxis.title = data.Parent.XLabel.String;
    yaxis.title = data.Parent.YLabel.String;

    %-update axis-%
    obj.layout = setfield(obj.layout, sprintf('xaxis%d', xsource), xaxis);
    obj.layout = setfield(obj.layout, sprintf('yaxis%d', ysource), yaxis);
  end

  %------------------------------------------------------------------------%  

end