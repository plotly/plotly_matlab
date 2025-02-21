function marker = extractPatchFace(patch_data)
    % EXTRACTS THE FACE STYLE USED FOR MATLAB OBJECTS
    % OF TYPE "PATCH". THESE OBJECTS ARE USED BOXPLOTS.

    %-AXIS STRUCTURE-%
    axis_data = ancestor(patch_data.Parent,"axes");

    %-FIGURE STRUCTURE-%
    figure_data = ancestor(patch_data.Parent,"figure");

    %-INITIALIZE OUTPUT-%
    marker = struct();

    %-PATCH EDGE WIDTH-%
    marker.line.width = patch_data.LineWidth;

    %-PATCH FACE COLOR-%

    colormap = figure_data.Colormap;

    if isnumeric(patch_data.FaceColor)
        %-paper_bgcolor-%
        col = [round(255*patch_data.FaceColor) patch_data.FaceAlpha];
    else
        switch patch_data.FaceColor
            case "none"
                col = [0 0 0 0];
            case {"flat","interp"}
                switch patch_data.CDataMapping
                    case "scaled"
                        capCD = max(min(patch_data.FaceVertexCData(1,1), ...
                                axis_data.CLim(2)), axis_data.CLim(1));
                        scalefactor = (capCD - axis_data.CLim(1)) ...
                                / diff(axis_data.CLim);
                        col = round(255*(colormap(1 + floor(scalefactor ...
                                * (length(colormap)-1)),:)));
                    case "direct"
                        col = round(255*(colormap( ...
                                patch_data.FaceVertexCData(1,1),:)));
                end
                col = [col patch_data.FaceAlpha];
            case 'auto'
                cIndex = find(flipud(arrayfun(@(x) isequaln(x,patch_data), ...
                        patch_data.Parent.Children))); % far from pretty
                col = round(255*patch_data.Parent.ColorOrder(cIndex,:));
                col = [col patch_data.FaceAlpha];
        end
    end
    marker.color = sprintf("rgba(%d,%d,%d,%f)", col);

    %-PATCH EDGE COLOR-%
    if isnumeric(patch_data.EdgeColor)
        col = [255*patch_data.EdgeColor patch_data.EdgeAlpha];
    else
        switch patch_data.EdgeColor
            case "none"
                col = [0 0 0 0];
            case "flat"
                switch patch_data.CDataMapping
                    case "scaled"
                        capCD = max(min(patch_data.FaceVertexCData(1,1), ...
                                axis_data.CLim(2)),axis_data.CLim(1));
                        scalefactor = (capCD - axis_data.CLim(1)) ...
                                / diff(axis_data.CLim);
                        col = round(255*(colormap(1+floor(scalefactor ...
                                * (length(colormap)-1)),:)));
                    case "direct"
                        col = round(255*(colormap( ...
                                patch_data.FaceVertexCData(1,1),:)));
                end
                col = [col patch_data.EdgeAlpha];
        end
    end
    marker.line.color = sprintf("rgba(%d,%d,%d,%f)", col);
end
