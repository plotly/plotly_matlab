function updateScattergroup(obj,scatterIndex)

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
% textfont - [NOT SUPPORTED IN MATLAB]
% textposition - [NOT SUPPORTED IN MATLAB]
% xaxis [DONE]
% yaxis [DONE]
% showlegend [DONE]
% stream - [HANDLED BY PLOTLYSTREAM]
% visible [DONE]
% type [DONE]
% opacity ------------------------------------------> [TODO]

% MARKER 
% marler.color - [DONE]
% marker.size - [DONE]
% marker.line.color - [DONE]
% marker.line.width - [DONE]
% marker.line.dash - [NOT SUPPORTED IN MATLAB]
% marker.line.opacity - [DONE]
% marker.line.smoothing - [NOT SUPPORTED IN MATLAB]
% marker.line.shape - [NOT SUPPORTED IN MATLAB]
% marker.opacity - [NOT SUPPORTED IN MATLAB]
% marker.colorscale - [NOT SUPPORTED IN MATLAB]
% marker.sizemode - [DONE]
% marker.sizeref - [DONE]
% marker.maxdisplayed - [NOT SUPPORTED IN MATLAB]

% LINE 
% line.color - [DONE]
% line.width - [DONE]
% line.dash - [DONE]
% line.opacity ------------------------------------------> [TODO]
% line.smoothing - [NOT SUPPORTED IN MATLAB]
% line.shape - [NOT SUPPORTED IN MATLAB]
% connectgaps - [NOT SUPPORTED IN MATLAB]
% fill - [HANDLED BY AREA]
% fillcolor - [HANDLED BY AREA]

%-FIGURE STRUCTURE-%
figure_data = get(obj.State.Figure.Handle);

%-AXIS STRUCTURE-%
axis_data = get(obj.State.Plot(scatterIndex).AssociatedAxis);

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(scatterIndex).AssociatedAxis);

%-SCATTER DATA STRUCTURE- %
scatter_data = get(obj.State.Plot(scatterIndex).Handle);

%-SCATTER CHILDREN-%
scatter_child = get(obj.State.Plot(scatterIndex).Handle,'Children');

%-SCATTER CHILDREN DATA-%
scatter_child_data = get(scatter_child);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(axIndex) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(axIndex) ';']);

%-------------------------------------------------------------------------%

%-SCATTER XAXIS-%
obj.data{scatterIndex}.xaxis = ['x' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-SCATTER YAXIS-%
obj.data{scatterIndex}.yaxis = ['y' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-SCATTER TYPE-%
obj.data{scatterIndex}.type = 'scatter';

%-------------------------------------------------------------------------%

%-SCATTER MODE-%
obj.data{scatterIndex}.mode = 'markers';

%-------------------------------------------------------------------------%

%-SCATTER SHOWLEGEND-%
leg = get(scatter_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{scatterIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

%-SCATTER VISIBLE-%
obj.data{scatterIndex}.visible = strcmp(scatter_data.Visible,'on');

%-------------------------------------------------------------------------%

%-SCATTER NAME-%
obj.data{scatterIndex}.name = scatter_child_data.DisplayName;

%-------------------------------------------------------------------------%

%-SCATTER OPACITY-%
obj.data{scatterIndex}.opacity = obj.PlotlyDefaults.MarkerOpacity;

%-------------------------------------------------------------------------%

%-MARKER SIZEREF-%
obj.data{scatterIndex}.marker.sizeref = 1;

%-------------------------------------------------------------------------%

%-MARKER SIZEMODE-%
obj.data{scatterIndex}.marker.sizemode = 'diameter';

%-------------------------------------------------------------------------%


%-SCATTER PATCH DATA-%

for m = 1:length(scatter_child_data)
    
    %reverse counter
    n = length(scatter_child_data) - m + 1; 
    
    %-------------------------------------------------------------------------%
    
    %-SCATTER X-%
    obj.data{scatterIndex}.x(m) = scatter_child_data(n).XData;
    
    %-------------------------------------------------------------------------%
    
    %-SCATTER Y-%
    obj.data{scatterIndex}.y(m) = scatter_child_data(n).YData;
    
    %-------------------------------------------------------------------------%
    
    %-MARKER SIZE-%
    obj.data{scatterIndex}.marker.size(m) = scatter_child_data(n).MarkerSize;
    
    %-------------------------------------------------------------------------%
    
    %-MARKER SYMBOL-%
    if ~strcmp(scatter_child_data(n).Marker,'none')
        
        switch scatter_child_data(n).Marker
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
        
        obj.data{scatterIndex}.marker.symbol{m} = marksymbol;
    end
    
    %-------------------------------------------------------------------------%
    
    %-MARKER LINE WIDTH-%
    obj.data{scatterIndex}.marker.line.width(m) = scatter_child_data(n).LineWidth;
    
    %-------------------------------------------------------------------------%
    
    %-MARKER OPACITY-%
    obj.data{scatterIndex}.marker.opacity(m) = obj.PlotlyDefaults.MarkerOpacity;
    
    %-------------------------------------------------------------------------%
    
    %--MARKER FILL COLOR--%
    
    %-figure colormap-%
    colormap = figure_data.Colormap;
    
    MarkerColor = scatter_child_data(n).MarkerFaceColor;
    
    filledMarkerSet = {'o','square','s','diamond','d',...
        'v','^', '<','>','hexagram','pentagram'};
    
    filledMarker = ismember(scatter_child_data(n).Marker,filledMarkerSet);
    
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
                    
                case 'flat'
                    
                    switch scatter_child_data(n).CDataMapping
                        
                        case 'scaled'
                            capCD = max(min(scatter_child_data(n).FaceVertexCData(1,1),axis_data.CLim(2)),axis_data.CLim(1));
                            scalefactor = (capCD - axis_data.CLim(1))/diff(axis_data.CLim);
                            col =  255*(colormap(1 + floor(scalefactor*(length(colormap)-1)),:));
                        case 'direct'
                            col =  255*(colormap(scatter_child_data(n).FaceVertexCData(1,1),:));
                    end
                    
                    markercolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
                    
            end
        end
        
        obj.data{scatterIndex}.marker.color{m} = markercolor;
        
    end
    
    
    
    %-------------------------------------------------------------------------%
    
    %-MARKER LINE COLOR-%
    
    MarkerLineColor = scatter_child_data(n).MarkerEdgeColor;
    
    filledMarker = ismember(scatter_child_data(n).Marker,filledMarkerSet);
    
    if isnumeric(MarkerLineColor)
        col = 255*MarkerLineColor;
        markerlinecolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    else
        switch MarkerLineColor
            
            case 'none'
                markerlinecolor = 'rgba(0,0,0,0)';
            case 'auto'
                
                EdgeColor = scatter_child_data(n).EdgeColor;
                
                if isnumeric(EdgeColor)
                    col = 255*EdgeColor;
                    markerlinecolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
                else
                    
                    switch EdgeColor
                        
                        case 'none'
                            markerlinecolor = 'rgba(0,0,0,0)';
                        case {'flat', 'interp'}
                            
                            switch scatter_child_data(n).CDataMapping
                                case 'scaled'
                                    capCD = max(min(scatter_child_data(n).FaceVertexCData(1,1),axis_data.CLim(2)),axis_data.CLim(1));
                                    scalefactor = (capCD - axis_data.CLim(1))/diff(axis_data.CLim);
                                    col =  255*(colormap(1 + floor(scalefactor*(length(colormap)-1)),:));
                                case 'direct'
                                    col =  255*(colormap(scatter_child_data(n).FaceVertexCData(1,1),:));
                            end
                    end
                end
                
            case 'flat'
                
                switch scatter_child_data(n).CDataMapping
                    case 'scaled'
                        capCD = max(min(scatter_child_data(n).FaceVertexCData(1,1),axis_data.CLim(2)),axis_data.CLim(1));
                        scalefactor = (capCD - axis_data.CLim(1))/diff(axis_data.CLim);
                        col =  255*(colormap(1+floor(scalefactor*(length(colormap)-1)),:));
                    case 'direct'
                        col =  255*(colormap(scatter_child_data(n).FaceVertexCData(1,1),:));
                end
                
                markerlinecolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
        end
    end
    
    if filledMarker
        obj.data{scatterIndex}.marker.line.color{m} = markerlinecolor;
    else
        obj.data{scatterIndex}.marker.color{m} = markerlinecolor;
    end
    
    %-------------------------------------------------------------------------%
    
end

end

