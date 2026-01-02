function marker = extractScatterMarker(plotData)
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    %                                                                     %
    % %-DESCRIPTION-%                                                     %
    %                                                                     %
    % EXTRACTS THE MARKER STYLE USED FOR MATLAB OBJECTS OF TYPE "PATCH".  %
    % THESE OBJECTS ARE USED IN AREASERIES BARSERIES, CONTOURGROUP,       %
    % SCATTERGROUP.                                                       %
    %                                                                     %
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    axisData = ancestor(plotData.Parent, ["Axes" "PolarAxes"]);
    figureData = ancestor(plotData.Parent, "figure");

    marker = struct();
    marker.sizeref = 1;
    marker.sizemode = "area";
    marker.size = getMarkerSize(plotData);
    marker.line.width = 1.5*plotData.LineWidth;

    filledMarkerSet = {'o', 'square', 's', 'diamond', 'd', 'v', '^', ...
            '<', '>', 'hexagram', 'pentagram'};
    filledMarker = ismember(plotData.Marker, filledMarkerSet);

    if plotData.Marker ~= "none"
        if plotData.Marker == "."
            marker.size = 0.1*marker.size;
        end
        marker.symbol = getMarkerSymbol(plotData.Marker);
    end

    markerFaceColor = plotData.MarkerFaceColor;
    markerFaceAlpha = plotData.MarkerFaceAlpha;

    if filledMarker
        if isnumeric(markerFaceColor)
            faceColor = getStringColor(round(255*markerFaceColor));
        else
            switch markerFaceColor
                case "none"
                    faceColor = "rgba(0,0,0,0)";
                case "auto"
                    if axisData.Color ~= "none"
                        faceColor = axisData.Color;
                    else
                        faceColor = figureData.Color;
                    end
                    faceColor = getStringColor(round(255*faceColor));
                case "flat"
                    faceColor = getScatterFlatColor(plotData, axisData);
            end
        end

        if isnumeric(markerFaceAlpha)
            faceAlpha = markerFaceAlpha;
        else
            switch markerFaceColor
                case "none"
                    faceAlpha = 1;
                case "flat"
                    aLim = axisData.ALim;
                    faceAlpha = plotData.AlphaData;
                    faceAlpha = rescaleData(faceAlpha, aLim);
            end
        end
        marker.color = faceColor;
        marker.opacity = faceAlpha;
    end

    markerEdgeColor = plotData.MarkerEdgeColor;
    markerEdgeAlpha = plotData.MarkerEdgeAlpha;

    if isnumeric(markerEdgeColor)
        lineColor = getStringColor(round(255*markerEdgeColor));
    else
        switch markerEdgeColor
            case "none"
                lineColor = "rgba(0,0,0,0)";
            case "auto"
                if axisData.Color ~= "none"
                    lineColor = axisData.Color;
                else
                    lineColor = figureData.Color;
                end
                lineColor = getStringColor(round(255*lineColor), markerEdgeAlpha);
            case "flat"
                lineColor = getScatterFlatColor(plotData, axisData);
        end
    end

    if filledMarker
        marker.line.color = lineColor;
    else
        marker.color = lineColor;
        if plotData.Marker == "."
            marker.line.color = lineColor;
        end
    end
end

function flatColor = getScatterFlatColor(plotData, axisData)
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

    if cDataByIndex
        cMapInd = getcMapInd(cData, cLim, nColors);
        numColor = round(255 * colorMap(cMapInd, :));
    else
        numColor = round(255*cData);
    end

    if size(numColor, 1) == 1
        flatColor = getStringColor(numColor);
    else
        flatColor = cell(1, size(numColor, 1));
        for n = 1:size(numColor, 1)
            flatColor{n} = getStringColor(numColor(n, :));
        end
    end
end

function cMapInd = getcMapInd(cData, cLim, nColors)
    scaledCData = rescaleData(cData, cLim);
    cMapInd = 1 + floor(scaledCData*(nColors-1));
end

function outData = rescaleData(inData, dataLim)
    outData = max(min(inData, dataLim(2)), dataLim(1));
    outData = (outData - dataLim(1)) / diff(dataLim);
end

function markerSize = getMarkerSize(plotData)
    markerSize = plotData.SizeData;

    if isscalar(markerSize)
        if ~isempty(plotData.XData)
            dataSize = size(plotData.XData);
        else
            dataSize = size(plotData.RData); % polar plot
        end
        markerSize = markerSize * ones(dataSize);
        if isscalar(markerSize)
            markerSize = {markerSize};
        end
    end
end
