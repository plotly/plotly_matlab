function scatterMode = getScatterMode(plotData)
	marker = get(plotData, 'Marker');
	lineStyle = get(plotData, 'LineStyle');

	if ~strcmpi('none', marker) && ~strcmpi('none', lineStyle)
        scatterMode = 'lines+markers';
    elseif ~strcmpi('none', marker)
        scatterMode = 'markers';
    elseif ~strcmpi('none', lineStyle)
        scatterMode = 'lines';
    else
        scatterMode = 'none';
    end
end
