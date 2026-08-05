function marker = extractPatchFace(patch_data)
    % EXTRACTS THE FACE STYLE USED FOR MATLAB OBJECTS
    % OF TYPE "PATCH". THESE OBJECTS ARE USED BOXPLOTS.

    cLim = get(ancestor(get(patch_data, 'Parent'), {'axes' 'polaraxes'}), 'CLim');
    colormap = get(ancestor(get(patch_data, 'Parent'), "figure"), 'Colormap');

    marker = struct();
    marker.line.width = get(patch_data, 'LineWidth');

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

    faceColor = get(patch_data, 'FaceColor');
    alpha = 1;
    if isnumeric(faceColor)
        col = faceColor;
        if isprop(patch_data, 'FaceAlpha')
            alpha = get(patch_data, 'FaceAlpha');
        end
    else
        switch faceColor
            case "none"
                col = [0 0 0];
                alpha = 0;
            case {"flat","interp"}
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
                if isprop(patch_data, 'FaceAlpha')
                    alpha = get(patch_data, 'FaceAlpha');
                end
            case "auto"
                cIndex = find(flipud(arrayfun(@(x) isequaln(x,patch_data), ...
                        get(get(patch_data, 'Parent'), 'Children')))); % far from pretty
                tmpColorOrder = get(get(patch_data, 'Parent'), 'ColorOrder');
                col = tmpColorOrder(cIndex,:);
                if isprop(patch_data, 'FaceAlpha')
                    alpha = get(patch_data, 'FaceAlpha');
                end
        end
    end
    marker.color = getStringColor(round(255*col), alpha);

    edgeColor = get(patch_data, 'EdgeColor');
    alpha = 1;
    if isnumeric(edgeColor)
        col = edgeColor;
        if isprop(patch_data, 'EdgeAlpha')
            alpha = get(patch_data, 'EdgeAlpha');
        end
    else
        switch edgeColor
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
                if isprop(patch_data, 'EdgeAlpha')
                    alpha = get(patch_data, 'EdgeAlpha');
                end
        end
    end
    marker.line.color = getStringColor(round(255*col), alpha);
end
