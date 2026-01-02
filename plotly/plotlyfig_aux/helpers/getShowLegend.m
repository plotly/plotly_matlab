function showLegend = getShowLegend(plotData)
	try
		switch plotData.Annotation.LegendInformation.IconDisplayStyle
			case "on"
				showLegend = true;
			case "off"
				showLegend = false;
		end
		showLegend = showLegend & ~isempty(plotData.DisplayName);
	catch
		showLegend = false;
	end
end
