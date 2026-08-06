function showLegend = getShowLegend(plotData)
	showLegend = false;
	try
		switch get(get(get(plotData, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle')
			case "on"
				showLegend = true;
			case "off"
				showLegend = false;
		end
	catch
		% Octave objects have no Annotation property; fall back to a
		% non-empty DisplayName (set by legend) as the legend marker.
		if isprop(plotData, 'DisplayName')
			showLegend = ~isempty(get(plotData, 'DisplayName'));
		end
	end
end
