function showLegend = getShowLegend(plotData)
	try
		switch plotData.Annotation.LegendInformation.IconDisplayStyle
			case "on"
				showLegend = true;
			case "off"
				showLegend = false;
		end
	catch
		showLegend = false;
	end
end
