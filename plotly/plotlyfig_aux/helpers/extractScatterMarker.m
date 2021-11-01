function marker = extractScatterMarker(plotData)

    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    %                                                                         %
    % %-DESCRIPTION-%                                                         %
    %                                                                         %
    % EXTRACTS THE MARKER STYLE USED FOR MATLAB OBJECTS OF TYPE "PATCH".      %
    % THESE OBJECTS ARE USED IN AREASERIES BARSERIES, CONTOURGROUP,           %
    % SCATTERGROUP.                                                           %
    %                                                                         %
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%

    %-INITIALIZATIONS-%
    axisData = get(ancestor(plotData.Parent,'axes'));
    figureData = get(ancestor(plotData.Parent,'figure'));

    marker = struct();
    marker.sizeref = 1;
    marker.sizemode = 'area';
    marker.size = getMarkerSize(plotData);
    marker.line.width = 1.5*plotData.LineWidth;

    filledMarkerSet = {'o', 'square', 's', 'diamond', 'd', 'v', '^', ...
        '<', '>', 'hexagram', 'pentagram'};
    filledMarker = ismember(plotData.Marker, filledMarkerSet);

    %-------------------------------------------------------------------------%

    %-get marker symbol-%
    if ~strcmp(plotData.Marker,'none')

        switch plotData.Marker
            case '.'
                markerSymbol = 'circle';
                marker.size = 0.1*marker.size;
            case 'o'
                markerSymbol = 'circle';
            case 'x'
                markerSymbol = 'x-thin-open';
            case '+'
                markerSymbol = 'cross-thin-open';
            case '*'
                markerSymbol = 'asterisk-open';
            case {'s','square'}
                markerSymbol = 'square';
            case {'d','diamond'}
                markerSymbol = 'diamond';
            case 'v'
                markerSymbol = 'triangle-down';
            case '^'
                markerSymbol = 'triangle-up';
            case '<'
                markerSymbol = 'triangle-left';
            case '>'
                markerSymbol = 'triangle-right';
            case {'p','pentagram'}
                markerSymbol = 'star';
            case {'h','hexagram'}
                markerSymbol = 'hexagram';
        end
        
        marker.symbol = markerSymbol;
    end

    %-------------------------------------------------------------------------%

    %-marker fill-%
    markerFaceColor = plotData.MarkerFaceColor;
    markerFaceAlpha = plotData.MarkerFaceAlpha;

    if filledMarker
        
        %-get face color-%
        if isnumeric(markerFaceColor)
            faceColor = sprintf('rgb(%f,%f,%f)', 255*markerFaceColor);

        else
            switch markerFaceColor
                
                case 'none'        
                    faceColor = 'rgba(0,0,0,0)';
                    
                case 'auto'
                    if ~strcmp(axisData.Color,'none')
                        faceColor = 255*axisData.Color;
                    else
                        faceColor = 255*figureData.Color;
                    end

                    faceColor = getStringColor(faceColor);
                    
                case 'flat'
                    faceColor = getScatterFlatColor(plotData, axisData);

            end
        end

        %-get face alpha-%
        if isnumeric(markerFaceAlpha)
            faceAlpha = markerFaceAlpha;
        else
            switch markerFaceColor
                
                case 'none'        
                    faceAlpha = 1;
                    
                case 'flat'
                    aLim = axisData.ALim;
                    faceAlpha = plotData.AlphaData;
                    faceAlpha = rescaleData(faceAlpha, aLim);
            end
        end
        
        %-set marker fill-%
        marker.color = faceColor;
        marker.opacity = faceAlpha;
        
    end

    %-------------------------------------------------------------------------%

    %-marker line-%
    markerEdgeColor = plotData.MarkerEdgeColor;
    markerEdgeAlpha = plotData.MarkerEdgeAlpha;

    if isnumeric(markerEdgeColor)
        lineColor = sprintf('rgb(%f,%f,%f)', 255*markerEdgeColor);

    else
        switch markerEdgeColor

            case 'none'
                lineColor = 'rgba(0,0,0,0)';
                
            case 'auto'

                if ~strcmp(axisData.Color,'none')
                    lineColor = 255*axisData.Color;
                else
                    lineColor = 255*figureData.Color;
                end

                lineColor = getStringColor(lineColor, markerEdgeAlpha);
                
            case 'flat'

                lineColor = getScatterFlatColor(plotData, axisData);

        end
    end

    if filledMarker
        marker.line.color = lineColor;
    else
        marker.color = lineColor;
        if strcmp(plotData.Marker, '.'), marker.line.color = lineColor; end
    end

    %-------------------------------------------------------------------------%
end

function flatColor = getScatterFlatColor(plotData, axisData, opacity)

    %-------------------------------------------------------------------------%

    cData = plotData.CData;
    colorMap = axisData.Colormap;
    cLim = axisData.CLim;
    nColors = size(colorMap, 1);
    cDataByIndex = false;

    if isvector(cData)
        lenCData = length(cData);
        nMarkers = length(plotData.XData);
        cDataByIndex = lenCData == nMarkers || lenCData == 1;
    end

    %-------------------------------------------------------------------------%

    if cDataByIndex
        cMapInd = getcMapInd(cData, cLim, nColors);
        numColor = 255 * colorMap(cMapInd, :);
    else
        numColor = 255*cData;
    end

    if size(numColor, 1) == 1
        flatColor = getStringColor(numColor);

    else
        for n = 1:size(numColor, 1)
            flatColor{n} = getStringColor(numColor(n, :));
        end
    end

    %-------------------------------------------------------------------------%
end

function cMapInd = getcMapInd(cData, cLim, nColors)
    scaledCData = rescaleData(cData, cLim);
    cMapInd = 1 + floor(scaledCData*(nColors-1));
end

function outData = rescaleData(inData, dataLim)
    outData = max( min( inData, dataLim(2) ), dataLim(1) );
    outData = (outData - dataLim(1)) / diff(dataLim);
end

function markerSize = getMarkerSize(plotData)
    markerSize = plotData.SizeData;

    if length(markerSize) == 1
        markerSize = markerSize * ones(size(plotData.XData));
    end
end