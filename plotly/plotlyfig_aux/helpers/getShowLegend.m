function showLegend = getShowLegend(plotData)
	try
		leg = plotData.Annotation;
		legInfo = leg.LegendInformation;

		switch legInfo.IconDisplayStyle
			case 'on'
				showLegend = true;
			case 'off'
				showLegend = false;
		end
		showLegend = showLegend & ~isempty(plotData.DisplayName);
	catch
		showLegend = false;
	end
end
