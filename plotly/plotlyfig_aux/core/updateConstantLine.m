function data = updateConstantLine(obj,plotIndex)
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);

    %-PLOT DATA STRUCTURE- %
    plotData = obj.State.Plot(plotIndex).Handle;

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj, axIndex);

    data.xaxis = sprintf("x%d", xsource);
    data.yaxis = sprintf("y%d", ysource);
    data.type = "scatter";
    data.visible = strcmp(get(plotData, 'Visible'), "on");

    xaxis = obj.layout.(sprintf("xaxis%d", xsource));
    yaxis = obj.layout.(sprintf("yaxis%d", ysource));
    value = [get(plotData, 'Value') get(plotData, 'Value')];
    if strcmp(get(plotData, 'InterceptAxis'), "y")
        data.x = xaxis.range;
        data.y = value;
    else
        data.x = value;
        data.y = yaxis.range;
    end

    if ~isempty(get(plotData, 'Label'))
        annotation = struct();

        annotation.showarrow = false;

        annotation.xref = sprintf("x%d", xsource);
        annotation.yref = sprintf("y%d", ysource);

        if strcmp(get(plotData, 'InterceptAxis'), "x")
            annotation.textangle = -90;
        end

        annotation.xanchor = get(plotData, 'LabelHorizontalAlignment');

        switch get(plotData, 'LabelVerticalAlignment')
            case {"top", "cap"}
                annotation.yanchor = "top";
            case "middle"
                annotation.yanchor = "middle";
            case {"baseline","bottom"}
                annotation.yanchor = "bottom";
        end

        annotation.text = parseString( ...
                get(plotData, 'Label'), get(plotData, 'Interpreter'));
        annotation.text = sprintf('<b>%s</b>', strjoin(cellstr(annotation.text), '<br>'));

        if strcmp(get(plotData, 'InterceptAxis'), "x")
            annotation.x = get(plotData, 'Value');
            annotation.y = yaxis.range(2);
        else
            annotation.x = xaxis.range(2);
            annotation.y = get(plotData, 'Value');
        end

        col = round(255*get(plotData, 'LabelColor'));
        annotation.font.color = getStringColor(col);

        annotation.font.family = matlab2plotlyfont(get(plotData, 'FontName'));
        annotation.font.size = get(plotData, 'FontSize');
        switch get(plotData, 'FontWeight')
            case {"bold","demi"}
                annotation.text = sprintf('<b>%s</b>', annotation.text);
            otherwise
        end

        if strcmp(get(plotData, 'LabelHorizontalAlignment'), "center")
            if strcmp(get(plotData, 'InterceptAxis'), "x")
                tmpExtent = get(text(0,0,get(plotData, 'Label'), ...
                        "units", "normalized", "rotation", 90, ...
                        "Visible", "off"), 'Extent');
                ylim = get(get(plotData, 'Parent'), 'YLim');
                textWidth = tmpExtent(4);
                textWidth = textWidth * (ylim(2) - ylim(1));
                data.y(2) = data.y(2) - textWidth;
            else
                tmpExtent2 = get(text(0,0,get(plotData, 'Label'), ...
                        "units", "normalized", ...
                        "Visible", "off"), 'Extent');
                xlim = get(get(plotData, 'Parent'), 'XLim');
                textWidth = tmpExtent2(3);
                textWidth = textWidth * (xlim(2) - xlim(1));
                data.x(2) = data.x(2) - textWidth;
            end
        end

        obj.layout.annotations{end+1} = annotation;
    end

    %-For 3D plots-%
    obj.PlotOptions.is3d = false; % by default

    if isprop(plotData, 'ZData')
        numbset = unique(get(plotData, 'ZData'));
        if any(get(plotData, 'ZData')) && length(numbset)>1
            data.z = get(plotData, 'ZData');
            data.type = "scatter3d";
            %-flag to manage 3d plots-%
            obj.PlotOptions.is3d = true;
        end
    end

    data.name = get(plotData, 'DisplayName');

    if ~strcmp(get(plotData, 'Type'), "constantline") ...
            && ~strcmpi(get(plotData, 'Marker'), "none") ...
            && ~strcmpi(get(plotData, 'LineStyle'), "none")
        mode = "lines+markers";
    elseif ~strcmp(get(plotData, 'Type'), "constantline") ...
            && ~strcmpi(get(plotData, 'Marker'), "none")
        mode = "markers";
    elseif ~strcmpi(get(plotData, 'LineStyle'), "none")
        mode = "lines";
    else
        mode = "none";
    end

    data.mode = mode;
    data.line = extractLineLine(plotData);

    if ~strcmp(get(plotData, 'Type'), "constantline")
        data.marker = extractLineMarker(plotData);
    end

    data.showlegend = getShowLegend(plotData);
end
