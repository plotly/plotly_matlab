function obj = updateErrorbar(obj, plotIndex)
	%-INITIALIZATION-%

	%-get data structures-%
	plotData = obj.State.Plot(plotIndex).Handle;

	%-get error data-%
	yPositiveDelta = plotData.YPositiveDelta;
	yNegativeDelta = plotData.YNegativeDelta;

	xPositiveDelta = plotData.XPositiveDelta;
	xNegativeDelta = plotData.XNegativeDelta;

	%-set trace-%
	updateLineseries(obj, plotIndex);

	obj.data{plotIndex}.error_y.visible = true;
	obj.data{plotIndex}.error_x.visible = true;
	obj.data{plotIndex}.error_y.type = 'data';
	obj.data{plotIndex}.error_x.type = 'data';

	obj.data{plotIndex}.error_y.symmetric = false;

	obj.data{plotIndex}.error_y.array = yPositiveDelta;
	obj.data{plotIndex}.error_x.array = xPositiveDelta;
	obj.data{plotIndex}.error_x.arrayminus = xNegativeDelta;
	obj.data{plotIndex}.error_y.arrayminus = yNegativeDelta;

	obj.data{plotIndex}.error_y.thickness = plotData.LineWidth;
	obj.data{plotIndex}.error_x.thickness = plotData.LineWidth;

	obj.data{plotIndex}.error_y.width = obj.PlotlyDefaults.ErrorbarWidth;
	obj.data{plotIndex}.error_x.width = obj.PlotlyDefaults.ErrorbarWidth;

	%-errorbar color-%
	errorColor = getStringColor(round(255*plotData.Color));
	obj.data{plotIndex}.error_y.color = errorColor;
	obj.data{plotIndex}.error_x.color = errorColor;
end
