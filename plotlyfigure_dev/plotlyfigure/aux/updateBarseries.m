function obj = updateBarseries(obj,dataIndex)

% x: ...[DONE]
% y: ...[DONE]
% name: ...[DONE]
% orientation: ...[DONE]
% text: ...[NOT SUPPORTED IN MATLAB]
% error_y: ...[HANDLED BY ERRORBAR]
% error_x: ...[HANDLED BY ERRORBAR]
% opacity: ------------------------------------------> [TODO]
% xaxis: ...[DONE]
% yaxis: ...[DONE]
% showlegend: ...[DONE]
% stream: ...[HANDLED BY PLOTLY STREAM]
% visible: ...[DONE]
% type: ...[DONE]
% r: ...[NA]
% t: ...[NA]
% textfont: ...[NA]

% MARKER:
% color: ...DONE]
% size: ...[NA]
% symbol: ...[NA]
% opacity: ...[NA]
% sizeref: ...[NA]
% sizemode: ...[NA]
% colorscale: ...[NA]
% cauto: ...[NA]
% cmin: ...[NA]
% cmax: ...[NA]
% outliercolor: ...[NA]
% maxdisplayed: ...[NA]

% MARKER LINE:
% color: ...[DONE]
% width: ...[DONE]
% dash: ...[NA]
% opacity: ------------------------------------------> [TODO]
% shape: ...[NA]
% smoothing: ...[NA]
% outliercolor: ...[NA]
% outlierwidth: ...[NA]

% LINE:
% color: ........[N/A]
% width: ...[NA]
% dash: ...[NA]
% opacity: ...[NA]
% shape: ...[NA]
% smoothing: ...[NA]
% outliercolor: ...[NA]
% outlierwidth: ...[NA]


%-------------------------------------------------------------------------%

%-AXIS INDEX-%
axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);

%-BAR DATA STRUCTURE- %
bar_data = get(obj.State.Plot(dataIndex).Handle);

%-BAR CHILD (PATCH) DATA STRUCTURE- %
bar_child_data = get(bar_data.Children(1));

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj,axIndex);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

%-------------------------------------------------------------------------%

%-BAR XAXIS-%
obj.data{dataIndex}.xaxis = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

%-BAR YAXIS-%
obj.data{dataIndex}.yaxis = ['y' num2str(ysource)];

%-------------------------------------------------------------------------%

%-BAR VISIBLE-%
obj.data{dataIndex}.visible = strcmp(bar_data.Visible,'on');

%-------------------------------------------------------------------------%

%-BAR TYPE-%
obj.data{dataIndex}.type = 'bar';

%-------------------------------------------------------------------------%

%-BAR NAME-%
obj.data{dataIndex}.name = bar_data.DisplayName;

%-------------------------------------------------------------------------%

%-LAYOUT BARMODE-%
switch bar_data.BarLayout
    case 'grouped'
        obj.layout.barmode = 'group';
    case 'stacked'
        obj.layout.barmode = 'stack';
end

%-------------------------------------------------------------------------%

%-BAR ORIENTATION-%
switch bar_data.Horizontal
    
    case 'off'
        
        obj.data{dataIndex}.orientation = 'v';
        
        %-bar x data-%
        obj.data{dataIndex}.x = bar_data.XData;
        
        %-bar y data-%
        obj.data{dataIndex}.y = bar_data.YData;
        
        
    case 'on'
        
        obj.data{dataIndex}.orientation = 'h';
        
        %-bar x data-%
        obj.data{dataIndex}.x = bar_data.YData;
        
        %-bar y data-%
        obj.data{dataIndex}.y = bar_data.XData;
end

%-----------------------------!STYLE!-------------------------------------%

if ~obj.PlotOptions.Strip
    
    %-LAYOUT BARGAP-%
    obj.layout.bargap = 1-bar_data.BarWidth;
    
    %---------------------------------------------------------------------%
    
    %-BAR SHOWLEGEND-%
    leg = get(bar_data.Annotation);
    legInfo = get(leg.LegendInformation);
    
    switch legInfo.IconDisplayStyle
        case 'on'
            showleg = true;
        case 'off'
            showleg = false;
    end
    
    obj.data{dataIndex}.showlegend = showleg;
    
    %---------------------------------------------------------------------%
    
    %-BAR OPACITY-%
    if ~ischar(bar_child_data.FaceAlpha)
        obj.data{dataIndex}.opacity = bar_child_data.FaceAlpha;
    end
    
    %---------------------------------------------------------------------%
    
    %-BAR MARKER-%
    obj.data{dataIndex}.marker = extractPatchFace(bar_child_data);
    
    %---------------------------------------------------------------------%
    
end
end


