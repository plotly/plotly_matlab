function data = updateLineseries(obj, plotIndex)
    %-INITIALIZATIONS-%

    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    plotData = obj.State.Plot(plotIndex).Handle;

    %-check for multiple axes-%
    if isprop(get(plotData, 'Parent'), "YAxis") && numel(get(get(plotData, 'Parent'), 'YAxis')) > 1
        yaxMatch = zeros(1,2);
        for yax = 1:2
            tmpYAxis = get(get(plotData, 'Parent'), 'YAxis');
            yAxisColor = get(tmpYAxis(yax), 'Color');
            yaxMatch(yax) = sum(yAxisColor == get(plotData, 'Color'));
        end
        [~, yaxIndex] = max(yaxMatch);
        [xSource, ySource] = findSourceAxis(obj, axIndex, yaxIndex);
    else
        [xSource, ySource] = findSourceAxis(obj,axIndex);
    end

    treatAs = lower(obj.PlotOptions.TreatAs);
    isPolar = ismember('compass', treatAs) || ismember('ezpolar', treatAs);

    isPlot3D = isfield(plotData, "ZData") && ~isempty(get(plotData, 'ZData'));

    xData = get(plotData, 'XData');
    yData = get(plotData, 'YData');

    if isPolar
        rData = sqrt(xData.^2 + yData.^2);
        thetaData = atan2(xData, yData);
        thetaData = -(rad2deg(thetaData) - 90);
    end

    if isPlot3D
        zData = get(plotData, 'ZData');
    end

    if isPolar
        data.type = "scatterpolar";
        data.subplot = sprintf("polar%d", xSource+1);
        obj.layout.(data.subplot) = updateDefaultPolarAxes(obj, plotIndex);
    elseif ~isPlot3D
        data.type = "scatter";
        data.xaxis = "x" + xSource;
        data.yaxis = "y" + ySource;
    else
        data.type = "scatter3d";
        data.scene = "scene" + xSource;
        updateScene(obj, plotIndex);
    end

    data.visible = strcmp(get(plotData, 'Visible'), "on");
    data.name = get(plotData, 'DisplayName');
    data.mode = getScatterMode(plotData);

    if isPolar
        data.r = rData;
        data.theta = thetaData;
    else
        data.x = xData;
        data.y = yData;
        if isPlot3D
            data.z = zData;
            obj.PlotOptions.is3d = true;
        end
    end

    % Handle custom datatip rows
    hasDataTipRows = isprop(plotData, "DataTipTemplate") && isprop(plotData.DataTipTemplate, "DataTipRows");
    if hasDataTipRows
        dataTipRows = plotData.DataTipTemplate.DataTipRows;
        exclude = ["Size" "Color" "X" "Y" "Z" "Y Delta"];
        dataTipRows = dataTipRows(~ismember({dataTipRows.Label}, exclude));
        if numel(dataTipRows) > 0
            customLabel = "";
            xDataLabel = "X";
            yDataLabel = "Y";
            for i = 1:numel(dataTipRows)
                dataTipRow = dataTipRows(i);
                if isequal(dataTipRow.Value, "XData")
                    xDataLabel = string(dataTipRow.Label);
                    continue
                end
                if isequal(dataTipRow.Value, "YData")
                    yDataLabel = string(dataTipRow.Label);
                    continue
                end
                customLabel = customLabel + arrayfun(@(value) string(dataTipRow.Label) ...
                        + ": " + string(value) + "<br>", dataTipRow.Value);
            end
            if isPolar
                data.hovertext = "R: " + data.r(:) + "<br>" + "Theta: " + ...
                        data.theta(:) + "<br>" + customLabel(:);
            elseif isPlot3D
                data.hovertext = xDataLabel + ": " + data.x(:) + "<br>" ...
                               + yDataLabel + ": " + data.y(:) + "<br>" ...
                               + "Z: " + data.z(:) + "<br>" + customLabel(:);
            else
                data.hovertext = xDataLabel + ": " + data.x(:) + "<br>" ...
                               + yDataLabel + ": " + data.y(:) + "<br>" ...
                               + customLabel(:);
            end
            data.hoverinfo = "text";
        end
    end

    data.line = extractLineLine(plotData);
    if isPolar
        data.line.width = data.line.width * 1.5;
    end
    data.marker = extractLineMarker(plotData);
    data.showlegend = getShowLegend(plotData) & ~isempty(get(plotData, 'DisplayName'));
end

function polarAxis = updateDefaultPolarAxes(obj, plotIndex)
    %-INITIALIZATIONS-%
    plotData = obj.State.Plot(plotIndex).Handle;
    axisData = get(plotData, 'Parent');

    thetaAxis = get(axisData, 'XAxis');
    rAxis = get(axisData, 'YAxis');
    thetaLabel = get(thetaAxis, 'Label');

    %-set domain plot-%
    tmpPosition = get(axisData, 'Position');
    xo = tmpPosition(1);
    yo = tmpPosition(2);
    w = tmpPosition(3);
    h = tmpPosition(4);

    tickValues = get(rAxis, 'TickValues');
    tickValues = tickValues(find(tickValues==0) + 1 : end);
    rLabel = get(rAxis, 'Label');

    gridColor = getStringColor(255*get(axisData, 'GridColor'), get(axisData, 'GridAlpha'));
    gridWidth = get(axisData, 'LineWidth');
tmpView = get(axisData, 'View');

    polarAxis.domain = struct( ...
        "x", min([xo xo + w], 1), ...
        "y", min([yo yo + h], 1) ...
    );
    polarAxis.angularaxis = struct(...
        "ticklen", 0, ...
        "autorange", true, ...
        "linecolor", gridColor, ...
        "gridwidth", gridWidth, ...
        "gridcolor", gridColor, ...
        "rotation", -tmpView(1), ...
        "showticklabels", true, ...
        "nticks", 16, ...
        "tickfont", struct( ...
            "size", get(thetaAxis, 'FontSize'), ...
            "color", getStringColor(round(255*get(thetaAxis, 'Color'))), ...
            "family", matlab2plotlyfont(get(thetaAxis, 'FontName')) ...
        ), ...
        "title", struct( ...
            "text", get(thetaLabel, 'String'), ...
            "font", struct( ...
                "size", get(thetaLabel, 'FontSize'), ...
                "color", getStringColor(round(255*get(thetaLabel, 'Color'))), ...
                "family", matlab2plotlyfont(get(thetaLabel, 'FontName')) ...
            ) ...
        ) ...
    );
    polarAxis.radialaxis = struct( ...
        "ticklen", 0, ...
        "range", [0,  tickValues(end)], ...
        "showline", false, ...
        "angle", 80, ...
        "tickangle", 80, ...
        "gridwidth", gridWidth, ...
        "gridcolor", gridColor, ...
        "showticklabels", true, ...
        "tickvals", tickValues, ...
        "tickfont", struct( ...
            "size", get(rAxis, 'FontSize'), ...
            "color", getStringColor(round(255*get(rAxis, 'Color'))), ...
            "family", matlab2plotlyfont(get(rAxis, 'FontName')) ...
        ), ...
        "title", struct( ...
            "text", get(rLabel, 'String'), ...
            "font", struct( ...
                "size", get(rLabel, 'FontSize'), ...
                "color", getStringColor(round(255*get(rLabel, 'Color'))), ...
                "family", matlab2plotlyfont(get(rLabel, 'FontName')) ...
            ) ...
        ) ...
    );
end
