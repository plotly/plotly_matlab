function marker = extractPatchFace(patch_data)
    % EXTRACTS THE FACE STYLE USED FOR MATLAB OBJECTS
    % OF TYPE "PATCH". THESE OBJECTS ARE USED BOXPLOTS.

    cLim = get(ancestor(get(patch_data, 'Parent'), {"axes" "polaraxes"}), 'CLim');
    colormap = get(ancestor(get(patch_data, 'Parent'), "figure"), 'Colormap');

    marker = struct();
    marker.line.width = get(patch_data, 'LineWidth');

    if isnumeric(get(patch_data, 'FaceColor'))
        col = get(patch_data, 'FaceColor');
        alpha = get(patch_data, 'FaceAlpha');
    else
        switch get(patch_data, 'FaceColor')
            case "none"
                col = [0 0 0];
                alpha = 0;
            case {"flat","interp"}
                tmpFaceVertexCData = get(patch_data, 'FaceVertexCData');
                faceVertexCData = tmpFaceVertexCData(1,1);
                switch get(patch_data, 'CDataMapping')
                    case "scaled"
                        capCD = max(min(faceVertexCData, cLim(2)), cLim(1));
                        scalefactor = (capCD - cLim(1)) / diff(cLim);
                        col = colormap(1 + floor(scalefactor ...
                                * (length(colormap)-1)),:);
                    case "direct"
                        col = colormap(faceVertexCData,:);
                end
                alpha = get(patch_data, 'FaceAlpha');
            case "auto"
                cIndex = find(flipud(arrayfun(@(x) isequaln(x,patch_data), ...
                        get(get(patch_data, 'Parent'), 'Children')))); % far from pretty
                tmpColorOrder = get(get(patch_data, 'Parent'), 'ColorOrder');
                col = tmpColorOrder(cIndex,:);
                alpha = get(patch_data, 'FaceAlpha');
        end
    end
    marker.color = getStringColor(round(255*col), alpha);

    if isnumeric(get(patch_data, 'EdgeColor'))
        col = get(patch_data, 'EdgeColor');
        alpha = get(patch_data, 'EdgeAlpha');
    else
        switch get(patch_data, 'EdgeColor')
            case "none"
                col = [0 0 0];
                alpha = 0;
            case "flat"
                faceVertexCData = tmpFaceVertexCData(1,1);
                switch get(patch_data, 'CDataMapping')
                    case "scaled"
                        capCD = max(min(faceVertexCData, cLim(2)), cLim(1));
                        scalefactor = (capCD - cLim(1)) / diff(cLim);
                        col = colormap(1 + floor(scalefactor ...
                                * (length(colormap)-1)),:);
                    case "direct"
                        col = colormap(faceVertexCData,:);
                end
                alpha = get(patch_data, 'EdgeAlpha');
        end
    end
    marker.line.color = getStringColor(round(255*col), alpha);
end
