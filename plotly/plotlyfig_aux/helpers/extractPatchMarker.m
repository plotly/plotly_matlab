function marker = extractPatchMarker(patch_data)
    % EXTRACTS THE MARKER STYLE USED FOR MATLAB OBJECTS
    % OF TYPE "PATCH". THESE OBJECTS ARE USED IN AREASERIES
    % BARSERIES, CONTOURGROUP, SCATTERGROUP.

    %-AXIS STRUCTURE-%
    axis_data = ancestor(patch_data.Parent, "axes");

    %-FIGURE STRUCTURE-%
    figure_data = ancestor(patch_data.Parent, "figure");

    %-INITIALIZE OUTPUT-%
    marker = struct();

    marker.sizeref = 1;
    marker.sizemode = "diameter";
    marker.size = patch_data.MarkerSize;

    %-MARKER SYMBOL (STYLE)-%
    if ~strcmp(patch_data.Marker, "none")
        marker.symbol = getMarkerSymbol(patch_data.Marker);
    end

    %-MARKER LINE WIDTH (STYLE)-%
    marker.line.width = patch_data.LineWidth;

    %--MARKER FILL COLOR--%

    %-figure colormap-%
    colormap = figure_data.Colormap;

    % marker face color
    MarkerColor = patch_data.MarkerFaceColor;

    filledMarkerSet = {'o','square','s','diamond','d',...
        'v','^', '<','>','hexagram','pentagram'};

    filledMarker = ismember(patch_data.Marker, filledMarkerSet);

    % initialize markercolor output
    markercolor = cell(1, length(patch_data.FaceVertexCData));

    if filledMarker
        if isnumeric(MarkerColor)
            col = round(255*MarkerColor);
            markercolor = getStringColor(col);
        else
            switch MarkerColor
                case "none"
                    markercolor = "rgba(0,0,0,0)";
                case "auto"
                    if ~strcmp(axis_data.Color,"none")
                        col = round(255*axis_data.Color);
                    else
                        col = round(255*figure_data.Color);
                    end
                    markercolor = getStringColor(col);
                case "flat"
                    for n = 1:length(patch_data.FaceVertexCData)
                        switch patch_data.CDataMapping
                            case "scaled"
                                capCD = max(min( ...
                                        patch_data.FaceVertexCData(n,1), ...
                                        axis_data.CLim(2)), ...
                                        axis_data.CLim(1));
                                scalefactor = (capCD - axis_data.CLim(1)) ...
                                        / diff(axis_data.CLim);
                                col = round(255*(colormap(1 + ...
                                        floor(scalefactor ...
                                        * (length(colormap)-1)),:)));
                            case "direct"
                                col = round(255*(colormap( ...
                                        patch_data.FaceVertexCData(n,1),:)));
                        end
                        markercolor{n} = getStringColor(col);
                    end
            end
        end
        marker.color = markercolor;
    end


    MarkerLineColor = patch_data.MarkerEdgeColor;
    filledMarker = ismember(patch_data.Marker,filledMarkerSet);
    markerlinecolor = cell(1,length(patch_data.FaceVertexCData));
    if isnumeric(MarkerLineColor)
        col = round(255*MarkerLineColor);
        markerlinecolor = getStringColor(col);
    else
        switch MarkerLineColor
            case "none"
                markerlinecolor = "rgba(0,0,0,0)";
            case "auto"
                EdgeColor = patch_data.EdgeColor;
                if isnumeric(EdgeColor)
                    col = round(255*EdgeColor);
                    markerlinecolor = getStringColor(col);
                else
                    switch EdgeColor
                        case "none"
                            markerlinecolor = "rgba(0,0,0,0)";
                        case {"flat", "interp"}
                            for n = 1:length(patch_data.FaceVertexCData)
                                switch patch_data.CDataMapping
                                    case "scaled"
                                        capCD = max(min( ...
                                                patch_data.FaceVertexCData(n,1), ...
                                                axis_data.CLim(2)), ...
                                                axis_data.CLim(1));
                                        scalefactor = (capCD ...
                                                - axis_data.CLim(1)) ...
                                                / diff(axis_data.CLim);
                                        col = round(255*(colormap(1 + ...
                                                floor(scalefactor ...
                                                * (length(colormap)-1)),:)));
                                    case "direct"
                                        col = round(255*(colormap( ...
                                                patch_data.FaceVertexCData(n,1),:)));
                                end
                                markerlinecolor{n} = getStringColor(col);
                            end
                    end
                end
            case "flat"
                for n = 1:length(patch_data.FaceVertexCData)
                    switch patch_data.CDataMapping
                        case "scaled"
                            capCD = max(min( ...
                                    patch_data.FaceVertexCData(n,1), ...
                                    axis_data.CLim(2)), ...
                                    axis_data.CLim(1));
                            scalefactor = (capCD - axis_data.CLim(1)) ...
                                    / diff(axis_data.CLim);
                            col = round(255*(colormap(1+floor(scalefactor ...
                                    * (length(colormap)-1)),:)));
                        case "direct"
                            col = round(255*(colormap( ...
                                    patch_data.FaceVertexCData(n,1),:)));
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
