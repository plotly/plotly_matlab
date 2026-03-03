function data = updateLineseries(obj, plotIndex)
    %-INITIALIZATIONS-%

    axIndex = obj.getAxisIndex(obj.State.Plot(plotIndex).AssociatedAxis);
    plotData = obj.State.Plot(plotIndex).Handle;

    %-check for multiple axes-%
    if isprop(plotData.Parent, "YAxis") && numel(plotData.Parent.YAxis) > 1
        yaxMatch = zeros(1,2);
        for yax = 1:2
            yAxisColor = plotData.Parent.YAxis(yax).Color;
            yaxMatch(yax) = sum(yAxisColor == plotData.Color);
        end
        [~, yaxIndex] = max(yaxMatch);
        [xSource, ySource] = findSourceAxis(obj, axIndex, yaxIndex);
    else
        [xSource, ySource] = findSourceAxis(obj,axIndex);
    end

    treatAs = lower(obj.PlotOptions.TreatAs);
    isPolar = ismember('compass', treatAs) || ismember('ezpolar', treatAs);

    isPlot3D = isfield(plotData, "ZData") && ~isempty(plotData.ZData);

    xData = plotData.XData;
    yData = plotData.YData;

    if isPolar
        rData = sqrt(xData.^2 + yData.^2);
        thetaData = atan2(xData, yData);
        thetaData = -(rad2deg(thetaData) - 90);
    end

    if isPlot3D
        zData = plotData.ZData;
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

    data.visible = plotData.Visible == "on";
    data.name = plotData.DisplayName;
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
    data.showlegend = getShowLegend(plotData) & ~isempty(plotData.DisplayName);
end

function polarAxis = updateDefaultPolarAxes(obj, plotIndex)
    %-INITIALIZATIONS-%
    plotData = obj.State.Plot(plotIndex).Handle;
    axisData = plotData.Parent;

    thetaAxis = axisData.XAxis;
    rAxis = axisData.YAxis;
    thetaLabel = thetaAxis.Label;

    %-set domain plot-%
    xo = axisData.Position(1);
    yo = axisData.Position(2);
    w = axisData.Position(3);
    h = axisData.Position(4);

    tickValues = rAxis.TickValues;
    tickValues = tickValues(find(tickValues==0) + 1 : end);
    rLabel = rAxis.Label;

    gridColor = getStringColor(255*axisData.GridColor, axisData.GridAlpha);
    gridWidth = axisData.LineWidth;

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
        "rotation", -axisData.View(1), ...
        "showticklabels", true, ...
        "nticks", 16, ...
        "tickfont", struct( ...
            "size", thetaAxis.FontSize, ...
            "color", getStringColor(round(255*thetaAxis.Color)), ...
            "family", matlab2plotlyfont(thetaAxis.FontName) ...
        ), ...
        "title", struct( ...
            "text", thetaLabel.String, ...
            "font", struct( ...
                "size", thetaLabel.FontSize, ...
                "color", getStringColor(round(255*thetaLabel.Color)), ...
                "family", matlab2plotlyfont(thetaLabel.FontName) ...
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
            "size", rAxis.FontSize, ...
            "color", getStringColor(round(255*rAxis.Color)), ...
            "family", matlab2plotlyfont(rAxis.FontName) ...
        ), ...
        "title", struct( ...
            "text", rLabel.String, ...
            "font", struct( ...
                "size", rLabel.FontSize, ...
                "color", getStringColor(round(255*rLabel.Color)), ...
                "family", matlab2plotlyfont(rLabel.FontName) ...
            ) ...
        ) ...
    );
end
