function marker = extractLineMarker(line_data)
    % EXTRACTS THE MARKER STYLE USED FOR MATLAB OBJECTS
    % OF TYPE "LINE". THESE OBJECTS ARE USED IN LINESERIES,
    % STAIRSERIES, STEMSERIES, BASELINESERIES, AND BOXPLOTS

    %-INITIALIZE OUTPUT-%
    marker = struct();

    %-MARKER SIZE-%
    marker.size = line_data.MarkerSize;

    if line_data.Marker == "." % scale factor for points is off
        marker.size = floor(sqrt(marker.size));
    elseif length(marker.size) == 1
        marker.size = 0.6*marker.size;
    end

    %-MARKER SYMBOL-%
    if ~strcmp(line_data.Marker, "none")
        marker.symbol = getMarkerSymbol(line_data.Marker);
        if isfield(line_data, "MarkerIndices")
            marker.maxdisplayed=length(line_data.MarkerIndices)+1;
        end
    end

    %-MARKER LINE WIDTH-%
    marker.line.width = line_data.LineWidth;

    filledMarkerSet = ["o","square","s","diamond","d",...
            "v","^", "<",">","hexagram","pentagram"];

    filledMarker = ismember(line_data.Marker,filledMarkerSet);

    %--MARKER FILL COLOR--%
    MarkerColor = line_data.MarkerFaceColor;

    if filledMarker
        if isnumeric(MarkerColor)
            col = round(255*MarkerColor);
            markercolor = getStringColor(col);
        else
            switch MarkerColor
                case "none"
                    markercolor = "rgba(0,0,0,0)";
                case "auto"
                    markercolor = "rgba(0, 0.4470, 0.7410,1)";
            end
        end
        marker.color = markercolor;
    end

    %-MARKER LINE COLOR-%
    MarkerLineColor = line_data.MarkerEdgeColor;

    if isnumeric(MarkerLineColor)
        col = round(255*MarkerLineColor);
        markerlinecolor = getStringColor(col);
    else
        switch MarkerLineColor
            case "none"
                markerlinecolor = "rgba(0,0,0,0)";
            case "auto"
                col = round(255*line_data.Color);
                markerlinecolor = getStringColor(col);
        end
    end

    if filledMarker
        marker.line.color = markerlinecolor;
    else
        marker.color = markerlinecolor;
    end
end
