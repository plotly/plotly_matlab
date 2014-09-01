function obj = extractBarseries(obj,event,prop)

% x: ................[TODO]
% y: ................[TODO]
% name: ................[TODO]
% orientation: ................[TODO]
% text: ................[TODO]
% error_y: ................[TODO]
% error_x: ................[TODO]
% marker: ................[TODO]
% opacity: ................[TODO]
% xaxis: ................[TODO]
% yaxis: ................[TODO]
% showlegend: ................[TODO]
% stream: ...[HANDLED BY PLOTLY STREAM]
% visible: ................[TODO]
% type: ................[TODO]
% r: ................[TODO]
% t: ................[TODO]
% line: ................[TODO]
% textfont: ................[TODO]

%-FIGURE STRUCTURE-%
figure_data = get(obj.State.Figure.Handle);

%-AXIS STRUCTURE-%
axis_data = get(obj.State.Axis.Handle);

%-AXIS DATA-%
eval(['xaxis = obj.layout.xaxis' num2str(obj.getCurrentAxisIndex) ';']);
eval(['yaxis = obj.layout.yaxis' num2str(obj.getCurrentAxisIndex) ';']);

%-PLOT DATA STRUCTURE- %
bar_data = event.AffectedObject;

%-BAR XAXIS-%
obj.data{obj.getCurrentDataIndex}.xaxis = ['x' num2str(obj.getCurrentAxisIndex)];

%-BAR YAXIS-%
obj.data{obj.getCurrentDataIndex}.yaxis = ['y' num2str(obj.getCurrentAxisIndex)];

%-BAR TYPE-%
obj.data{obj.getCurrentDataIndex}.type = 'bar';

switch prop
    
    case 'BarLayout'
        
    case 'BarWidth'
        
    case 'BaseLine'
        
    case 'BaseValue'
        
    case 'Children'
        
    case 'DisplayName'
        
    case 'EdgeColor'
        
    case 'FaceColor'    
        
    case 'LineStyle'
        
    case 'LineWidth'
        
    case 'ShowBaseLine'
        
    case 'Visible'
        
    case 'XData'
    
    %-bar x data-%
    obj.data{obj.getCurrentDataIndex}.x = bar_data.XData;
        
    case 'XDataMode'
              
    case 'YData'
    
    %-bar y data-%
    obj.data{obj.getCurrentDataIndex}.y = bar_data.YData; 
           
end