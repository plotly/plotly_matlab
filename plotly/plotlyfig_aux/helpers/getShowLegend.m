function showLegend = getShowLegend(plotData)
	try
		switch get(get(get(plotData, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle')
			case "on"
				showLegend = true;
			case "off"
				showLegend = false;
		end
	catch
		showLegend = false;
	end
end
