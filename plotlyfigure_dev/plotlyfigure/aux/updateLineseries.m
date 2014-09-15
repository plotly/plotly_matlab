function updateLineseries(obj,plotIndex)

%----SCATTER FIELDS----%

% x - [DONE]
% y - [DONE]
% r - [HANDLED BY SCATTER]
% t - [HANDLED BY SCATTER]
% mode - [DONE]
% name - [NOT SUPPORTED IN MATLAB]
% text - [DONE]
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

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);

%-PLOT DATA STRUCTURE- %
plot_data = get(obj.State.Plot(plotIndex).Handle);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(axIndex) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(axIndex) ';']);

%-------------------------------------------------------------------------%

%-SCATTER XAXIS-%
obj.data{plotIndex}.xaxis = ['x' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-SCATTER YAXIS-%
obj.data{plotIndex}.yaxis = ['y' num2str(axIndex)];

%-------------------------------------------------------------------------%

%-SCATTER TYPE-%
obj.data{plotIndex}.type = 'scatter';

%-------------------------------------------------------------------------%

%-SCATTER VISIBLE-%
obj.data{plotIndex}.visible = strcmp(plot_data.Visible,'on');

%-------------------------------------------------------------------------%

%-SCATTER X-%
obj.data{plotIndex}.x = plot_data.XData;

%-------------------------------------------------------------------------%

%-SCATTER Y-%
obj.data{plotIndex}.y = plot_data.YData;

%-------------------------------------------------------------------------%

%-SCATTER NAME-%
obj.data{plotIndex}.name = plot_data.DisplayName;

%-----------------------------!STYLE!-------------------------------------%

if ~obj.PlotOptions.Strip
    
    %-SCATTER MODE (STYLE)-%
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
    
    %---------------------------------------------------------------------%
    
    %-LINE AND MARKER STYLE-%
    [line, marker] = extractLineMarker(plot_data);
    
    % line style
    obj.data{plotIndex}.line = line;
    
    % marker style
    obj.data{plotIndex}.marker = marker;
    
    %---------------------------------------------------------------------%
    
    %-SCATTER SHOWLEGEND (STYLE)-%
    leg = get(plot_data.Annotation);
    legInfo = get(leg.LegendInformation);
    
    switch legInfo.IconDisplayStyle
        case 'on'
            showleg = true;
        case 'off'
            showleg = false;
    end
    
    obj.data{plotIndex}.showlegend = showleg;
    
end

end

%-------------------------------------------------------------------------%


