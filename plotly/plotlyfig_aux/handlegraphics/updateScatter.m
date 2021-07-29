function updateScatter(obj,scatterIndex)

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
% opacity ---[TODO]

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

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,axIndex);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

%-------------------------------------------------------------------------%

%-scatter xaxis-%
obj.data{scatterIndex}.xaxis = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

%-scatter yaxis-%
obj.data{scatterIndex}.yaxis = ['y' num2str(ysource)];

%-------------------------------------------------------------------------%

%-scatter type-%
obj.data{scatterIndex}.type = 'scatter';

%-------------------------------------------------------------------------%

%-scatter mode-%
obj.data{scatterIndex}.mode = 'markers';

%-------------------------------------------------------------------------%

%-scatter visible-%
obj.data{scatterIndex}.visible = strcmp(scatter_data.Visible,'on');

%-------------------------------------------------------------------------%

%-scatter name-%
obj.data{scatterIndex}.name = scatter_data.DisplayName;

%-------------------------------------------------------------------------%


%---------------------------------------------------------------------%

%-scatter x-%
obj.data{scatterIndex}.x = scatter_data.XData;

%---------------------------------------------------------------------%

%-scatter y-%
obj.data{scatterIndex}.y = scatter_data.YData;

%---------------------------------------------------------------------%

%-scatter z-%
if isHG2()
    if isfield(scatter_data,'ZData')
        obj.data{scatterIndex}.type = 'scatter3d';
        obj.data{scatterIndex}.z = scatter_data.ZData;
    end
end

%---------------------------------------------------------------------%

%-scatter showlegend-%
leg = get(scatter_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{scatterIndex}.showlegend = showleg;

%---------------------------------------------------------------------%

%-scatter marker-%
childmarker = extractScatterMarker(scatter_data);

%---------------------------------------------------------------------%

%-line color-%
obj.data{scatterIndex}.marker.line.color = childmarker.line.color;

%---------------------------------------------------------------------%

%-marker color-%
obj.data{scatterIndex}.marker.color = childmarker.color;

%---------------------------------------------------------------------%

%-sizeref-%
obj.data{scatterIndex}.marker.sizeref = childmarker.sizeref;

%---------------------------------------------------------------------%

%-sizemode-%
obj.data{scatterIndex}.marker.sizemode = childmarker.sizemode;

%---------------------------------------------------------------------%

%-symbol-%
obj.data{scatterIndex}.marker.symbol = childmarker.symbol;

%---------------------------------------------------------------------%

%-size-%
obj.data{scatterIndex}.marker.size = childmarker.size*0.1;

%---------------------------------------------------------------------%

%-line width-%
obj.data{scatterIndex}.marker.line.width = childmarker.line.width;

%---------------------------------------------------------------------%
    
end

