function updatePolarplot(obj,plotIndex)
    
%-------------------------------------------------------------------------%
    
%-Get plot class-%
plotclass = obj.State.Plot(plotIndex).Class;

%-------------------------------------------------------------------------%

%-run the correct plot class-%
if strcmpi(plotclass, 'line')
    updatePolarline(obj,plotIndex)
elseif strcmpi(plotclass, 'polaraxes')
    updatePolaraxes(obj,plotIndex)
end

%-------------------------------------------------------------------------%

end


%-------------------------------------------------------------------------%
%-HELPERS FUNCTIONS-%
%-------------------------------------------------------------------------%

function updatePolaraxes(obj,plotIndex)

%-------------------------------------------------------------------------%
    
%-PLOT DATA STRUCTURE-%
plot_data = get(obj.State.Plot(plotIndex).Handle);

%-------------------------------------------------------------------------%
    
%-setting polar axes-%
gridcolor = 'rgb(235,235,235)';
linecolor = 'rgb(210,210,210)';

%-R-axis-%
obj.layout.polar.angularaxis.tickmode = 'array';
obj.layout.polar.angularaxis.tickvals = plot_data.ThetaTick(1:end-1);
obj.layout.polar.angularaxis.gridcolor = gridcolor;
obj.layout.polar.angularaxis.linecolor = linecolor;
obj.layout.polar.angularaxis.ticks = '';

%-Theta-axis-%
obj.layout.polar.radialaxis.angle = plot_data.RAxisLocation;
obj.layout.polar.radialaxis.tickmode = 'array';
obj.layout.polar.radialaxis.tickvals = plot_data.RTick;
obj.layout.polar.radialaxis.gridcolor = gridcolor;
obj.layout.polar.radialaxis.showline = false;
obj.layout.polar.radialaxis.tickangle = 90;
obj.layout.polar.radialaxis.ticks = '';

%-------------------------------------------------------------------------%

end

function updatePolarline(obj,plotIndex)

%-------------------------------------------------------------------------%

%-PLOT DATA STRUCTURE- %
plot_data = get(obj.State.Plot(plotIndex).Handle);

%-------------------------------------------------------------------------%

%-scatterpolar type-%
obj.data{plotIndex}.type = 'scatterpolar';

%-------------------------------------------------------------------------%

%-scatter visible-%
obj.data{plotIndex}.visible = strcmp(plot_data.Visible,'on');

%-------------------------------------------------------------------------%

%-scatter r-data-%
obj.data{plotIndex}.r = abs(plot_data.RData);

%-------------------------------------------------------------------------%

%-scatter theta-data-%
obj.data{plotIndex}.theta = rad2deg(plot_data.ThetaData);

%-------------------------------------------------------------------------%

%-scatterpolar name-%
obj.data{plotIndex}.name = plot_data.DisplayName;

%-------------------------------------------------------------------------%

%-scatterpolar mode-%
if ~strcmpi('none', plot_data.Marker) ...
        && ~strcmpi('none', plot_data.LineStyle)
    mode = 'lines+markers';
elseif ~strcmpi('none', plot_data.Marker)
    mode = 'markers';
elseif ~strcmpi('none', plot_data.LineStyle)
    mode = 'lines';
else
    mode = 'none';
end

obj.data{plotIndex}.mode = mode;

%-------------------------------------------------------------------------%

%-scatter line-%
obj.data{plotIndex}.line = extractLineLine(plot_data);
obj.data{plotIndex}.line.width = 2 * obj.data{plotIndex}.line.width;

%-------------------------------------------------------------------------%

%-scatter marker-%
obj.data{plotIndex}.marker = extractLineMarker(plot_data);

%-------------------------------------------------------------------------%

%-scatter showlegend-%
leg = get(plot_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{plotIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

end