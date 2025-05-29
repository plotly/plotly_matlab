function [marker, linee] = extractGeoLinePlusMarker(geoData, axisData)
    figureData = ancestor(geoData.Parent, "figure");

    marker = struct();
    linee = struct();

    lineColor = geoData.Color;
    if isnumeric(lineColor)
        lineColor = getStringColor(round(255*lineColor));
    else
        switch lineColor
            case "none"
                lineColor = "rgba(0,0,0,0)";
            case {"auto", "manual"}
                lineColor = getStringColor(round(255*lineColor));
            case "flat"
                cData = geoData.CData;
                cMap = figureData.Colormap;
                ncolors = size(cMap, 1);
                for m = 1:length(cData)
                    colorValue = max(min(cData(m), axisData.CLim(2)), ...
                            axisData.CLim(1));
                    scaleFactor = (colorValue - axisData.CLim(1)) ...
                            / diff(axisData.CLim);
                    rgbColor =  ound(255 * cMap(1+floor(scaleFactor ...
                            * (ncolors-1)),:));
                    lineColor{m} = getStringColor(rgbColor);
                end
        end
    end

    linee.color = lineColor;
    linee.width = 2*geoData.LineWidth;
    linee.dash = getLineDash(geoData.LineStyle);

    marker.sizeref = 1;
    marker.sizemode = "area";
    marker.size = geoData.MarkerSize;

    if ~strcmp(geoData.Marker, "none")
        marker.symbol = getMarkerSymbol(geoData.Marker);
    end

    marker.line.width = 2*geoData.LineWidth;

    faceColor = geoData.MarkerFaceColor;

    filledMarkerSet = {'o','square','s','diamond','d','v','^', '<', ...
            '>','hexagram','pentagram'};
    filledMarker = ismember(geoData.Marker, filledMarkerSet);

    if filledMarker
        if isnumeric(faceColor)
            markerColor = getStringColor(round(255*faceColor));
        else
            switch faceColor
                case "none"
                    markerColor = "rgba(0,0,0,0)";
                case "auto"
                    if ~strcmp(axisData.Color,"none")
                        col = round(255*axisData.Color);
                    else
                        col = round(255*figureData.Color);
                    end
                    markerColor = getStringColor(col);
                case "flat"
                    cData = geoData.CData;
                    cMap = figureData.Colormap;
                    ncolors = size(cMap, 1);
                    markerColor = cell(1, length(cData));
                    for m = 1:length(cData)
                        colorValue = max(min(cData(m), ...
                                axisData.CLim(2)), axisData.CLim(1));
                        scaleFactor = (colorValue - axisData.CLim(1)) ...
                                / diff(axisData.CLim);
                        rgbColor = round(255 * cMap(1+floor(scaleFactor ...
                                * (ncolors-1)),:));
                        markerColor{m} = getStringColor(rgbColor);
                    end
            end
        end
        marker.color = markerColor;
    end

    edgeColor = geoData.MarkerEdgeColor;
    if isnumeric(edgeColor)
        lineColor = getStringColor(round(255*edgeColor));
    else
        switch edgeColor
            case "none"
                lineColor = "rgba(0,0,0,0)";
            case "auto"
                lineColor = getStringColor(round(255*geoData.Color));
            case "flat"
                cData = geoData.CData;
                cMap = figureData.Colormap;
                ncolors = size(cMap, 1);
                lineColor = cell(1,length(cData));
                for m = 1:length(cData)
                    colorValue = max(min(cData(m), axisData.CLim(2)), ...
                            axisData.CLim(1));
                    scaleFactor = (colorValue - axisData.CLim(1)) ...
                            / diff(axisData.CLim);
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
