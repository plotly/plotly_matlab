function line = extractLineLine(line_data)
    % EXTRACTS THE LINE STYLE USED FOR MATLAB OBJECTS
    % OF TYPE "LINE". THESE OBJECTS ARE USED IN LINESERIES,
    % STAIRSERIES, STEMSERIES, BASELINESERIES, AND BOXPLOTS

    %-INITIALIZE OUTPUT-%
    line = struct();

    if line_data.LineStyle ~= "none"
        line.color = getStringColor(round(255*line_data.Color));
        line.width = line_data.LineWidth;
        line.dash = getLineDash(line_data.LineStyle);
    end
end
