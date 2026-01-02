function data = updateConstantLine(obj,plotIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);

    %-PLOT DATA STRUCTURE- %
    plotData = obj.State.Plot(plotIndex).Handle;

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj, axIndex);

    data.xaxis = "x" + xsource;
    data.yaxis = "y" + ysource;
    data.type = "scatter";
    data.visible = plotData.Visible == "on";

    xaxis = obj.layout.("xaxis" + xsource);
    yaxis = obj.layout.("yaxis" + ysource);
    value = [plotData.Value plotData.Value];
    if plotData.InterceptAxis == "y"
        data.x = xaxis.range;
        data.y = value;
    else
        data.x = value;
        data.y = yaxis.range;
    end

    if ~isempty(plotData.Label)
        annotation = struct();

        annotation.showarrow = false;

        annotation.xref = "x" + xsource;
        annotation.yref = "y" + ysource;

        if plotData.InterceptAxis == "x"
            annotation.textangle = -90;
        end

        annotation.xanchor = plotData.LabelHorizontalAlignment;

        switch plotData.LabelVerticalAlignment
            case {"top", "cap"}
                annotation.yanchor = "top";
            case "middle"
                annotation.yanchor = "middle";
            case {"baseline","bottom"}
                annotation.yanchor = "bottom";
        end

        annotation.text = parseString( ...
                plotData.Label, plotData.Interpreter);
        annotation.text = "<b>" + join( ...
                string(annotation.text), "<br>") + "</b>";

        if plotData.InterceptAxis == "x"
            annotation.x = plotData.Value;
            annotation.y = yaxis.range(2);
        else
            annotation.x = xaxis.range(2);
            annotation.y = plotData.Value;
        end

        col = round(255*plotData.LabelColor);
        annotation.font.color = getStringColor(col);

        annotation.font.family = matlab2plotlyfont(plotData.FontName);
        annotation.font.size = plotData.FontSize;
        switch plotData.FontWeight
            case {"bold","demi"}
                annotation.text = "<b>" + annotation.text + "</b>";
            otherwise
        end

        if plotData.LabelHorizontalAlignment == "center"
            if plotData.InterceptAxis == "x"
                ylim = plotData.Parent.YLim;
                textWidth = text(0,0,plotData.Label,units="normalized", ...
                        rotation=90,Visible="off").Extent(4);
                textWidth = textWidth * (ylim(2) - ylim(1));
                data.y(2) = data.y(2) - textWidth;
            else
                xlim = plotData.Parent.XLim;
                textWidth = text(0,0,plotData.Label,units="normalized", ...
                        Visible="off").Extent(3);
                textWidth = textWidth * (xlim(2) - xlim(1));
                data.x(2) = data.x(2) - textWidth;
            end
        end

        obj.layout.annotations{end+1} = annotation;
    end

    %-For 3D plots-%
    obj.PlotOptions.is3d = false; % by default

    if isfield(plotData,"ZData")
        numbset = unique(plotData.ZData);
        if any(plotData.ZData) && length(numbset)>1
            data.z = plotData.ZData;
            data.type = "scatter3d";
            %-flag to manage 3d plots-%
            obj.PlotOptions.is3d = true;
        end
    end

    data.name = plotData.DisplayName;

    if plotData.Type ~= "constantline" ...
            && lower(plotData.Marker) ~= "none" ...
            && lower(plotData.LineStyle) ~= "none"
        mode = "lines+markers";
    elseif plotData.Type ~= "constantline" ...
            && lower(plotData.Marker) ~= "none"
        mode = "markers";
    elseif lower(plotData.LineStyle) ~= "none"
        mode = "lines";
    else
        mode = "none";
    end

    data.mode = mode;
    data.line = extractLineLine(plotData);

    if plotData.Type ~= "constantline"
        data.marker = extractLineMarker(plotData);
    end

    switch plotData.Annotation.LegendInformation.IconDisplayStyle
        case "on"
            data.showlegend = true;
        case "off"
            data.showlegend = false;
    end
end
