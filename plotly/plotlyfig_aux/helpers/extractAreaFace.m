function face = extractAreaFace(area_data)
    % EXTRACTS THE FACE STYLE USED FOR MATLAB OBJECTS
    % OF TYPE "PATCH". THESE OBJECTS ARE USED IN AREASERIES
    % BARSERIES, CONTOURGROUP, SCATTERGROUP.

    %-AXIS STRUCTURE-%
    axis_data = ancestor(area_data,"axes");

    %-FIGURE STRUCTURE-%
    figure_data = ancestor(area_data,"figure");

    %-INITIALIZE OUTPUT-%
    face = struct();

    %--FACE FILL COLOR--%

    %-figure colormap-%
    colormap = figure_data.Colormap;

    % face face color
    MarkerColor = area_data.FaceColor;
    if isnumeric(MarkerColor)
        col = MarkerColor;
        alpha = area_data.FaceAlpha;
    else
        switch MarkerColor
            case "none"
                col = [0 0 0];
                alpha = 0;
            case "flat"
                areaACData = area_data.getColorAlphaDataExtents;
                capCD = max(min(areaACData(1,1),axis_data.CLim(2)), ...
                        axis_data.CLim(1));
                scalefactor = (capCD - axis_data.CLim(1)) ...
                        / diff(axis_data.CLim);
                col = (colormap(1 + floor(scalefactor ...
                        * (length(colormap)-1)),:));
                alpha = area_data.FaceAlpha;
        end
    end
    face.color = getStringColor(round(255*col), alpha);
end
