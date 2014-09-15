% x: ...[DONE]
% y: ...[DONE]
% traceorder: ...[DONE]
% font: ..........................[TODO]
% bgcolor: ...[DONE]
% bordercolor: ...[DONE]
% borderwidth: ...[DONE]
% xref: ...[DONE]
% yref: ...[DONE]
% xanchor: ...[DONE]
% yanchor: ...[DONE]

function obj = updateLegend(obj, legIndex)

%-STANDARDIZE UNITS-%
legendunits = get(obj.State.Legend(legIndex).Handle,'Units'); 
fontunits = get(obj.State.Legend(legIndex).Handle,'FontUnits'); 
set(obj.State.Legend(legIndex).Handle,'Units','normalized');
set(obj.State.Legend(legIndex).Handle,'FontUnits','points');

%-FIGURE DATA-%
figure_data = get(obj.State.Figure.Handle);

%-AXIS DATA-%
axis_data = get(obj.State.Legend(legIndex).AssociatedAxis); 

%-LEGEND DATA STRUCTURE-%
legend_data = get(obj.State.Legend(legIndex).Handle);

% only displays last legend as global Plotly legend
obj.layout.legend = struct(); 

%-------------------------------------------------------------------------%

obj.layout.traceorder = 'normal'; 

%-------------------------------------------------------------------------%

obj.layout.showlegend = strcmpi(get(obj.State.Legend(legIndex).Handle,'ContentsVisible'),'on'); 

%-------------------------------------------------------------------------%

obj.layout.legend.x = legend_data.Position(1);  

%-------------------------------------------------------------------------%

obj.layout.legend.xref = 'paper'; 

%-------------------------------------------------------------------------%

obj.layout.legend.xanchor = 'left'; 

%-------------------------------------------------------------------------%

obj.layout.legend.y = legend_data.Position(2); 

%-------------------------------------------------------------------------%

obj.layout.legend.yref = 'paper'; 

%-------------------------------------------------------------------------%

obj.layout.legend.yanchor = 'bottom';

%-------------------------------------------------------------------------%

if (strcmp(legend_data.Box,'on') && strcmp(legend_data.Visible, 'on'))
    %-legend borderwidth-%
    obj.layout.legend.borderwidth = legend_data.LineWidth;
    
    %-legend bordercolor-%
    col = 255*legend_data.EdgeColor; 
    obj.layout.legend.bordercolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')']; 
    
    %-legend bgcolor-%
    col = 255*legend_data.Color;
    obj.layout.legend.bgcolor = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
end

%-REVERT UNITS-%
set(obj.State.Legend(legIndex).Handle,'Units',legendunits);
set(obj.State.Legend(legIndex).Handle,'FontUnits',fontunits);

end