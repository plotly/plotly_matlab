function line = extractPatchLine(patch_data)
    % EXTRACTS THE LINE STYLE USED FOR MATLAB OBJECTS
    % OF TYPE "LINE". THESE OBJECTS ARE USED IN LINESERIES,
    % STAIRSERIES, STEMSERIES, BASELINESERIES, AND BOXPLOTS

    line = struct();
    if patch_data.LineStyle == "none"
        return
    end

    cLim = ancestor(patch_data.Parent, "axes").CLim;
    colormap = ancestor(patch_data.Parent, "figure").Colormap;
    faceVertexCData = patch_data.FaceVertexCData(1,1);
    cDataMapping = patch_data.CDataMapping;

    line.color = extractColor(patch_data.EdgeColor, cDataMapping, colormap, cLim, faceVertexCData);
    line.width = patch_data.LineWidth;
    line.dash = getLineDash(patch_data.LineStyle);
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
