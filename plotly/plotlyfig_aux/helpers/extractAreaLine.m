function line = extractAreaLine(area_data)
    % EXTRACTS THE LINE STYLE USED FOR MATLAB OBJECTS
    % OF TYPE "LINE". THESE OBJECTS ARE USED IN LINESERIES,
    % STAIRSERIES, STEMSERIES, BASELINESERIES, AND BOXPLOTS

    line = struct();

    if area_data.LineStyle ~= "none"
        LineColor = area_data.EdgeColor;
        if isnumeric(LineColor)
            linecolor = getStringColor(round(255*LineColor), ...
                    area_data.EdgeAlpha);
        else
            linecolor = "rgba(0,0,0,0)";
        end

        line.color = linecolor;
        line.width = area_data.LineWidth;

        switch area_data.LineStyle
            case "-"
                LineStyle = "solid";
            case "--"
                LineStyle = "dash";
            case ":"
                LineStyle = "dot";
            case "-."
                LineStyle = "dashdot";
        end
        line.dash = LineStyle;
    end
end
