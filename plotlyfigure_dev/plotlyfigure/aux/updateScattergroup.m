function updateScattergroup(obj,scatterIndex)

%check: http://undocumentedmatlab.com/blog/undocumented-scatter-plot-behavior

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
% marker.opacity - [NOT SUPPORTED IN MATLAB]
% marker.colorscale - [NOT SUPPORTED IN MATLAB]
% marker.sizemode - [DONE]
% marker.sizeref - [DONE]
% marker.maxdisplayed - [NOT SUPPORTED IN MATLAB]

% MARKER LINE
% marker.line.color - [DONE]
% marker.line.width - [DONE]
% marker.line.dash - [NOT SUPPORTED IN MATLAB]
% marker.line.opacity - [DONE]
% marker.line.smoothing - [NOT SUPPORTED IN MATLAB]
% marker.line.shape - [NOT SUPPORTED IN MATLAB]

% LINE
% line.color - [NA]
% line.width - [NA]
% line.dash - [NA]
% line.opacity [NA]
% line.smoothing - [NOT SUPPORTED IN MATLAB]
% line.shape - [NOT SUPPORTED IN MATLAB]
% connectgaps - [NOT SUPPORTED IN MATLAB]
% fill - [HANDLED BY AREA]
% fillcolor - [HANDLED BY AREA]

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(scatterIndex).AssociatedAxis);

%-SCATTER DATA STRUCTURE- %
scatter_data = get(obj.State.Plot(scatterIndex).Handle);

%-SCATTER CHILDREN-%
scatter_child = get(obj.State.Plot(scatterIndex).Handle,'Children');

%-SCATTER CHILDREN DATA-%
scatter_child_data = get(scatter_child);

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,axIndex);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

%-------------------------------------------------------------------------%

%-SCATTER XAXIS-%
obj.data{scatterIndex}.xaxis = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

%-SCATTER YAXIS-%
obj.data{scatterIndex}.yaxis = ['y' num2str(ysource)];

%-------------------------------------------------------------------------%

%-SCATTER TYPE-%
obj.data{scatterIndex}.type = 'scatter';

%-------------------------------------------------------------------------%

%-SCATTER MODE-%
obj.data{scatterIndex}.mode = 'markers';

%-------------------------------------------------------------------------%

%-SCATTER VISIBLE-%
obj.data{scatterIndex}.visible = strcmp(scatter_data.Visible,'on');

%-------------------------------------------------------------------------%

%-SCATTER NAME-%
obj.data{scatterIndex}.name = scatter_child_data.DisplayName;

%-------------------------------------------------------------------------%

%-SCATTER PATCH DATA-%
for m = 1:length(scatter_child_data)
    
    %reverse counter
    n = length(scatter_child_data) - m + 1;
    
    %---------------------------------------------------------------------%
    
    %-SCATTER X-%
    if length(scatter_child_data) > 1
        obj.data{scatterIndex}.x(m) = scatter_child_data(n).XData;
    else
        obj.data{scatterIndex}.x = scatter_child_data.XData;
    end
    
    %---------------------------------------------------------------------%
    
    %-SCATTER Y-%
    if length(scatter_child_data) > 1
        obj.data{scatterIndex}.y(m) = scatter_child_data(n).YData;
    else
        obj.data{scatterIndex}.y = scatter_child_data.YData;
    end
    
    %-----------------------------!STRIP!---------------------------------%
    
    if ~obj.PlotOptions.Strip
        
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
        
        %-----------------------------------------------------------------%
        
        %-SCATTER OPACITY-%
        obj.data{scatterIndex}.opacity = obj.PlotlyDefaults.MarkerOpacity;
        
        %-----------------------------------------------------------------%
        
        %-SCATTER MARKER-%
        childmarker = extractPatchMarker(scatter_child_data(n));
        
        %-sizeref-%
        obj.data{scatterIndex}.marker.sizeref = childmarker.sizeref;
        
        %-sizemode-%
        obj.data{scatterIndex}.marker.sizemode = childmarker.sizemode;
        
        %-size-%
        obj.data{scatterIndex}.marker.size(m) = childmarker.size;
        
        %-symbol-%
        obj.data{scatterIndex}.marker.symbol = childmarker.symbol;
        
        %-line width-%
        obj.data{scatterIndex}.marker.line.width(m) = childmarker.line.width;
        
        %-line color-%
        if length(scatter_child_data) > 1
            obj.data{scatterIndex}.marker.line.color{m} = childmarker.line.color{1};
        else
            obj.data{scatterIndex}.marker.line.color = childmarker.line.color;
        end
        
        %-marker color-%
        if length(scatter_child_data) > 1
            obj.data{scatterIndex}.marker.color{m} = childmarker.color{1};
        else
            obj.data{scatterIndex}.marker.color = childmarker.color;
        end
        
        %-----------------------------------------------------------------%
        
    end
end
end

