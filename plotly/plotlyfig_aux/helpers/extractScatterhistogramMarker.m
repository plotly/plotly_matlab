function marker = extractScatterhistogramMarker(patch_data, t)
    % EXTRACTS THE MARKER STYLE USED FOR MATLAB OBJECTS
    % OF TYPE "PATCH". THESE OBJECTS ARE USED IN AREASERIES
    % BARSERIES, CONTOURGROUP, SCATTERGROUP.

    %-AXIS STRUCTURE-%
    axis_data = ancestor(get(patch_data, 'Parent'), "axes");

    %-FIGURE STRUCTURE-%
    figure_data = ancestor(get(patch_data, 'Parent'), "figure");

    %-INITIALIZE OUTPUT-%
    marker = struct();

    %-MARKER SIZE (STYLE)-%
    tmpMarkerSize = get(patch_data, 'MarkerSize');
    marker.size = tmpMarkerSize(t)*0.20;

    tmpMarkerStyle = get(patch_data, 'MarkerStyle');
    %-MARKER SYMBOL (STYLE)-%
    if ~strcmp(tmpMarkerStyle(t), "none")
        marker.symbol = getMarkerSymbol(tmpMarkerStyle(t));
    end

    %-MARKER LINE WIDTH (STYLE)-%
    tmpLineWidth = get(patch_data, 'LineWidth');
    marker.line.width = tmpLineWidth(t);

    %--MARKER COLOR--%

    %-figure colormap-%
    colormap = get(figure_data, 'Colormap');

    % marker face color
    tmpColor = get(patch_data, 'Color');
    MarkerColor = tmpColor(t, :);

    filledMarkerSet = {'o','square','s','diamond','d',...
        'v','^', '<','>','hexagram','pentagram'};

    filledMarker = ismember(tmpMarkerStyle(t), filledMarkerSet);

    if filledMarker && strcmp(get(patch_data, 'MarkerFilled'), "on")
        if isnumeric(MarkerColor)
            markercolor = getStringColor(round(255*MarkerColor));
        else
            switch MarkerColor
                case "none"
                    markercolor = "rgba(0,0,0,0)";
                case "auto"
                    if ~strcmp(get(axis_data, 'Color'), "none")
                        col = get(axis_data, 'Color');
                    else
                        col = get(figure_data, 'Color');
                    end
                    markercolor = getStringColor(round(255*col));
                case "flat"
                    markercolor = cell(1, length(get(patch_data, 'CData')));
                    tmpCData = get(patch_data, 'CData');
                    tmpCLim = get(axis_data, 'CLim');
                    for n = 1:length(get(patch_data, 'CData'))
                        capCD = max(min(tmpCData(n), ...
                                tmpCLim(2)), tmpCLim(1));
                        scalefactor = (capCD - tmpCLim(1)) ...
                                /diff(get(axis_data, 'CLim'));
                        col = colormap(1 + floor(scalefactor ...
                                * (length(colormap)-1)),:);
                        markercolor{n} = getStringColor(round(255*col));
                    end
            end
        end
        marker.color = markercolor;
    end

    if filledMarker
        marker.line.color = markercolor;
    end
end
