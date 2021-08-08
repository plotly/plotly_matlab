function obj = updateBar(obj,barIndex)

% x: ...[DONE]
% y: ...[DONE]
% name: ...[DONE]
% orientation: ...[DONE]
% text: ...[NOT SUPPORTED IN MATLAB]
% error_y: ...[HANDLED BY ERRORBAR]
% error_x: ...[HANDLED BY ERRORBAR]
% opacity: ...[DONE]
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
% opacity: ---[TODO]
% shape: ...[NA]
% smoothing: ...[NA]
% outliercolor: ...[NA]
% outlierwidth: ...[NA]

%-------------------------------------------------------------------------%

%-AXIS INDEX-%
axis_data = obj.State.Plot(barIndex).AssociatedAxis;
axIndex = obj.getAxisIndex(axis_data);

%-BAR DATA STRUCTURE- %
bar_data = obj.State.Plot(barIndex).Handle;

%-CHECK FOR MULTIPLE AXES-%
[xsource, ysource] = findSourceAxis(obj, axIndex);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(xsource) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(ysource) ';']);

%-------------------------------------------------------------------------%

%-bar xaxis-%
obj.data{barIndex}.xaxis = ['x' num2str(xsource)];

%-------------------------------------------------------------------------%

%-bar yaxis-%
obj.data{barIndex}.yaxis = ['y' num2str(ysource)];

%-------------------------------------------------------------------------%

%-bar visible-%
obj.data{barIndex}.visible = strcmp(bar_data.Visible,'on');

%-------------------------------------------------------------------------%

%-bar type-%
obj.data{barIndex}.type = 'bar';

%-------------------------------------------------------------------------%

%-bar name-%
obj.data{barIndex}.name = bar_data.DisplayName;

%-------------------------------------------------------------------------%

%-layout barmode-%
switch bar_data.BarLayout
    case 'grouped'
        obj.layout.barmode = 'group';
    case 'stacked'
        obj.layout.barmode = 'relative';
end

%-------------------------------------------------------------------------%

%-layout bargroupgap-%
obj.layout.bargroupgap = 1-bar_data.BarWidth;

%---------------------------------------------------------------------%

%-layout bargap-%
if strcmp(obj.layout.barmode,'group')
    obj.layout.bargap = 0.3;
else
    obj.layout.bargap = obj.PlotlyDefaults.Bargap;
end

%-------------------------------------------------------------------------%

%-bar orientation-%
switch bar_data.Horizontal
    
    case 'off'
        
        %-bar orientation-%
        obj.data{barIndex}.orientation = 'v';
        
        %-bar x data-%
        obj.data{barIndex}.x = bar_data.XData;
        
        %-bar y data-%
        obj.data{barIndex}.y = bar_data.YData - bar_data.BaseValue;
        
        eval(['obj.layout.yaxis',num2str(axIndex),'.range = [',num2str(minmax(axis_data.YTick-bar_data.BaseValue)),'];']);
        eval(['obj.layout.yaxis',num2str(axIndex),'.tickvals = [',sprintf('%d,',axis_data.YTick-bar_data.BaseValue),'];']);
        eval(['obj.layout.yaxis',num2str(axIndex),'.ticktext = [',num2str(axis_data.YTick),'];']);
        eval(['obj.layout.yaxis',num2str(axIndex),'.tickmode = ''array'';']);
        if bar_data.BaseValue ~= 0
            eval(['obj.layout.yaxis',num2str(axIndex),'.zeroline = 1;']);
        end
        
    case 'on'
        
        %-bar orientation-%
        obj.data{barIndex}.orientation = 'h';
        
        %-bar x data-%
        obj.data{barIndex}.x = bar_data.YData - bar_data.BaseValue;
        
        %-bar y data-%
        obj.data{barIndex}.y = bar_data.XData;
        
        eval(['obj.layout.xaxis',num2str(axIndex),'.range = [',num2str(minmax(axis_data.XTick-bar_data.BaseValue)),'];']);
        eval(['obj.layout.xaxis',num2str(axIndex),'.tickvals = [',sprintf('%d,',axis_data.XTick-bar_data.BaseValue),'];']);
        eval(['obj.layout.xaxis',num2str(axIndex),'.ticktext = [',num2str(axis_data.XTick),'];']);
        eval(['obj.layout.xaxis',num2str(axIndex),'.tickmode = ''array'';']);
        if bar_data.BaseValue ~= 0
            eval(['obj.layout.xaxis',num2str(axIndex),'.zeroline = 1;']);
        end
end


%---------------------------------------------------------------------%

%-bar showlegend-%
leg = get(bar_data.Annotation);
legInfo = get(leg.LegendInformation);

switch legInfo.IconDisplayStyle
    case 'on'
        showleg = true;
    case 'off'
        showleg = false;
end

obj.data{barIndex}.showlegend = showleg;

%-------------------------------------------------------------------------%

%-bar marker-%
obj.data{barIndex}.marker = extractAreaFace(bar_data);

%-------------------------------------------------------------------------%

%-bar marker line-%
markerline = extractAreaLine(bar_data); 
obj.data{barIndex}.marker.line = markerline; 

%-------------------------------------------------------------------------%
end


