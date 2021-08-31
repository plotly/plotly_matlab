function obj = updateHeatmapAnnotation(obj,anIndex)

%-------X/YLABEL FIELDS--------%
% title...[DONE]
% titlefont.size...[DONE]
% titlefont.family...[DONE]
% titlefont.color...[DONE]

%------ANNOTATION FIELDS-------%

% x: ...[DONE]
% y: ...[DONE]
% xref: ...[DONE]
% yref: ...[DONE]
% text: ...[DONE]
% showarrow: ...[HANDLED BY CALL TO ANNOTATION];
% font: ...[DONE]
% xanchor: ...[DONE]
% yanchor: ...[DONE]
% align: ...[DONE]
% arrowhead: ...[HANDLED BY CALL FROM ANNOTATION];
% arrowsize: ...[HANDLED BY CALL FROM ANNOTATION];
% arrowwidth: ...[HANDLED BY CALL FROM ANNOTATION];
% arrowcolor: ...[HANDLED BY CALL FROM ANNOTATION];
% ax: ...[HANDLED BY CALL FROM ANNOTATION];
% ay: ...[HANDLED BY CALL FROM ANNOTATION];
% textangle: ...[DONE]
% bordercolor: ...[DONE]
% borderwidth: ...[DONE]
% borderpad: ...[DONE]
% bgcolor: ...[DONE]
% opacity: ...[NOT SUPPORTED IN MATLAB]


%-AXIS INDEX-%
nanns = length(obj.layout.annotations);
axIndex = nanns + obj.getAxisIndex(obj.State.Text(anIndex).AssociatedAxis);

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,anIndex);

%-get heatmap title name-%
title_name = obj.State.Text(anIndex).Handle;

%-show arrow-%
obj.layout.annotations{axIndex}.showarrow = false;

%-------------------------------------------------------------------------%

%-anchor title to paper-%
if obj.State.Text(anIndex).Title
    %-xref-%
    obj.layout.annotations{axIndex}.xref = 'paper';
    %-yref-%
    obj.layout.annotations{axIndex}.yref = 'paper';
else
    %-xref-%
    obj.layout.annotations{axIndex}.xref = ['x' num2str(xsource)];
    %-yref-%
    obj.layout.annotations{axIndex}.yref = ['y' num2str(ysource)];
end

%-------------------------------------------------------------------------%

%-xanchor-%
obj.layout.annotations{axIndex}.xanchor = 'middle';

%-align-%
obj.layout.annotations{axIndex}.align = 'middle';

%-xanchor-%
obj.layout.annotations{axIndex}.yanchor = 'top';


%-------------------------------------------------------------------------%

%-text-%
obj.layout.annotations{axIndex}.text = sprintf('<b>%s</b>', title_name);
obj.layout.annotations{axIndex}.font.size = 14;

%-------------------------------------------------------------------------%

if obj.State.Text(anIndex).Title
    
    %-AXIS DATA-%
    eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
    eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);
    
    %-x position-%
    obj.layout.annotations{axIndex}.x = mean(xaxis.domain);
    %-y position-%
    obj.layout.annotations{axIndex}.y = (yaxis.domain(2) + 0.04);
else
    %-x position-%
    obj.layout.annotations{axIndex}.x = text_data.Position(1);
    %-y position-%
    obj.layout.annotations{axIndex}.y = text_data.Position(2);
end

%-------------------------------------------------------------------------%
end