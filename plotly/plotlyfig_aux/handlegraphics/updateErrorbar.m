function obj = updateErrorbar(obj, plotIndex)

	%-------------------------------------------------------------------------%

	%-INITIALIZATION-%

	%-get data structures-%
	plotData = get(obj.State.Plot(plotIndex).Handle);

	%-get error data-%
	yPositiveDelta = date2NumData(plotData.YPositiveDelta);
	yNegativeDelta = date2NumData(plotData.YNegativeDelta);

	xPositiveDelta = date2NumData(plotData.XPositiveDelta);
	xNegativeDelta = date2NumData(plotData.XNegativeDelta);

	%-------------------------------------------------------------------------%

	%-set trace-%

	updateLineseries(obj, plotIndex);

	%-errorbar visible-%
	obj.data{plotIndex}.error_y.visible = true;
	obj.data{plotIndex}.error_x.visible = true;

	%-errorbar type-%
	obj.data{plotIndex}.error_y.type = 'data';
	obj.data{plotIndex}.error_x.type = 'data';

	%-errorbar symmetry-%
	obj.data{plotIndex}.error_y.symmetric = false;


	%-------------------------------------------------------------------------%

	%-set errorbar data-%

	obj.data{plotIndex}.error_y.array = yPositiveDelta;
	obj.data{plotIndex}.error_x.array = xPositiveDelta;

	obj.data{plotIndex}.error_x.arrayminus = xNegativeDelta;
	obj.data{plotIndex}.error_y.arrayminus = yNegativeDelta;

	%-------------------------------------------------------------------------%

	%-errorbar thickness-%
	obj.data{plotIndex}.error_y.thickness = plotData.LineWidth;
	obj.data{plotIndex}.error_x.thickness = plotData.LineWidth;

	%-errorbar width-%
	obj.data{plotIndex}.error_y.width = obj.PlotlyDefaults.ErrorbarWidth;
	obj.data{plotIndex}.error_x.width = obj.PlotlyDefaults.ErrorbarWidth;

	%-errorbar color-%
	errorColor = getStringColor(255*plotData.Color);
	obj.data{plotIndex}.error_y.color = errorColor;
	obj.data{plotIndex}.error_x.color = errorColor;

	%-------------------------------------------------------------------------%

end
		