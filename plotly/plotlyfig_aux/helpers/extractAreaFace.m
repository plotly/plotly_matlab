function face = extractAreaFace(area_data)
    % EXTRACTS THE FACE STYLE USED FOR MATLAB OBJECTS
    % OF TYPE "PATCH". THESE OBJECTS ARE USED IN AREASERIES
    % BARSERIES, CONTOURGROUP, SCATTERGROUP.

    %-AXIS STRUCTURE-%
    cLim = ancestor(area_data,"axes").CLim;
    colormap = ancestor(area_data, "figure").Colormap;

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
                capCD = max(min(areaACData(1,1),cLim(2)), cLim(1));
                scalefactor = (capCD - cLim(1)) / diff(cLim);
                col = colormap(1 + floor(scalefactor ...
                        * (length(colormap)-1)),:);
                alpha = area_data.FaceAlpha;
        end
    end
    face = struct(...
        "color", getStringColor(round(255*col), alpha) ...
    );
end
