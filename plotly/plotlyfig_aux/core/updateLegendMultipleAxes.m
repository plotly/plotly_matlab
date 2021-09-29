function obj = updateLegendMultipleAxes(obj, legIndex)

% x: ...[DONE]
% y: ...[DONE]
% traceorder: ...[DONE]
% font: ...[DONE]
% bgcolor: ...[DONE]
% bordercolor: ...[DONE]
% borderwidth: ...[DONE]
% xref: ...[DONE]
% yref: ...[DONE]
% xanchor: ...[DONE]
% yanchor: ...[DONE]

%=========================================================================%
%
%-GET NECESSARY INFO FOR MULTIPLE LEGENDS-%
%
%=========================================================================%

for traceIndex = 1:obj.State.Figure.NumPlots
    allNames{traceIndex} = obj.data{traceIndex}.name;
    allShowLegens(traceIndex) = obj.data{traceIndex}.showlegend;
    obj.data{traceIndex}.showlegend = false;
    obj.data{traceIndex}.legendgroup = obj.data{traceIndex}.name;

    axIndex = obj.getAxisIndex(obj.State.Plot(traceIndex).AssociatedAxis);
    [xSource, ySource] = findSourceAxis(obj, axIndex);
    xAxis = eval(sprintf('obj.layout.xaxis%d', xSource));
    yAxis = eval(sprintf('obj.layout.yaxis%d', xSource));

    allDomain(traceIndex, 1) = max(xAxis.domain);
    allDomain(traceIndex, 2) = max(yAxis.domain);
end

[~, groupIndex] = unique(allNames);

for traceIndex = groupIndex'
   obj.data{traceIndex}.showlegend = allShowLegens(traceIndex); 
end

%-------------------------------------------------------------------------%

%-STANDARDIZE UNITS-%
legendUnits = get(obj.State.Legend(legIndex).Handle,'Units');
fontUnits = get(obj.State.Legend(legIndex).Handle,'FontUnits');
set(obj.State.Legend(legIndex).Handle,'Units','normalized');
set(obj.State.Legend(legIndex).Handle,'FontUnits','points');

%-------------------------------------------------------------------------%

%-LEGEND DATA STRUCTURE-%
legendData = get(obj.State.Legend(legIndex).Handle);

% only displays last legend as global Plotly legend
obj.layout.legend = struct();

%-------------------------------------------------------------------------%

%-layout showlegend-%
obj.layout.showlegend = strcmpi(legendData.Visible,'on');

%-------------------------------------------------------------------------%

%-legend (x,y) coordenates-%
obj.layout.legend.x = 1.005 * max(allDomain(:,1));
obj.layout.legend.y = 1.001 * max(allDomain(:,2));;

%-legend (x,y) refs-%
obj.layout.legend.xref = 'paper';
obj.layout.legend.yref = 'paper';

%-legend (x,y) anchors-%
obj.layout.legend.xanchor = 'left';
obj.layout.legend.yanchor = 'top';

%-------------------------------------------------------------------------%

if (strcmp(legendData.Box,'on') && strcmp(legendData.Visible, 'on'))
    
    %---------------------------------------------------------------------%
    
    %-legend traceorder-%
    obj.layout.legend.traceorder = 'normal';
    
    %---------------------------------------------------------------------%
    
    %-legend borderwidth-%
    obj.layout.legend.borderwidth = legendData.LineWidth;
    
    %---------------------------------------------------------------------%
    
    %-legend bordercolor-%
    col = 255*legendData.EdgeColor;
    obj.layout.legend.bordercolor = sprintf('rgb(%f,%f,%f)', col);
    
    %---------------------------------------------------------------------%
    
    %-legend bgcolor-%
    col = 255*legendData.Color;
    obj.layout.legend.bgcolor = sprintf('rgb(%f,%f,%f)', col);
    
    %---------------------------------------------------------------------%
    
    %-legend font size-%
    obj.layout.legend.font.size = legendData.FontSize;
    
    %---------------------------------------------------------------------%
    
    %-legend font family-%
    obj.layout.legend.font.family = matlab2plotlyfont(legendData.FontName);
    
    %---------------------------------------------------------------------%
    
    %-legend font colour-%
    col = 255*legendData.TextColor;
    obj.layout.legend.font.color = sprintf('rgb(%f,%f,%f)', col);
    
end

%-------------------------------------------------------------------------%

%-REVERT UNITS-%
set(obj.State.Legend(legIndex).Handle,'Units',legendUnits);
set(obj.State.Legend(legIndex).Handle,'FontUnits',fontUnits);

end