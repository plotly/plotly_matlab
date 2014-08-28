function obj = extractPlotText(obj)


%-SCATTER XAXIS-%
obj.data{obj.getCurrentDataIndex}.xaxis = ['x' num2str(obj.getCurrentAxisIndex)];

%-SCATTER YAXIS-%
obj.data{obj.getCurrentDataIndex}.yaxis = ['y' num2str(obj.getCurrentAxisIndex)];

%-SCATTER TYPE-%
obj.data{obj.getCurrentDataIndex}.type = 'annotation';


end
