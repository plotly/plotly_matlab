function obj = extractPlotData(obj)

%-PLOT AXIS STRUCTURE-%

plot_axis = get(obj.State.AxisHandle(obj.State.CurrentAxisHandleIndex));

%-PLOT DATA STRUCTURE- %

plot_data = get(obj.State.DataHandle(obj.State.CurrentDataHandleIndex));

%-SCATTER X-%

data{obj.State.CurrentDataHandleIndex}.x = plot_data.XData;

%-SCATTER Y-%

data{obj.State.CurrentDataHandleIndex}.y = plot_data.XData;

%-SCATTER R-%

%TODO 

%-SCATTER T-%

%TODO 

%-SCATTER MODE-%

if ~strcmpi('none', plot_data.Marker) && ~strcmpi('none', plot_data.LineStyle)
    data{obj.State.CurrentDataHandleIndex}.mode = 'lines+markers';
elseif ~strcmpi('none', plot_data.Marker)
    data{obj.State.CurrentDataHandleIndex}.mode = 'markers';
elseif ~strcmpi('none', plot_data.LineStyle)
    data{obj.State.CurrentDataHandleIndex}.mode = 'lines';
else
    data{obj.State.CurrentDataHandleIndex}.mode = 'none';
end

%-SCATTER NAME-%

data{obj.State.CurrentDataHandleIndex}.name = get(plot_axis.YLabel,'string'); 

%-SCATTER TEXT-%

%TODO

%-SCATTER ERROR_Y-%

%TODO

%-SCATTER ERROR_X-%

%TODO 

%-SCATTER MARKER-%

%--SCATTER MARKER COLOR--%
col = 255*plot_data.Color; 
data{obj.State.CurrentDataHandleIndex}.marker.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')']; 

%--SCATTER MARKER SIZE--%
data{obj.State.CurrentDataHandleIndex}.marker.size = plot_data.MarkerSize; 

%--SCATTER MARKER SYMBOL--%
closedMarker = false;
switch plot_data.Marker
    case '.'
        data{obj.State.CurrentDataHandleIndex}.marker.symbol = 'circle';
    case 'o'
        data{obj.State.CurrentDataHandleIndex}.marker.symbol = 'circle';
        closedMarker = true;
    case 'x'
        data{obj.State.CurrentDataHandleIndex}.marker.symbol = 'x-thin-open';
    case '+'
        data{obj.State.CurrentDataHandleIndex}.marker.symbol = 'cross-thin-open';
    case '*'
        data{obj.State.CurrentDataHandleIndex}.marker.symbol = 'asterisk-open';
    case {'s','square'}
        data{obj.State.CurrentDataHandleIndex}.marker.symbol = 'square';
        closedMarker = true;
    case {'d','diamond'}
        data{obj.State.CurrentDataHandleIndex}.marker.symbol = 'diamond';
        closedMarker = true;
    case 'v'
        data{obj.State.CurrentDataHandleIndex}.marker.symbol = 'triangle-down';
        closedMarker = true;
    case '^'
        data{obj.State.CurrentDataHandleIndex}.marker.symbol = 'triangle-up';
        closedMarker = true;
    case '<'
        data{obj.State.CurrentDataHandleIndex}.marker.symbol = 'triangle-left';
        closedMarker = true;
    case '>'
        data{obj.State.CurrentDataHandleIndex}.marker.symbol = 'triangle-right';
        closedMarker = true;
    case {'p','pentagram'}
        data{obj.State.CurrentDataHandleIndex}.marker.symbol = 'star';
        closedMarker = true;
    case {'h','hexagram'}
        data{obj.State.CurrentDataHandleIndex}.marker.symbol = 'hexagram';
        closedMarker = true;
end

%--SCATTER MARKER LINE--%

%--SCATTER MARKER LINE COLOR--%

%TODO 

%--SCATTER MARKER LINE WIDTH--%
data{obj.State.CurrentDataHandleIndex}.marker.line.width = plot_data.LineWidth;

%--SCATTER MARKER LINE DASH--%

%TODO 

%--SCATTER MARKER LINE OPACITY--%

%TODO 

%--SCATTER MARKER LINE SMOOTHING--%

%TODO 

%--SCATTER MARKER LINE SHAPE--%

%TODO 

%--SCATTER MARKER OPACITY--%

%TODO 

%--SCATTER MARKER COLOR SCALE--%

%TODO 

%--SCATTER MARKER SIZE MODE--%

%TODO 

%--SCATTER MARKER SIZE REF--%

%TODO 

%--SCATTER MARKER MAX DISPLAYED--%

%TODO 

%-SCATTER LINE-%

%-SCATTER LINE COLOR-%

%TODO 

%-SCATTER LINE WIDTH-%

%TODO 

%-SCATTER LINE DASH-%

%TODO 

%-SCATTER LINE OPACITY-%

%TODO 

%-SCATTER LINE SMOOTHING-%

%TODO 

%-SCATTER LINE SHAPE-%

%TODO 

%-SCATTER CONNECTGAPS-%

%TODO 

%-SCATTER FILL-%

%TODO 

%-SCATTER FILLCOLOR-%

%TODO 

%-SCATTER OPACITY-%

%TODO 

%-SCATTER TEXTFONT-%

%TODO 

%-SCATTER TEXTPOSITION-%

%TODO 

%-SCATTER XAXIS-%
data{obj.State.CurrentDataHandleIndex}.xaxis = ['x' num2str(obj.State.CurrentAxisHandleIndex)];

%-SCATTER YAXIS-%
data{obj.State.CurrentDataHandleIndex}.yaxis = ['y' num2str(obj.State.CurrentAxisHandleIndex)];

%-SCATTER SHOWLEGEND-%

%TODO 

%-SCATTER STREAM-%

%TODO 

%-SCATTER VISIBLE-%
data{obj.State.CurrentDataHandleIndex}.type = strcmp(plot_data.Visible,'on'); 

%-SCATTER TYPE-%
data{obj.State.CurrentDataHandleIndex}.type = 'scatter'; 

%-ADD DATA-%
obj.Data = data;

end

