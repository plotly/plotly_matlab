function marker = extractBarMarker(bar_data)
    % EXTRACTS THE FACE STYLE USED FOR MATLAB OBJECTS
    % OF TYPE "bar". THESE OBJECTS ARE USED BARGRAPHS.

    cLim = get(ancestor(get(bar_data, 'Parent'), "axes"), 'CLim');
    colormap = get(ancestor(get(bar_data, 'Parent'), "figure"), 'Colormap');
    cDataMapping = get(bar_data, 'CDataMapping');
    tmpFaceVertexCData = get(bar_data, 'FaceVertexCData');
    faceVertexCData = tmpFaceVertexCData(1,1);

    marker = struct( ...
        "line", struct( ...
            "width", get(bar_data, 'LineWidth'), ...
            "color", extractColor(get(bar_data, 'EdgeColor'), cDataMapping, colormap, cLim, faceVertexCData) ...
        ), ...
        "color", extractColor(get(bar_data, 'FaceColor'), cDataMapping, colormap, cLim, faceVertexCData) ...
    );
end

function out = extractColor(color, cDataMapping, colormap, cLim, faceVertexCData)
    if isnumeric(color)
        out = getStringColor(round(255*color));
    else
        switch color
            case "none"
                out = "rgba(0,0,0,0)";
            case "flat"
                switch cDataMapping
                    case "scaled"
                        capCD = max(min(faceVertexCData, cLim(2)), cLim(1));
                        scalefactor = (capCD - cLim(1)) / diff(cLim);
                        col = colormap(1+floor(scalefactor ...
                                * (length(colormap)-1)),:);
                    case "direct"
                        col = colormap(faceVertexCData,:);
                end
                out = getStringColor(round(255*col));
        end
    end
end
