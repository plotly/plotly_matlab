function obj = extractPlotData(obj)

%----SCATTER FIELDS----%

% x - [DONE]
% y - [DONE]
% r - [HANDLED BY SCATTER]
% t - [HANDLED BY SCATTER]
% mode - [DONE]
% name - [DONE]
% text - [NOT SUPPORTED IN MATLAB]
% error_y - [HANDLED BY ERRORBAR]
% error_x - [HANDLED BY ERRORBAR]
% marler.color - [DONE]
% marker.size - [DONE]
% marker.line.color - [DONE]
% marker.line.width - [DONE]
% marker.line.dash - [NOT SUPPORTED IN MATLAB]
% marker.line.opacity - [NOT SUPPORTED IN MATLAB]
% marker.line.smoothing - [NOT SUPPORTED IN MATLAB]
% marker.line.shape - [NOT SUPPORTED IN MATLAB]
% marker.opacity - [NOT SUPPORTED IN MATLAB]
% marker.colorscale - [NOT SUPPORTED IN MATLAB]
% marker.sizemode - [NOT SUPPORTED IN MATLAB]
% marker.sizeref - [NOT SUPPORTED IN MATLAB]
% marker.maxdisplayed - [NOT SUPPORTED IN MATLAB]
% line.color - [DONE]
% line.width - [DONE]
% line.dash - [DONE]
% line.opacity - [NOT SUPPORTED IN MATLAB]
% line.smoothing - [NOT SUPPORTED IN MATLAB]
% line.shape - [NOT SUPPORTED IN MATLAB]
% connectgaps - [NOT SUPPORTED IN MATLAB]
% fill - [HANDLED BY AREA]
% fillcolor - [HANDLED BY AREA]
% opacity - [NOT SUPPORTED IN MATLAB]
% textfont - [NOT SUPPORTED IN MATLAB]
% textposition - [NOT SUPPORTED IN MATLAB]
% xaxis [DONE]
% yaxis [DONE]
% showlegend [DONE]
% stream - [HANDLED BY PLOTLYSTREAM]
% visible [DONE]
% type [DONE]

%-PLOT FIGURE STRUCTURE-%

plot_figure = get(obj.State.Figure.Handle);

%-PLOT AXIS STRUCTURE-%

plot_axis = get(obj.State.Data(obj.State.CurrentDataIndex).AxisHandle);

%-PLOT DATA STRUCTURE- %

plot_data = get(obj.State.Data(obj.State.CurrentDataIndex).Handle);

%-SCATTER X-%

data{obj.State.CurrentDataIndex}.x = plot_data.XData;

%-SCATTER Y-%

data{obj.State.CurrentDataIndex}.y = plot_data.YData;

%-SCATTER R-%

%[HANDLED BY SCATTER]

%-SCATTER T-%

%[HANDLED BY SCATTER]

%-SCATTER MODE-%

if ~strcmpi('none', plot_data.Marker) && ~strcmpi('none', plot_data.LineStyle)
    mode = 'lines+markers';
elseif ~strcmpi('none', plot_data.Marker)
    mode = 'markers';
elseif ~strcmpi('none', plot_data.LineStyle)
    mode = 'lines';
else
    mode = 'none';
end

data{obj.State.CurrentDataIndex}.mode = mode;

%-SCATTER NAME-%

data{obj.State.CurrentDataIndex}.name = get(plot_axis.YLabel,'string');

%-SCATTER TEXT-%

%TODO

%-SCATTER ERROR_Y-%

%[HANDLED BY ERRORBAR]

%-SCATTER ERROR_X-%

%[HANDLED BY ERRORBAR]

%-SCATTER MARKER-%

%--SCATTER MARKER SIZE--%
data{obj.State.CurrentDataIndex}.marker.size = plot_data.MarkerSize;

%--SCATTER MARKER SYMBOL--%
filledMarker = false;
switch plot_data.Marker
    case '.'
        data{obj.State.CurrentDataIndex}.marker.symbol = 'circle';
    case 'o'
        data{obj.State.CurrentDataIndex}.marker.symbol = 'circle';
        filledMarker = true;
    case 'x'
        data{obj.State.CurrentDataIndex}.marker.symbol = 'x-thin-open';
    case '+'
        data{obj.State.CurrentDataIndex}.marker.symbol = 'cross-thin-open';
    case '*'
        data{obj.State.CurrentDataIndex}.marker.symbol = 'asterisk-open';
    case {'s','square'}
        data{obj.State.CurrentDataIndex}.marker.symbol = 'square';
        filledMarker = true;
    case {'d','diamond'}
        data{obj.State.CurrentDataIndex}.marker.symbol = 'diamond';
        filledMarker = true;
    case 'v'
        data{obj.State.CurrentDataIndex}.marker.symbol = 'triangle-down';
        filledMarker = true;
    case '^'
        data{obj.State.CurrentDataIndex}.marker.symbol = 'triangle-up';
        filledMarker = true;
    case '<'
        data{obj.State.CurrentDataIndex}.marker.symbol = 'triangle-left';
        filledMarker = true;
    case '>'
        data{obj.State.CurrentDataIndex}.marker.symbol = 'triangle-right';
        filledMarker = true;
    case {'p','pentagram'}
        data{obj.State.CurrentDataIndex}.marker.symbol = 'star';
        filledMarker = true;
    case {'h','hexagram'}
        data{obj.State.CurrentDataIndex}.marker.symbol = 'hexagram';
        filledMarker = true;
end

%--SCATTER MARKER COLOR--%
MarkerColor = plot_data.MarkerFaceColor;

if filledMarker
    if ~ischar(MarkerColor)
        col = 255*MarkerColor;
        markercolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    else
        switch MarkerColor
            case 'none'
                markercolor = 'rgba(0,0,0,0)';
            case 'auto'
                if ~strcmp(plot_axis.Color,'none')
                    col = 255*plot_axis.Color;
                    markercolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
                else
                    col = 255*plot_figure.Color;
                    markercolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
                end 
        end
    end
    data{obj.State.CurrentDataIndex}.marker.color = markercolor;
end

%--SCATTER MARKER LINE--%

%--SCATTER MARKER LINE COLOR--%
MarkerLineColor = plot_data.MarkerEdgeColor;

if ~ischar(MarkerLineColor)
    mlc = 255*MarkerLineColor;
    markerlinecolor = ['rgb(' num2str(mlc(1)) ',' num2str(mlc(2)) ',' num2str(mlc(3)) ')'];
else
    switch MarkerLineColor
        case 'none'
            markerlinecolor = 'rgba(0,0,0,0)';
        case 'auto'
            col = 255*plot_data.Color;
            markerlinecolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    end
end

data{obj.State.CurrentDataIndex}.marker.line.color = markerlinecolor;

%--SCATTER MARKER LINE WIDTH--%
data{obj.State.CurrentDataIndex}.marker.line.width = plot_data.LineWidth;

%--SCATTER MARKER LINE DASH--%
data{obj.State.CurrentDataIndex}.marker.line.dash = 'solid';

%--SCATTER MARKER LINE OPACITY--%

%[NOT SUPPORTED IN MATLAB: setting to 0.9]
data{obj.State.CurrentDataIndex}.marker.line.opacity = 0.9;

%--SCATTER MARKER LINE SMOOTHING--%

%[NOT SUPPORTED IN MATLAB: setting to 1]
data{obj.State.CurrentDataIndex}.marker.line.smoothing = 1;

%--SCATTER MARKER LINE SHAPE--%

%[NOT SUPPORTED IN MATLAB: setting to linear]
data{obj.State.CurrentDataIndex}.marker.line.shape = 'linear';

%--SCATTER MARKER OPACITY--%

%[NOT SUPPORTED IN MATLAB: setting to 0.9]
data{obj.State.CurrentDataIndex}.marker.opacity = 0.9;

%--SCATTER MARKER COLOR SCALE--%

%[NOT SUPPORTED IN MATLAB: left unset]

%--SCATTER MARKER SIZE MODE--%

%[NOT SUPPORTED IN MATLAB: left unset]

%--SCATTER MARKER SIZE REF--%

%[NOT SUPPORTED IN MATLAB: left unset]

%--SCATTER MARKER MAX DISPLAYED--%

%[NOT SUPPORTED IN MATLAB: left unset]

if(~strcmp(plot_data.LineStyle,'none'))
    
    %-SCATTER LINE-%
    
    %-SCATTER LINE COLOR-%
    col = 255*plot_data.Color; 
    data{obj.State.CurrentDataIndex}.line.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    
    %-SCATTER LINE WIDTH-%
    
    data{obj.State.CurrentDataIndex}.line.width = plot_data.LineWidth;
    
    %-SCATTER LINE DASH-%
    
    switch plot_data.LineStyle
        case '-'
            LineStyle = 'solid';
        case '--'
            LineStyle = 'dash';
        case ':'
            LineStyle = 'dot';
        case '-.'
            LineStyle = 'dashdot';
    end
    
    data{obj.State.CurrentDataIndex}.line.dash = LineStyle;
end

%-SCATTER LINE OPACITY-%

%[NOT SUPPORTED IN MATLAB: left unset]

%-SCATTER LINE SMOOTHING-%

%[NOT SUPPORTED IN MATLAB: left unset]

%-SCATTER LINE SHAPE-%

%[NOT SUPPORTED IN MATLAB: left unset]

%-SCATTER CONNECTGAPS-%

%[NOT SUPPORTED IN MATLAB: setting to true]
data{obj.State.CurrentDataIndex}.connectgap = true;

%-SCATTER FILL-%

%[HANDLED BY AREA]

%-SCATTER FILLCOLOR-%

%[HANDLED BY AREA]

%-SCATTER OPACITY-%

%[NOT SUPPORTED IN MATLAB: left unset]

%-SCATTER TEXTFONT-%

%TODO

%-SCATTER TEXTPOSITION-%

%TODO

%-SCATTER XAXIS-%
data{obj.State.CurrentDataIndex}.xaxis = ['x' num2str(obj.State.CurrentAxisIndex)];

%-SCATTER YAXIS-%
data{obj.State.CurrentDataIndex}.yaxis = ['y' num2str(obj.State.CurrentAxisIndex)];

%-SCATTER SHOWLEGEND-%
leg = get(plot_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

data{obj.State.CurrentDataIndex}.showlegend = showleg;

%-SCATTER STREAM-%

%[HANDLED BY PLOTLYSTREAM]

%-SCATTER VISIBLE-%
data{obj.State.CurrentDataIndex}.visible = strcmp(plot_data.Visible,'on');

%-SCATTER TYPE-%
data{obj.State.CurrentDataIndex}.type = 'scatter';

%-ADD DATA-%
obj.Data = data;

end
