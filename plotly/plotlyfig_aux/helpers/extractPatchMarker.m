function marker = extractPatchMarker(patch_data)
    % EXTRACTS THE MARKER STYLE USED FOR MATLAB OBJECTS
    % OF TYPE "PATCH". THESE OBJECTS ARE USED IN AREASERIES
    % BARSERIES, CONTOURGROUP, SCATTERGROUP.

    %-AXIS STRUCTURE-%
    axis_data = ancestor(get(patch_data, 'Parent'), "axes");

    %-FIGURE STRUCTURE-%
    figure_data = ancestor(get(patch_data, 'Parent'), "figure");

    %-INITIALIZE OUTPUT-%
    marker = struct();

    % patches with Faces/Vertices store their colors in
    % FaceVertexCData; patches without it have an empty color array
    try
        tmpFaceVertexCData = get(patch_data, 'FaceVertexCData');
        if isempty(tmpFaceVertexCData)
            tmpFaceVertexCData = get(patch_data, 'CData');
        end
    catch
        try
            tmpFaceVertexCData = get(patch_data, 'CData');
        catch
            tmpFaceVertexCData = [];
        end
    end
    tmpCLim = get(axis_data, 'CLim');

    marker.sizeref = 1;
    marker.sizemode = "diameter";
    marker.size = get(patch_data, 'MarkerSize');

    %-MARKER SYMBOL (STYLE)-%
    if ~strcmp(get(patch_data, 'Marker'), "none")
        marker.symbol = getMarkerSymbol(get(patch_data, 'Marker'));
    end

    %-MARKER LINE WIDTH (STYLE)-%
    marker.line.width = get(patch_data, 'LineWidth');

    %--MARKER FILL COLOR--%

    %-figure colormap-%
    colormap = get(figure_data, 'Colormap');

    % marker face color
    MarkerColor = get(patch_data, 'MarkerFaceColor');

    filledMarkerSet = {'o','square','s','diamond','d',...
        'v','^', '<','>','hexagram','pentagram'};

    filledMarker = ismember(get(patch_data, 'Marker'), filledMarkerSet);

    % initialize markercolor output
    markercolor = cell(1, length(get(patch_data, 'FaceVertexCData')));

    if filledMarker
        if isnumeric(MarkerColor)
            col = round(255*MarkerColor);
            markercolor = getStringColor(col);
        else
            switch MarkerColor
                case "none"
                    markercolor = "rgba(0,0,0,0)";
                case "auto"
                    if ~strcmp(get(axis_data, 'Color'),"none")
                        col = round(255*get(axis_data, 'Color'));
                    else
                        col = round(255*get(figure_data, 'Color'));
                    end
                    markercolor = getStringColor(col);
                case "flat"
                    for n = 1:length(get(patch_data, 'FaceVertexCData'))
                        switch get(patch_data, 'CDataMapping')
                            case "scaled"
                                capCD = max(min( ...
                                        tmpFaceVertexCData(n,1), ...
                                        tmpCLim(2)), ...
                                        tmpCLim(1));
                                scalefactor = (capCD - tmpCLim(1)) ...
                                        / diff(get(axis_data, 'CLim'));
                                col = round(255*(colormap(1 + ...
                                        floor(scalefactor ...
                                        * (length(colormap)-1)),:)));
                            case "direct"
                                col = round(255*(colormap( ...
                                        tmpFaceVertexCData(n,1),:)));
                        end
                        markercolor{n} = getStringColor(col);
                    end
            end
        end
        marker.color = markercolor;
    end


    MarkerLineColor = get(patch_data, 'MarkerEdgeColor');
    filledMarker = ismember(get(patch_data, 'Marker'),filledMarkerSet);
    markerlinecolor = cell(1,length(get(patch_data, 'FaceVertexCData')));
    if isnumeric(MarkerLineColor)
        col = round(255*MarkerLineColor);
        markerlinecolor = getStringColor(col);
    else
        switch MarkerLineColor
            case "none"
                markerlinecolor = "rgba(0,0,0,0)";
            case "auto"
                EdgeColor = get(patch_data, 'EdgeColor');
                if isnumeric(EdgeColor)
                    col = round(255*EdgeColor);
                    markerlinecolor = getStringColor(col);
                else
                    switch EdgeColor
                        case "none"
                            markerlinecolor = "rgba(0,0,0,0)";
                        case {"flat", "interp"}
                            for n = 1:length(get(patch_data, 'FaceVertexCData'))
                                switch get(patch_data, 'CDataMapping')
                                    case "scaled"
                                        capCD = max(min( ...
                                                tmpFaceVertexCData(n,1), ...
                                                tmpCLim(2)), ...
                                                tmpCLim(1));
                                        scalefactor = (capCD ...
                                                - tmpCLim(1)) ...
                                                / diff(get(axis_data, 'CLim'));
                                        col = round(255*(colormap(1 + ...
                                                floor(scalefactor ...
                                                * (length(colormap)-1)),:)));
                                    case "direct"
                                        col = round(255*(colormap( ...
                                                tmpFaceVertexCData(n,1),:)));
                                end
                                markerlinecolor{n} = getStringColor(col);
                            end
                    end
                end
            case "flat"
                for n = 1:length(get(patch_data, 'FaceVertexCData'))
                    switch get(patch_data, 'CDataMapping')
                        case "scaled"
                            capCD = max(min( ...
                                    tmpFaceVertexCData(n,1), ...
                                    tmpCLim(2)), ...
                                    tmpCLim(1));
                            scalefactor = (capCD - tmpCLim(1)) ...
                                    / diff(get(axis_data, 'CLim'));
                            col = round(255*(colormap(1+floor(scalefactor ...
                                    * (length(colormap)-1)),:)));
                        case "direct"
                            col = round(255*(colormap( ...
                                    tmpFaceVertexCData(n,1),:)));
                    end
                    markerlinecolor{n} = getStringColor(col);
                end
        end
    end

    if filledMarker
        marker.line.color = markerlinecolor;
    else
        marker.color = markerlinecolor;
    end
end
