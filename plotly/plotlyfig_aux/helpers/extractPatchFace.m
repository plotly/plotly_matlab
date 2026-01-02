function marker = extractPatchFace(patch_data)
    % EXTRACTS THE FACE STYLE USED FOR MATLAB OBJECTS
    % OF TYPE "PATCH". THESE OBJECTS ARE USED BOXPLOTS.

    cLim = ancestor(patch_data.Parent, ["axes" "polaraxes"]).CLim;
    colormap = ancestor(patch_data.Parent, "figure").Colormap;

    marker = struct();
    marker.line.width = patch_data.LineWidth;

    if isnumeric(patch_data.FaceColor)
        col = patch_data.FaceColor;
        alpha = patch_data.FaceAlpha;
    else
        switch patch_data.FaceColor
            case "none"
                col = [0 0 0];
                alpha = 0;
            case {"flat","interp"}
                faceVertexCData = patch_data.FaceVertexCData(1,1);
                switch patch_data.CDataMapping
                    case "scaled"
                        capCD = max(min(faceVertexCData, cLim(2)), cLim(1));
                        scalefactor = (capCD - cLim(1)) / diff(cLim);
                        col = colormap(1 + floor(scalefactor ...
                                * (length(colormap)-1)),:);
                    case "direct"
                        col = colormap(faceVertexCData,:);
                end
                alpha = patch_data.FaceAlpha;
            case "auto"
                cIndex = find(flipud(arrayfun(@(x) isequaln(x,patch_data), ...
                        patch_data.Parent.Children))); % far from pretty
                col = patch_data.Parent.ColorOrder(cIndex,:);
                alpha = patch_data.FaceAlpha;
        end
    end
    marker.color = getStringColor(round(255*col), alpha);

    if isnumeric(patch_data.EdgeColor)
        col = patch_data.EdgeColor;
        alpha = patch_data.EdgeAlpha;
    else
        switch patch_data.EdgeColor
            case "none"
                col = [0 0 0];
                alpha = 0;
            case "flat"
                faceVertexCData = patch_data.FaceVertexCData(1,1);
                switch patch_data.CDataMapping
                    case "scaled"
                        capCD = max(min(faceVertexCData, cLim(2)), cLim(1));
                        scalefactor = (capCD - cLim(1)) / diff(cLim);
                        col = colormap(1 + floor(scalefactor ...
                                * (length(colormap)-1)),:);
                    case "direct"
                        col = colormap(faceVertexCData,:);
                end
                alpha = patch_data.EdgeAlpha;
        end
    end
    marker.line.color = getStringColor(round(255*col), alpha);
end
