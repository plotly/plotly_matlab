function obj = updatePatch(obj, patchIndex)


%----PATCH FIELDS----%

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
% fill - [HANDLED BY PATCH]
% fillcolor - [HANDLED BY PATCH]
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
axis_data = get(obj.State.Plot(patchIndex).AssociatedAxis);

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(patchIndex).AssociatedAxis);

%-PATCH DATA STRUCTURE- %
patch_data = get(obj.State.Plot(patchIndex).Handle);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(axIndex) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(axIndex) ';']);

%-------------------------------------------------------------------------%

%-PATCH XAXIS-%
obj.data{patchIndex}.xaxis = ['x' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-PATCH YAXIS-%
obj.data{patchIndex}.yaxis = ['y' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-PATCH TYPE-%
obj.data{patchIndex}.type = 'scatter';

%-------------------------------------------------------------------------%

%-PATCH X-%
xdata = patch_data.XData;
if isvector(xdata)
    obj.data{patchIndex}.x = xdata;
else
    xtemp = reshape(xdata,[],1);
    xnew = [];
    for n = 1:size(xdata,2)
        xnew = [xnew ; xdata(:,n) ; xdata(1,n); NaN];
    end
    obj.data{patchIndex}.x = xnew;
end

%-------------------------------------------------------------------------%

%-PATCH Y-%
ydata = patch_data.YData;
if isvector(ydata)
    obj.data{patchIndex}.y = ydata(2:(numel(ydata)-1)/2+1)';
else
    ytemp = reshape(ydata,[],1);
    ynew = [];
    for n = 1:size(ydata,2)
        ynew = [ynew ; ydata(:,n) ; ydata(1,n); NaN];
    end
    obj.data{patchIndex}.y = ynew;
end

%-------------------------------------------------------------------------%

%-PATCH NAME-%
if ~isempty(patch_data.DisplayName);
    obj.data{patchIndex}.name = patch_data.DisplayName;
else
    obj.data{patchIndex}.name = patch_data.DisplayName;
end

%-------------------------------------------------------------------------%

%-MARKER SIZE-%
obj.data{patchIndex}.marker.size = patch_data.MarkerSize;

%-------------------------------------------------------------------------%

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

%-MARKER SYMBOL-%
if ~strcmp(patch_data.Marker,'none')
    
    switch patch_data.Marker
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
    
    obj.data{patchIndex}.marker.symbol = marksymbol;
    
end

%-------------------------------------------------------------------------%

%-MARKER LINE WIDTH-%
obj.data{patchIndex}.marker.line.width = patch_data.LineWidth;

if(~strcmp(patch_data.LineStyle,'none'))
    
    %-PATCH LINE COLOR-%
    
    if isnumeric(patch_data.EdgeColor)
        
        col = 255*patch_data.EdgeColor;
        obj.data{patchIndex}.line.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
        
    else
        switch patch_data.FaceColor
            case 'none'
                obj.data{patchIndex}.line.color = 'rgba(0,0,0,0,)';
            case 'flat'
                col = 255*figure_data.Colormap(patch_data.CData(1),:);
                obj.data{patchIndex}.line.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
        end
    end
    
    
    %-PATCH LINE WIDTH-%
    obj.data{patchIndex}.line.width = patch_data.LineWidth;
    
    %-PATCH LINE DASH-%
    switch patch_data.LineStyle
        case '-'
            LineStyle = 'solid';
        case '--'
            LineStyle = 'dash';
        case ':'
            LineStyle = 'dot';
        case '-.'
            LineStyle = 'dashdot';
    end
    obj.data{patchIndex}.line.dash = LineStyle;
end

%-------------------------------------------------------------------------%

%--MARKER FILL COLOR--%

MarkerColor = patch_data.MarkerFaceColor;
filledMarkerSet = {'o','square','s','diamond','d',...
    'v','^', '<','>','hexagram','pentagram'};

filledMarker = ismember(patch_data.Marker,filledMarkerSet);

if filledMarker
    if ~ischar(MarkerColor)
        col = 255*MarkerColor;
        markercolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    else
        switch MarkerColor
            case 'none'
                markercolor = 'rgba(0,0,0,0)';
            case 'auto'
                markercolor = obj.data{patchIndex}.line.color;
        end
    end
    
    obj.data{patchIndex}.marker.color = markercolor;
    
end

%-------------------------------------------------------------------------%

%-MARKER LINE COLOR-%

MarkerLineColor = patch_data.MarkerEdgeColor;

if isnumeric(MarkerLineColor)
    col = 255*MarkerLineColor;
    markerlinecolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
else
    switch MarkerLineColor
        case 'none'
            markerlinecolor = 'rgba(0,0,0,0)';
        case 'auto'
            markerlinecolor = obj.data{patchIndex}.line.color;
    end
end

if filledMarker
    obj.data{patchIndex}.marker.line.color = markerlinecolor;
else
    obj.data{patchIndex}.marker.color = markerlinecolor;
end

%-------------------------------------------------------------------------%

%-PATCH SHOWLEGEND-%
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

%-PATCH VISIBLE-%
obj.data{patchIndex}.visible = strcmp(patch_data.Visible,'on');

%-------------------------------------------------------------------------%

%-PATCH FILL-%
obj.data{patchIndex}.fill = 'tonexty';

%-------------------------------------------------------------------------%

%-PATCH FILL COLOR-%
if isnumeric(patch_data.FaceColor)
    
    col = 255*patch_data.FaceColor;
    obj.data{patchIndex}.fillcolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    
else
    switch patch_data.FaceColor
        case 'none'
            obj.data{patchIndex}.fillcolor = 'rgba(0,0,0,0,)';
        case 'flat'
            switch patch_data.CDataMapping
                case 'scaled'
                    mapcol = max(axis_data.CLim(1),patch_data.CData(1));
                    mapcol = min(axis_data.CLim(2),mapcol);
                    mapcol = axis_data.CLim(1) + floor((length(figure_data.Colormap)-1)/diff(axis_data.CLim))*(mapcol-axis_data.CLim(1));
                    col = 255*figure_data.Colormap(mapcol,:);
                case 'direct'
                    col = 255*figure_data.Colormap(patch_data.CData(1),:);
            end
            
            obj.data{patchIndex}.fillcolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    end
end

end
