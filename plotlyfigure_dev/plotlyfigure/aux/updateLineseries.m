function updateLineseries(obj,dataIndex)

%----SCATTER FIELDS----%

% x - [DONE]
% y - [DONE]
% r - [HANDLED BY SCATTER]
% t - [HANDLED BY SCATTER]
% mode - [DONE]
% name - [DONE]
% text - [NOT SUPPORTED IN MATLAB]
% error_y - [HANDLED BY ERRORBAR]
% error_x - [NOT SUPPORTED IN MATLAB]
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

%-FIGURE STRUCTURE-%
figure_data = get(obj.State.Figure.Handle);

%-AXIS STRUCTURE-%
axis_data = get(obj.State.Plot(dataIndex).AssociatedAxis);

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);

%-PLOT DATA STRUCTURE- %
plot_data = get(obj.State.Plot(dataIndex).Handle);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(axIndex) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(axIndex) ';']);

%-------------------------------------------------------------------------%

%-SCATTER XAXIS-%
obj.data{dataIndex}.xaxis = ['x' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-SCATTER YAXIS-%
obj.data{dataIndex}.yaxis = ['y' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-SCATTER TYPE-%
obj.data{dataIndex}.type = 'scatter';

%-------------------------------------------------------------------------%

%-SCATTER X-%
obj.data{dataIndex}.x = plot_data.XData;

%-------------------------------------------------------------------------%

%-SCATTER Y-%
obj.data{dataIndex}.y = plot_data.YData;

%-------------------------------------------------------------------------%

%-SCATTER NAME-%
obj.data{dataIndex}.name = plot_data.DisplayName;

%-------------------------------------------------------------------------%

%-MARKER SIZE-%
obj.data{dataIndex}.marker.size = plot_data.MarkerSize;

%-------------------------------------------------------------------------%

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

obj.data{dataIndex}.mode = mode;

%-MARKER SYMBOL-%
if ~strcmp(plot_data.Marker,'none')
    
    switch plot_data.Marker
        case '.'
            marksymbol = 'circle';
        case 'o'
            marksymbol = 'circle';
        case 'x'
            marksymbol = 'x-thin-open';
        case '+'
            marksymbol = 'cross-thin-open';
        case '*'
            marksymbol = 'asterisk-open';
        case {'s','square'}
            marksymbol = 'square';
        case {'d','diamond'}
            marksymbol = 'diamond';
        case 'v'
            marksymbol = 'triangle-down';
        case '^'
            marksymbol = 'triangle-up';
        case '<'
            marksymbol = 'triangle-left';
        case '>'
            marksymbol = 'triangle-right';
        case {'p','pentagram'}
            marksymbol = 'star';
        case {'h','hexagram'}
            marksymbol = 'hexagram';
    end
    
    obj.data{dataIndex}.marker.symbol = marksymbol;
end

%-------------------------------------------------------------------------%

%-MARKER LINE WIDTH-%
obj.data{dataIndex}.marker.line.width = plot_data.LineWidth;

if(~strcmp(plot_data.LineStyle,'none'))
    
    %-SCATTER LINE COLOR-%
    col = 255*plot_data.Color;
    obj.data{dataIndex}.line.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    
    %-SCATTER LINE WIDTH-%
    obj.data{dataIndex}.line.width = plot_data.LineWidth;
    
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
    obj.data{dataIndex}.line.dash = LineStyle;
end

%-------------------------------------------------------------------------%

%--MARKER FILL COLOR--%

MarkerColor = plot_data.MarkerFaceColor;
filledMarkerSet = {'o','square','s','diamond','d',...
    'v','^', '<','>','hexagram','pentagram'};

filledMarker = ismember(plot_data.Marker,filledMarkerSet);

if filledMarker
    if isnumeric(MarkerColor)
        col = 255*MarkerColor;
        markercolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    else
        switch MarkerColor
            case 'none'
                markercolor = 'rgba(0,0,0,0)';
            case 'auto'
                if ~strcmp(axis_data.Color,'none')
                    col = 255*axis_data.Color;
                    markercolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
                else
                    col = 255*figure_data.Color;
                    markercolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
                end
        end
    end
    
    obj.data{dataIndex}.marker.color = markercolor;
    
end

%-------------------------------------------------------------------------%

%-MARKER LINE COLOR-%

MarkerLineColor = plot_data.MarkerEdgeColor;
filledMarkerSet = {'o','square','s','diamond','d',...
    'v','^', '<','>','hexagram','pentagram'};

filledMarker = ismember(plot_data.Marker,filledMarkerSet);

if isnumeric(MarkerLineColor)
    col = 255*MarkerLineColor;
    markerlinecolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
else
    switch MarkerLineColor
        case 'none'
            markerlinecolor = 'rgba(0,0,0,0)';
        case 'auto'
            col = 255*plot_data.Color;
            markerlinecolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    end
end

if filledMarker
    obj.data{dataIndex}.marker.line.color = markerlinecolor;
else
    obj.data{dataIndex}.marker.color = markerlinecolor;
end

%-------------------------------------------------------------------------%

%-SCATTER SHOWLEGEND-%
leg = get(plot_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{dataIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

%-SCATTER VISIBLE-%
obj.data{dataIndex}.visible = strcmp(plot_data.Visible,'on');

end



