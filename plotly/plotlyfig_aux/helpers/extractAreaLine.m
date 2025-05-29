function line = extractAreaLine(area_data)
    % EXTRACTS THE LINE STYLE USED FOR MATLAB OBJECTS
    % OF TYPE "LINE". THESE OBJECTS ARE USED IN LINESERIES,
    % STAIRSERIES, STEMSERIES, BASELINESERIES, AND BOXPLOTS

    line = struct();
    if area_data.LineStyle == "none"
        return
    end

    LineColor = area_data.EdgeColor;
    if isnumeric(LineColor)
        linecolor = getStringColor(round(255*LineColor), area_data.EdgeAlpha);
    else
        linecolor = "rgba(0,0,0,0)";
    end

    line.color = linecolor;
    line.width = area_data.LineWidth;
    line.dash = getLineDash(area_data.LineStyle);
end
