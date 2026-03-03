function colorScale = getColorScale(colorMap)
    nColors = size(colorMap, 1);
    normInd = rescale(1:nColors, 0, 1);
    colorScale = cell(nColors, 1);

    for n = 1:nColors
        colorScale{n} = {normInd(n), ...
            getStringColor(round(255*colorMap(n, :)))};
    end
end
