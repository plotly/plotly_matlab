function marker = extractGeoMarker(geoData, axisData)
    %-FIGURE STRUCTURE-%
    figureData = ancestor(geoData.Parent,'figure');

    %-INITIALIZE OUTPUT-%
    marker = struct();

    marker.sizeref = 1;
    marker.sizemode = 'area';
    marker.size = geoData.SizeData;

    %-MARKER SYMBOL (STYLE)-%
    if ~strcmp(geoData.Marker, 'none')
        switch geoData.Marker
            case '.'
                marksymbol = 'circle';
            case 'o'
                marksymbol = 'circle';
            case 'x'
                marksymbol = 'x-thin-open';
            case '+'
                marksymbol = 'cross-thin-open';
            case '*'
                marksymbol = 'asterisk-open';
            case {'s','square'}
                marksymbol = 'square';
            case {'d','diamond'}
                marksymbol = 'diamond';
            case 'v'
                marksymbol = 'triangle-down';
            case '^'
                marksymbol = 'star-triangle-up';
            case '<'
                marksymbol = 'triangle-left';
            case '>'
                marksymbol = 'triangle-right';
            case {'p','pentagram'}
                marksymbol = 'star';
            case {'h','hexagram'}
                marksymbol = 'hexagram';
        end

        marker.symbol = marksymbol;
    end

    %-MARKER LINE WIDTH (STYLE)-%
    marker.line.width = 2*geoData.LineWidth;

    %--MARKER FILL COLOR--%

    % marker face color
    faceColor = geoData.MarkerFaceColor;

    filledMarkerSet = {'o','square','s','diamond','d','v','^', '<', ...
            '>','hexagram','pentagram'};
    filledMarker = ismember(geoData.Marker, filledMarkerSet);

    if filledMarker
        if isnumeric(faceColor)
            markerColor = sprintf("rgb(%d,%d,%d)", round(255*faceColor));
        else
            switch faceColor
                case 'none'
                    markerColor = "rgba(0,0,0,0)";
                case 'auto'
                    if ~strcmp(axisData.Color, 'none')
                        col = round(255*axisData.Color);
                    else
                        col = round(255*figureData.Color);
                    end
                    markerColor = sprintf("rgb(%d,%d,%d)", col);
                case 'flat'
                    cData = geoData.CData;
                    cMap = figureData.Colormap;
                    ncolors = size(cMap, 1);
                    for m = 1:length(cData)
                        colorValue = max(min(cData(m), ...
                                axisData.CLim(2)), axisData.CLim(1));
                        scaleFactor = (colorValue - axisData.CLim(1)) ...
                                / diff(axisData.CLim);
                        rgbColor = round(255 * cMap(1+floor(scaleFactor ...
                                * (ncolors-1)),:));
                        markerColor{m} = sprintf("rgb(%d,%d,%d)", rgbColor);
                    end
            end
        end
        marker.color = markerColor;
    end

    %-MARKER LINE COLOR-%

    % marker edge color
    edgeColor = geoData.MarkerEdgeColor;

    if isnumeric(edgeColor)
        lineColor = sprintf("rgb(%d,%d,%d)", round(255*edgeColor));
    else
        switch edgeColor
            case 'none'
                lineColor = "rgba(0,0,0,0)";
            case 'auto'
                % TODO
            case 'flat'
                cData = geoData.CData;
                cMap = figureData.Colormap;
                ncolors = size(cMap, 1);
                for m = 1:length(cData)
                    colorValue = max(min(cData(m), axisData.CLim(2)), ...
                            axisData.CLim(1));
                    scaleFactor = (colorValue - axisData.CLim(1)) ...
                            / diff(axisData.CLim);
                    rgbColor = round(255 * cMap(1+floor(scaleFactor ...
                            * (ncolors-1)),:));
                    lineColor{m} = sprintf("rgb(%d,%d,%d)", rgbColor);
                end
        end
    end

    if filledMarker
        marker.line.color = lineColor;
    else
        marker.color = lineColor;
    end
end
