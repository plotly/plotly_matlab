function line = extractPatchLine(patch_data)
    % EXTRACTS THE LINE STYLE USED FOR MATLAB OBJECTS
    % OF TYPE "LINE". THESE OBJECTS ARE USED IN LINESERIES,
    % STAIRSERIES, STEMSERIES, BASELINESERIES, AND BOXPLOTS

    %---------------------------------------------------------------------%

    %-AXIS STRUCTURE-%
    axis_data = ancestor(patch_data.Parent,'axes');

    %-FIGURE STRUCTURE-%
    figure_data = ancestor(patch_data.Parent,'figure');

    %-INITIALIZE OUTPUT-%
    line = struct();

    %---------------------------------------------------------------------%

    %-PATCH LINE COLOR-%

    colormap = figure_data.Colormap;

    if (~strcmp(patch_data.LineStyle,'none'))
        if isnumeric(patch_data.EdgeColor)
            col = round(255*patch_data.EdgeColor);
            line.color = sprintf("rgb(%d,%d,%d)", col);
        else
            switch patch_data.EdgeColor
                case 'none'
                    line.color = 'rgba(0,0,0,0)';
                case 'flat'
                    switch patch_data.CDataMapping
                        case 'scaled'
                            capCD = max(min( ...
                                    patch_data.FaceVertexCData(1,1), ...
                                    axis_data.CLim(2)), axis_data.CLim(1));
                            scalefactor = (capCD - axis_data.CLim(1)) ...
                                    / diff(axis_data.CLim);
                            col = round(255*(colormap(1+floor(scalefactor ...
                                    * (length(colormap)-1)),:)));
                        case 'direct'
                            col = round(255*(colormap( ...
                                    patch_data.FaceVertexCData(1,1),:)));
                    end
                    line.color = sprintf("rgb(%d,%d,%d)", col);
            end
        end

        %-PATCH LINE WIDTH (STYLE)-%
        line.width = patch_data.LineWidth;

        %-PATCH LINE DASH (STYLE)-%
        switch patch_data.LineStyle
            case '-'
                LineStyle = 'solid';
            case '--'
                LineStyle = 'dash';
            case ':'
                LineStyle = 'dot';
            case '-.'
                LineStyle = 'dashdot';
        end
        line.dash = LineStyle;
    end
end
