function obj = updateAlternativeBoxplot(obj, dataIndex)
    %-INITIALIZATIONS-%

	axIndex = obj.getAxisIndex(obj.State.Plot(dataIndex).AssociatedAxis);
	plotStructure = obj.State.Plot(dataIndex).Handle;
	plotData = plotStructure.Children;

	nTraces = length(plotData);
	traceIndex = dataIndex;

	%-update traces-%
	for t = 1:nTraces
		if t ~= 1
			obj.PlotOptions.nPlots = obj.PlotOptions.nPlots + 1;
			traceIndex = obj.PlotOptions.nPlots;
		end
		updateBoxplotLine(obj, axIndex, plotData(t), traceIndex);
	end
end

function updateBoxplotLine(obj, axIndex, plotData, traceIndex)
    %-INITIALIZATIONS-%

	%-get axis info-%
	[xSource, ySource] = findSourceAxis(obj, axIndex);

	%-get trade data-%
	xData = plotData.XData;
	yData = plotData.YData;

    if isduration(xData) || isdatetime(xData)
        xData = datenum(xData);
    end
    if isduration(yData) || isdatetime(yData)
        yData = datenum(yData);
    end

    if length(xData) < 2
        xData = ones(1,2)*xData;
    end
    if length(yData) < 2
        yData = ones(1,2)*yData;
    end

    %-set trace-%
    obj.data{traceIndex}.type = 'scatter';
    obj.data{traceIndex}.mode = getScatterMode(plotData);
    obj.data{traceIndex}.visible = strcmp(plotData.Visible,'on');
    obj.data{traceIndex}.name = plotData.DisplayName;
    obj.data{traceIndex}.xaxis = sprintf('x%d', xSource);
    obj.data{traceIndex}.yaxis = sprintf('y%d', ySource);

    %-set trace data-%
    obj.data{traceIndex}.x = xData;
    obj.data{traceIndex}.y = yData;

    obj.data{traceIndex}.marker = extractLineMarker(plotData);
    obj.data{traceIndex}.line = extractLineLine(plotData);

    switch plotData.Annotation.LegendInformation.IconDisplayStyle
        case "on"
            obj.data{traceIndex}.showlegend = true;
        case "off"
            obj.data{traceIndex}.showlegend = false;
    end

    if isempty(obj.data{traceIndex}.name)
        obj.data{traceIndex}.showlegend = false;
    end
end
