function line = extractLineLine(line_data)
    % EXTRACTS THE LINE STYLE USED FOR MATLAB OBJECTS
    % OF TYPE "LINE". THESE OBJECTS ARE USED IN LINESERIES,
    % STAIRSERIES, STEMSERIES, BASELINESERIES, AND BOXPLOTS

    %-INITIALIZE OUTPUT-%
    line = struct();

    lineStyle = get(line_data, 'LineStyle');
    if ischar(lineStyle) && ~strcmp(lineStyle, "none")
        line.color = getStringColor(round(255*get(line_data, 'Color')));
        line.width = get(line_data, 'LineWidth');
        line.dash = getLineDash(lineStyle);
    end
end
