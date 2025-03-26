function updateConstantLine(obj,plotIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);

    %-PLOT DATA STRUCTURE- %
    plotData = obj.State.Plot(plotIndex).Handle;

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj, axIndex);

    %---------------------------------------------------------------------%

    obj.data{plotIndex}.xaxis = "x" + xsource;
    obj.data{plotIndex}.yaxis = "y" + ysource;
    obj.data{plotIndex}.type = "scatter";
    obj.data{plotIndex}.visible = strcmp(plotData.Visible, "on");

    %---------------------------------------------------------------------%

    %-scatter-%
    xaxis = obj.layout.("xaxis"+xsource);
    yaxis = obj.layout.("yaxis"+ysource);
    value = [plotData.Value plotData.Value];
    if plotData.InterceptAxis == "y"
        obj.data{plotIndex}.x = xaxis.range;
        obj.data{plotIndex}.y = value;
    else
        obj.data{plotIndex}.x = value;
        obj.data{plotIndex}.y = yaxis.range;
    end

    if ~isempty(plotData.Label)
        annotation = struct();

        annotation.showarrow = false;

        annotation.xref = "x"+xsource;
        annotation.yref = "y"+ysource;

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
        annotation.font.color = sprintf("rgb(%d,%d,%d)", col);

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
                textWidth = text(0,0,plotData.Label,units="normalized",rotation=90,Visible="off").Extent(4);
                textWidth = textWidth * (ylim(2) - ylim(1));
                obj.data{plotIndex}.y(2) = obj.data{plotIndex}.y(2) - textWidth;
            else
                xlim = plotData.Parent.XLim;
                textWidth = text(0,0,plotData.Label,units="normalized",Visible="off").Extent(3);
                textWidth = textWidth * (xlim(2) - xlim(1));
                obj.data{plotIndex}.x(2) = obj.data{plotIndex}.x(2) - textWidth;
            end
        end

        obj.layout.annotations{end+1} = annotation;
    end

    %---------------------------------------------------------------------%

    %-For 3D plots-%
    obj.PlotOptions.is3d = false; % by default

    if isfield(plotData,"ZData")
        numbset = unique(plotData.ZData);
        if any(plotData.ZData) && length(numbset)>1
            %-scatter z-%
            obj.data{plotIndex}.z = plotData.ZData;

            %-overwrite type-%
            obj.data{plotIndex}.type = "scatter3d";

            %-flag to manage 3d plots-%
            obj.PlotOptions.is3d = true;
        end
    end

    %---------------------------------------------------------------------%

    %-scatter name-%
    obj.data{plotIndex}.name = plotData.DisplayName;

    %---------------------------------------------------------------------%

    %-scatter mode-%
    if plotData.Type ~= "constantline" ...
            && ~strcmpi("none", plotData.Marker) ...
            && ~strcmpi("none", plotData.LineStyle)
        mode = "lines+markers";
    elseif plotData.Type ~= "constantline" ...
            && ~strcmpi("none", plotData.Marker)
        mode = "markers";
    elseif ~strcmpi("none", plotData.LineStyle)
        mode = "lines";
    else
        mode = "none";
    end

    obj.data{plotIndex}.mode = mode;

    %---------------------------------------------------------------------%

    %-scatter line-%
    obj.data{plotIndex}.line = extractLineLine(plotData);

    %---------------------------------------------------------------------%

    %-scatter marker-%
    if plotData.Type ~= "constantline"
        obj.data{plotIndex}.marker = extractLineMarker(plotData);
    end

    %---------------------------------------------------------------------%

    %-scatter showlegend-%
    leg = get(plotData.Annotation);
    legInfo = get(leg.LegendInformation);

    switch legInfo.IconDisplayStyle
        case "on"
            showleg = true;
        case "off"
            showleg = false;
    end

    obj.data{plotIndex}.showlegend = showleg;
end
