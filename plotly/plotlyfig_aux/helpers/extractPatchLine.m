function line = extractPatchLine(patch_data)
    % EXTRACTS THE LINE STYLE USED FOR MATLAB OBJECTS
    % OF TYPE "LINE". THESE OBJECTS ARE USED IN LINESERIES,
    % STAIRSERIES, STEMSERIES, BASELINESERIES, AND BOXPLOTS

    line = struct();
    if strcmp(get(patch_data, 'LineStyle'), "none")
        return
    end

    cLim = get(ancestor(get(patch_data, 'Parent'), "axes"), 'CLim');
    colormap = get(ancestor(get(patch_data, 'Parent'), "figure"), 'Colormap');

    line.color = extractColor(patch_data, colormap, cLim);
    line.width = get(patch_data, 'LineWidth');
    line.dash = getLineDash(get(patch_data, 'LineStyle'));
end

function out = extractColor(patch_data, colormap, cLim)
    color = get(patch_data, 'EdgeColor');
    if isnumeric(color)
        out = getStringColor(round(255*color));
    else
        switch color
            case "none"
                out = "rgba(0,0,0,0)";
            case "flat"
                tmpFaceVertexCData = get(patch_data, 'FaceVertexCData');
                faceVertexCData = tmpFaceVertexCData(1,1);
                switch get(patch_data, 'CDataMapping')
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
