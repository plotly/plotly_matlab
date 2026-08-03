function [marker, linee] = extractGeoLinePlusMarker(geoData, axisData)
    figureData = ancestor(get(geoData, 'Parent'), "figure");

    marker = struct();
    linee = struct();

    lineColor = get(geoData, 'Color');
    if isnumeric(lineColor)
        lineColor = getStringColor(round(255*lineColor));
    else
        switch lineColor
            case "none"
                lineColor = "rgba(0,0,0,0)";
            case {"auto", "manual"}
                lineColor = getStringColor(round(255*lineColor));
            case "flat"
                cData = get(geoData, 'CData');
                cMap = get(figureData, 'Colormap');
                ncolors = size(cMap, 1);
                tmpCLim = get(axisData, 'CLim');
                for m = 1:length(cData)
                    colorValue = max(min(cData(m), tmpCLim(2)), ...
                            tmpCLim(1));
                    scaleFactor = (colorValue - tmpCLim(1)) ...
                            / diff(get(axisData, 'CLim'));
                    rgbColor =  ound(255 * cMap(1+floor(scaleFactor ...
                            * (ncolors-1)),:));
                    lineColor{m} = getStringColor(rgbColor);
                end
        end
    end

    linee.color = lineColor;
    linee.width = 2*get(geoData, 'LineWidth');
    linee.dash = getLineDash(get(geoData, 'LineStyle'));

    marker.sizeref = 1;
    marker.sizemode = "area";
    marker.size = get(geoData, 'MarkerSize');

    if ~strcmp(get(geoData, 'Marker'), "none")
        marker.symbol = getMarkerSymbol(get(geoData, 'Marker'));
    end

    marker.line.width = 2*get(geoData, 'LineWidth');

    faceColor = get(geoData, 'MarkerFaceColor');

    filledMarkerSet = {'o','square','s','diamond','d','v','^', '<', ...
            '>','hexagram','pentagram'};
    filledMarker = ismember(get(geoData, 'Marker'), filledMarkerSet);

    if filledMarker
        if isnumeric(faceColor)
            markerColor = getStringColor(round(255*faceColor));
        else
            switch faceColor
                case "none"
                    markerColor = "rgba(0,0,0,0)";
                case "auto"
                    if ~strcmp(get(axisData, 'Color'), "none")
                        col = round(255*get(axisData, 'Color'));
                    else
                        col = round(255*get(figureData, 'Color'));
                    end
                    markerColor = getStringColor(col);
                case "flat"
                    cData = get(geoData, 'CData');
                    cMap = get(figureData, 'Colormap');
                    ncolors = size(cMap, 1);
                    markerColor = cell(1, length(cData));
                    for m = 1:length(cData)
                        colorValue = max(min(cData(m), ...
                                tmpCLim(2)), tmpCLim(1));
                        scaleFactor = (colorValue - tmpCLim(1)) ...
                                / diff(get(axisData, 'CLim'));
                        rgbColor = round(255 * cMap(1+floor(scaleFactor ...
                                * (ncolors-1)),:));
                        markerColor{m} = getStringColor(rgbColor);
                    end
            end
        end
        marker.color = markerColor;
    end

    edgeColor = get(geoData, 'MarkerEdgeColor');
    if isnumeric(edgeColor)
        lineColor = getStringColor(round(255*edgeColor));
    else
        switch edgeColor
            case "none"
                lineColor = "rgba(0,0,0,0)";
            case "auto"
                lineColor = getStringColor(round(255*get(geoData, 'Color')));
            case "flat"
                cData = get(geoData, 'CData');
                cMap = get(figureData, 'Colormap');
                ncolors = size(cMap, 1);
                lineColor = cell(1,length(cData));
                for m = 1:length(cData)
                    colorValue = max(min(cData(m), tmpCLim(2)), ...
                            tmpCLim(1));
                    scaleFactor = (colorValue - tmpCLim(1)) ...
                            / diff(get(axisData, 'CLim'));
                    rgbColor =  round(255 * cMap(1+floor(scaleFactor ...
                            * (ncolors-1)),:));
                    lineColor{m} = getStringColor(rgbColor);
                end
        end
    end

    if filledMarker
        marker.line.color = lineColor;
    else
        marker.color = lineColor;
    end
end
