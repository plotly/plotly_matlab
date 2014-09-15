function updateAreaseries(obj,areaIndex)

%----AREA FIELDS----%

% x - [DONE]
% y - [DONE]
% r - [HANDLED BY SCATTER]
% t - [HANDLED BY SCATTER]
% mode - [DONE]
% name - [DONE]
% text - [NOT SUPPORTED IN MATLAB]
% error_y - [HANDLED BY ERRORBAR]
% error_x - [HANDLED BY ERRORBAR]
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

% MARKER
% marker.color - [DONE]
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

% LINE

% line.color - [DONE]
% line.width - [DONE]
% line.dash - [DONE]
% line.opacity ------------------------------------------> [TODO]
% line.smoothing - [NOT SUPPORTED IN MATLAB]
% line.shape - [NOT SUPPORTED IN MATLAB]



%-FIGURE STRUCTURE-%
figure_data = get(obj.State.Figure.Handle);

%-AXIS STRUCTURE-%
axis_data = get(obj.State.Plot(areaIndex).AssociatedAxis);

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(areaIndex).AssociatedAxis);

%-AREA DATA STRUCTURE- %
area_data = get(obj.State.Plot(areaIndex).Handle);

%-AREA CHILD DATA STRUCTURE- %
area_child_data = get(area_data.Children(1));

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(axIndex) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(axIndex) ';']);

%-------------------------------------------------------------------------%

%-AREA XAXIS-%
obj.data{areaIndex}.xaxis = ['x' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-AREA YAXIS-%
obj.data{areaIndex}.yaxis = ['y' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-AREA TYPE-%
obj.data{areaIndex}.type = 'scatter';

%-------------------------------------------------------------------------%

%-AREA X-%
obj.data{areaIndex}.x = area_data.XData;

%-------------------------------------------------------------------------%

%-AREA Y-%
ydata = area_child_data.YData;
obj.data{areaIndex}.y = ydata(2:(numel(ydata)-1)/2+1)';

%-------------------------------------------------------------------------%

%-AREA NAME-%
obj.data{areaIndex}.name = area_child_data.DisplayName;

%-------------------------------------------------------------------------%

%-MARKER SIZE-%
obj.data{areaIndex}.marker.size = area_child_data.MarkerSize;

%-------------------------------------------------------------------------%

%-AREA MODE-%
if ~strcmpi('none', area_child_data.Marker) && ~strcmpi('none', area_child_data.LineStyle)
    mode = 'lines+markers';
elseif ~strcmpi('none', area_child_data.Marker)
    mode = 'markers';
elseif ~strcmpi('none', area_child_data.LineStyle)
    mode = 'lines';
else
    mode = 'none';
end

obj.data{areaIndex}.mode = mode;

%-MARKER SYMBOL-%
if ~strcmp(area_child_data.Marker,'none')
    
    switch area_child_data.Marker
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
    
    obj.data{areaIndex}.marker.symbol = marksymbol;
    
end

%-------------------------------------------------------------------------%

%-MARKER LINE WIDTH-%
obj.data{areaIndex}.marker.line.width = area_child_data.LineWidth;

if(~strcmp(area_child_data.LineStyle,'none'))
    
    %-AREA LINE COLOR-%
    if isnumeric(area_child_data.EdgeColor)
        
        col = 255*area_child_data.EdgeColor;
        obj.data{areaIndex}.line.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
        
    else
        switch area_child_data.FaceColor
            case 'none'
                obj.data{areaIndex}.line.color = 'rgba(0,0,0,0,)';
            case 'flat'
                col = 255*figure_data.Colormap(area_child_data.CData(1),:);
                obj.data{areaIndex}.line.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
        end
    end
    
    
    %-AREA LINE WIDTH-%
    obj.data{areaIndex}.line.width = area_child_data.LineWidth;
    
    %-AREA LINE DASH-%
    switch area_child_data.LineStyle
        case '-'
            LineStyle = 'solid';
        case '--'
            LineStyle = 'dash';
        case ':'
            LineStyle = 'dot';
        case '-.'
            LineStyle = 'dashdot';
    end
    obj.data{areaIndex}.line.dash = LineStyle;
end

%-------------------------------------------------------------------------%

%--MARKER FILL COLOR--%

MarkerColor = area_child_data.MarkerFaceColor;
filledMarkerSet = {'o','square','s','diamond','d',...
    'v','^', '<','>','hexagram','pentagram'};

filledMarker = ismember(area_child_data.Marker,filledMarkerSet);

if filledMarker
    if ~ischar(MarkerColor)
        col = 255*MarkerColor;
        markercolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    else
        switch MarkerColor
            case 'none'
                markercolor = 'rgba(0,0,0,0)';
            case 'auto'
                markercolor = obj.data{areaIndex}.line.color;
        end
    end
    
    obj.data{areaIndex}.marker.color = markercolor;
    
end

%-------------------------------------------------------------------------%

%-MARKER LINE COLOR-%

MarkerLineColor = area_child_data.MarkerEdgeColor;

if isnumeric(MarkerLineColor)
    col = 255*MarkerLineColor;
    markerlinecolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
else
    switch MarkerLineColor
        case 'none'
            markerlinecolor = 'rgba(0,0,0,0)';
        case 'auto'
            markerlinecolor = obj.data{areaIndex}.line.color;
    end
end

if filledMarker
    obj.data{areaIndex}.marker.line.color = markerlinecolor;
else
    obj.data{areaIndex}.marker.color = markerlinecolor;
end

%-------------------------------------------------------------------------%

%-AREA SHOWLEGEND-%
leg = get(area_child_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{areaIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

%-AREA VISIBLE-%
obj.data{areaIndex}.visible = strcmp(area_child_data.Visible,'on');

%-------------------------------------------------------------------------%

%-AREA FILL-%
obj.data{areaIndex}.fill = 'tozeroy';

%-------------------------------------------------------------------------%

%-AREA FILL COLOR-%
if isnumeric(area_child_data.FaceColor)
    
    col = 255*area_child_data.FaceColor;
    obj.data{areaIndex}.fillcolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    
else
    switch area_child_data.FaceColor
        case 'none'
            obj.data{areaIndex}.fillcolor = 'rgba(0,0,0,0,)';
        case 'flat'
            switch area_child_data.CDataMapping
                case 'scaled'
                    mapcol = max(axis_data.CLim(1),area_child_data.CData(1));
                    mapcol = min(axis_data.CLim(2),mapcol);
                    mapcol = axis_data.CLim(1) + floor((length(figure_data.Colormap)-1)/diff(axis_data.CLim))*(mapcol-axis_data.CLim(1));
                    col = 255*figure_data.Colormap(mapcol,:);
                case 'direct'
                    col = 255*figure_data.Colormap(area_child_data.CData(1),:);
            end
            
            obj.data{areaIndex}.fillcolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    end
end

end



