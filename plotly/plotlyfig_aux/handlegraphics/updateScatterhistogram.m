function updateScatterhistogram(obj,scatterIndex)

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(scatterIndex).AssociatedAxis);

%-SCATTER DATA STRUCTURE- %
scatter_data = get(obj.State.Plot(scatterIndex).Handle);

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource, xoverlay, yoverlay] = findSourceAxis(obj,axIndex);

%-parcing data-%
xplot = scatter_data.XData; 
yplot = scatter_data.YData;

xcateg = iscategorical(xplot);
ycateg = iscategorical(yplot);

if xcateg
  [xcats, ~, xplot] = unique(xplot);
  xc = {};
  for c=1:length(xcats)
    xc{c} = char(xcats(c));
  end
end
if ycateg
  [ycats, ~, yplot] = unique(yplot);
  yc = {};
  for c=1:length(ycats)
    yc{c} = char(ycats(c));
  end
end

xdata = {}; ydata = {};
gd = scatter_data.GroupData;
st = scatter_data.SourceTable;

bygroups = ~isempty(gd);

if bygroups
  if iscellstr(gd)
    gd = string(gd);
  end

  gs = unique(gd,'stable');

  for g=1:length(gs)
    inds = gd == gs(g);
    xdata{g} = xplot(inds);
    ydata{g} = yplot(inds);
  end

else
  xdata{1} = xplot;
  ydata{1} = yplot;
end

%=========================================================================%
%
%-UPDATE MAIN PLOT-%
%
%=========================================================================%

for t=1:length(xdata)

  p = t;
  if t > 1
    obj.PlotOptions.nplots = obj.PlotOptions.nplots + 1;
    p = obj.PlotOptions.nplots;
  end

  %-----------------------------------------------------------------------%

  %-scatter type-%
  obj.data{p}.type = 'scatter';

  %-----------------------------------------------------------------------%

  %-scatter mode-%
  obj.data{p}.mode = 'markers';

  %-----------------------------------------------------------------------%

  % %-scatter visible-%
  obj.data{p}.visible = strcmp(scatter_data.Visible,'on');

  %-----------------------------------------------------------------------%

  %-scatter data-%
  obj.data{p}.x = xdata{t};
  obj.data{p}.y = ydata{t};

  %-----------------------------------------------------------------------%

  %-scatter marker-%
  childmarker = extractScatterhistogramMarker(scatter_data, t);
  obj.data{p}.marker = childmarker;

  %-----------------------------------------------------------------------%

  %-associate x and y axis layout-%
  obj.data{p}.xaxis = sprintf('x%d', xsource);
  obj.data{p}.yaxis = sprintf('y%d', ysource);

  %-----------------------------------------------------------------------%

  %-legend-%

  if bygroups
    try
      obj.data{p}.name = char(gs(t));
    catch
      obj.data{p}.name = char(string(gs(t)));
    end

    obj.data{p}.showlegend = true;
  end

end

%-------------------------------------------------------------------------%

%-create xaxis layout-%
xo = scatter_data.Position(1);
yo = scatter_data.Position(2);
w = scatter_data.Position(3);
h = scatter_data.Position(4);
axiscol = 'rgba(0,0,0, 0.4)';

xaxis.domain = min([xo xo + w],1);
xaxis.showgrid = false;
xaxis.showticklabels = true;
xaxis.zeroline = true;
xaxis.anchor = sprintf('y%d', xsource);
xaxis.linecolor = axiscol;
xaxis.tickcolor = axiscol;
xaxis.mirror = 'ticks';
xaxis.ticks = 'inside';
xaxis.font.family = matlab2plotlyfont(scatter_data.FontName);
xaxis.tickfont.size = 1.2*scatter_data.FontSize;
xaxis.title.text = scatter_data.XLabel;
xaxis.title.font.family = matlab2plotlyfont(scatter_data.FontName);
xaxis.title.font.size = 1.2*scatter_data.FontSize;

if ~xcateg
  xaxis.range = scatter_data.XLimits;
else
  xaxis.range = [min(xplot)-0.5, max(xplot)+0.5];
  xaxis.tickvals = 1:max(xplot);
  xaxis.ticktext = xc;
end

if xoverlay
    xaxis.overlaying = sprintf('x%d', xoverlay);
end

%-------------------------------------------------------------------------%

%-create yaxis layout-%
yaxis.domain = min([yo yo + h],1);
yaxis.showgrid = false;
yaxis.showticklabels = true;
yaxis.zeroline = true;
yaxis.anchor = sprintf('x%d', ysource);
yaxis.linecolor = axiscol;
yaxis.tickcolor = axiscol;
yaxis.mirror = 'ticks';
yaxis.ticks = 'inside';
yaxis.tickfont.family = matlab2plotlyfont(scatter_data.FontName);
yaxis.tickfont.size = 1.2*scatter_data.FontSize;
yaxis.title.text = scatter_data.YLabel;
yaxis.title.font.family = matlab2plotlyfont(scatter_data.FontName);
yaxis.title.font.size = 1.2*scatter_data.FontSize;

if ~ycateg
  yaxis.range = scatter_data.YLimits;
  % yaxis.nticks = 20;
else
  yaxis.range = [min(yplot)-0.5, max(yplot)+0.5];
  yaxis.tickvals = 1:max(yplot);
  yaxis.ticktext = yc;
end

if yoverlay
    yaxis.overlaying = sprintf('y%d', yoverlay);
end

%-------------------------------------------------------------------------%

%-set x and y axis layout-%
obj.layout = setfield(obj.layout, sprintf('xaxis%d',xsource), xaxis);
obj.layout = setfield(obj.layout, sprintf('yaxis%d',ysource), yaxis);

%-------------------------------------------------------------------------%

%-remove any annotation text-%
istitle = length(scatter_data.Title) > 0;
obj.layout.annotations{1}.text = ' ';
obj.layout.annotations{1}.showarrow = false;

if istitle
  obj.layout.annotations{1}.text = sprintf('<b>%s</b>', scatter_data.Title);
  obj.layout.annotations{1}.xref = 'paper';
  obj.layout.annotations{1}.yref = 'paper';
  obj.layout.annotations{1}.yanchor = 'top';
  obj.layout.annotations{1}.xanchor = 'middle';
  obj.layout.annotations{1}.x = mean(xaxis.domain);
  obj.layout.annotations{1}.y = 0.96;
  obj.layout.annotations{1}.font.color = 'black';
  obj.layout.annotations{1}.font.family = matlab2plotlyfont(scatter_data.FontName);
  obj.layout.annotations{1}.font.size = 1.5*scatter_data.FontSize;
end


%layout legend-%
if bygroups
  obj.layout.showlegend = true;
  obj.layout.legend.xref = 'paper';
  obj.layout.legend.borderwidth = 1;
  obj.layout.legend.bordercolor = 'rgba(0,0,0,0.2)';
  obj.layout.legend.font.family = matlab2plotlyfont(scatter_data.FontName);
  obj.layout.legend.font.size = 1.0*scatter_data.FontSize;
  obj.layout.legend.valign = 'middle';

  if length(scatter_data.LegendTitle) > 0
    obj.layout.legend.title.text = sprintf('<b>%s</b>', scatter_data.LegendTitle);
    obj.layout.legend.title.side = 'top';
    obj.layout.legend.title.font.family = matlab2plotlyfont(scatter_data.FontName);
    obj.layout.legend.title.font.size = 1.2*scatter_data.FontSize;
    obj.layout.legend.title.font.color = 'black';
  end

  if ~isempty(strfind(scatter_data.ScatterPlotLocation, 'SouthWest'))
    obj.layout.legend.x = 0.96;
    obj.layout.legend.y = 0.96;
    obj.layout.legend.xanchor = 'right';
    obj.layout.legend.yanchor = 'top';
  elseif ~isempty(strfind(scatter_data.ScatterPlotLocation, 'NorthEast'))
    obj.layout.legend.x = 0.02;
    obj.layout.legend.y = 0.02;
    obj.layout.legend.xanchor = 'left';
    obj.layout.legend.yanchor = 'bottom';
  end
end

%-------------------------------------------------------------------------%

%=========================================================================%
%
%-UPDATE MARGINAL X AXIS-%
%
%=========================================================================%

for t=1:length(xdata)

  obj.PlotOptions.nplots = obj.PlotOptions.nplots + 1;
  p = obj.PlotOptions.nplots;

  if t == 1
    ps = p;
  end

  %-----------------------------------------------------------------------%

  %-histogram type-%
  obj.data{p}.type = 'histogram';

  %-----------------------------------------------------------------------%

  %-set plot data-%
  obj.data{p}.x = xdata{t};
  obj.data{p}.y = ydata{t};
  obj.data{p}.nbinsx = scatter_data.NumBins(1, t);

  %-----------------------------------------------------------------------%

  %-plot setting-%
  obj.data{p}.marker.color = 'rgba(0,0,0,0)';
  obj.data{p}.marker.line.color = sprintf('rgb(%f,%f,%f)', scatter_data.Color(t, :));
  obj.data{p}.marker.line.width = scatter_data.LineWidth(t);
  obj.data{p}.histnorm = 'probability';
  obj.data{p}.histfunc = 'count';

  %-----------------------------------------------------------------------%

  %-associate x and y axis layout-%
  obj.data{p}.xaxis = sprintf('x%d', ps);
  obj.data{p}.yaxis = sprintf('y%d', ps);
  obj.data{p}.showlegend = false;

  if bygroups
    try
      obj.data{p}.name = char(gs(t));
    catch
      obj.data{p}.name = char(string(gs(t)));
    end
  end

  %-----------------------------------------------------------------------%

end

%-------------------------------------------------------------------------%

%-create xaxis layout-%
xbase = xaxis.domain;

if ~isempty(strfind(scatter_data.ScatterPlotLocation, 'South'))
  yo1 = yo + h*1.02;

  if istitle
    h1 = 0.9 - yo1;
  else
    h1 = 0.96 - yo1;
  end

elseif ~isempty(strfind(scatter_data.ScatterPlotLocation, 'North'))
  yo1 = 0.02;
  h1 = yo*0.7 - yo1;
end

xo1 = xo;
w1 = w;

xaxis1.showgrid = false;
xaxis1.showticklabels = false;
xaxis1.zeroline = false;
xaxis1.range = scatter_data.XLimits;
xaxis1.domain = min([xo1 xo1+w1],1);
xaxis1.anchor = sprintf('y%d', ps);
xaxis1.color = 'rgba(0,0,0,0)';

if xoverlay
    xaxis1.overlaying = sprintf('x%d', ps);
end

%-------------------------------------------------------------------------%

%-create yaxis layout-%
yaxis1.showgrid = false;
yaxis1.showticklabels = false;
yaxis1.zeroline = true;
yaxis1.zerolinecolor = axiscol;
yaxis1.domain = min([yo1 yo1+h1],1);
yaxis1.anchor = sprintf('x%d', ps);
yaxis1.color = 'rgba(0,0,0,0)';

if yoverlay
    yaxis1.overlaying = sprintf('y%d', ps);
end

%-------------------------------------------------------------------------%

%-set x and y axis layout-%
obj.layout = setfield(obj.layout, sprintf('xaxis%d', ps), xaxis1);
obj.layout = setfield(obj.layout, sprintf('yaxis%d', ps), yaxis1);

obj.layout.plot_bgcolor = 'rgba(0,0,0,0)';
obj.layout.paper_bgcolor = 'rgba(0,0,0,0)';
obj.layout.barmode = 'overlay';


%=========================================================================%
%
%-UPDATE MARGINAL Y AXIS-%
%
%=========================================================================%

for t=1:length(xdata)

  obj.PlotOptions.nplots = obj.PlotOptions.nplots + 1;
  p = obj.PlotOptions.nplots;

  if t == 1
    ps = p;
  end

  %-----------------------------------------------------------------------%

  %-histogram type-%
  obj.data{p}.type = 'histogram';

  %-----------------------------------------------------------------------%

  %-set plot data-%
  obj.data{p}.x = xdata{t};
  obj.data{p}.y = ydata{t};
  obj.data{p}.nbinsy = scatter_data.NumBins(2, t);

  %-----------------------------------------------------------------------%

  %-plot setting-%
  obj.data{p}.marker.color = 'rgba(0,0,0,0)';
  obj.data{p}.marker.line.color = sprintf('rgb(%f,%f,%f)', scatter_data.Color(t, :));
  obj.data{p}.marker.line.width = scatter_data.LineWidth(t);
  obj.data{p}.histnorm = 'probability';
  obj.data{p}.histfunc = 'count';
  obj.data{p}.orientation = 'h';

  %-----------------------------------------------------------------------%

  %-associate x and y axis layout-%
  obj.data{p}.xaxis = sprintf('x%d', ps);
  obj.data{p}.yaxis = sprintf('y%d', ps);
  obj.data{p}.showlegend = false;

  if bygroups
    try
      obj.data{p}.name = char(gs(t));
    catch
      obj.data{p}.name = char(string(gs(t)));
    end
  end

  %-----------------------------------------------------------------------%

end

%-------------------------------------------------------------------------%

%-create xaxis layout-%
ybase = yaxis.domain;
if ~isempty(strfind(scatter_data.ScatterPlotLocation, 'West'))
  xo2 = xo + w * 1.0075;
  w2 = 0.96 - xo2;
elseif ~isempty(strfind(scatter_data.ScatterPlotLocation, 'East'))
  xo2 = 0.02;
  w2 = xo*0.7 - xo2;
end

yo2 = yo;
h2 = h;

xaxis2.showgrid = false;
xaxis2.showticklabels = false;
xaxis2.zeroline = true;
xaxis2.zerolinecolor = axiscol;
xaxis2.domain = min([xo2 xo2+w2],1);
xaxis2.anchor = sprintf('y%d', ps);
xaxis2.color = 'rgba(0,0,0,0)';

if xoverlay
    xaxis2.overlaying = sprintf('x%d', ps);
end

%-------------------------------------------------------------------------%

%-create yaxis layout-%
yaxis2.showgrid = false;
yaxis2.showticklabels = false;
yaxis2.zeroline = false;
yaxis2.domain = min([yo2 yo2+h2],1);
yaxis2.anchor = sprintf('x%d', ps);
yaxis2.color = 'rgba(0,0,0,0)';

if ~ycateg
  yaxis2.range = scatter_data.YLimits;
else
  yaxis2.range = [min(yplot)-0.5, max(yplot)+0.5];
  yaxis2.tickvals = 1:max(yplot);
  yaxis2.ticktext = yc;
end

if yoverlay
    yaxis2.overlaying = sprintf('y%d', ps);
end

%-------------------------------------------------------------------------%

%-set x and y axis layout-%
obj.layout = setfield(obj.layout, sprintf('xaxis%d',ps), xaxis2);
obj.layout = setfield(obj.layout, sprintf('yaxis%d',ps), yaxis2);

%-------------------------------------------------------------------------%

end

