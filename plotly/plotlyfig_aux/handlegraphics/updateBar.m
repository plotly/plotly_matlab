function data = updateBar(obj,barIndex)
    % x: ...[DONE]
    % y: ...[DONE]
    % name: ...[DONE]
    % orientation: ...[DONE]
    % text: ...[NOT SUPPORTED IN MATLAB]
    % error_y: ...[HANDLED BY ERRORBAR]
    % error_x: ...[HANDLED BY ERRORBAR]
    % opacity: ...[DONE]
    % xaxis: ...[DONE]
    % yaxis: ...[DONE]
    % showlegend: ...[DONE]
    % stream: ...[HANDLED BY PLOTLY STREAM]
    % visible: ...[DONE]
    % type: ...[DONE]
    % r: ...[NA]
    % t: ...[NA]
    % textfont: ...[NA]

    % MARKER:
    % color: ...DONE]
    % size: ...[NA]
    % symbol: ...[NA]
    % opacity: ...[NA]
    % sizeref: ...[NA]
    % sizemode: ...[NA]
    % colorscale: ...[NA]
    % cauto: ...[NA]
    % cmin: ...[NA]
    % cmax: ...[NA]
    % outliercolor: ...[NA]
    % maxdisplayed: ...[NA]

    % MARKER LINE:
    % color: ...[DONE]
    % width: ...[DONE]
    % dash: ...[NA]
    % opacity: ---[TODO]
    % shape: ...[NA]
    % smoothing: ...[NA]
    % outliercolor: ...[NA]
    % outlierwidth: ...[NA]

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(barIndex).AssociatedAxis);

    %-BAR DATA STRUCTURE- %
    barData = obj.State.Plot(barIndex).Handle;

    %-CHECK FOR MULTIPLE AXES-%
    [xSource, ySource] = findSourceAxis(obj, axIndex);

    data.xaxis = "x" + xSource;
    data.yaxis = "y" + ySource;
    data.type = "bar";
    data.name = barData.DisplayName;
    data.visible = barData.Visible == "on";

    %-find all grouped bars on the same axis-%
    parentAxis = obj.State.Plot(barIndex).AssociatedAxis;
    bars = findobj(parentAxis.Children, "Type", "Bar");

    %-check for multiple bar groups (cheap: just compare BarWidth values)-%
    barWidths = arrayfun(@(b) b.BarWidth, bars);
    hasMultipleGroups = numel(unique(barWidths)) > 1 ...
            && barData.BarLayout == "grouped";

    if hasMultipleGroups
        %-MULTI-GROUP: use overlay mode with explicit positions/widths-%
        barWidth = getRenderedBarWidth(obj, barData);

        switch barData.Horizontal
            case "off"
                data.orientation = "v";
                data.x = barData.XEndPoints;
                data.y = barData.YData;
            case "on"
                data.orientation = "h";
                data.x = barData.YData;
                data.y = barData.XEndPoints;
        end

        data.width = barWidth;
        obj.layout.barmode = "overlay";
        obj.layout.bargap = 0;
    else
        %-SINGLE GROUP: use plotly's built-in grouping-%
        switch barData.Horizontal
            case "off"
                data.orientation = "v";
                data.x = barData.XData;
                data.y = barData.YData;
            case "on"
                data.orientation = "h";
                data.x = barData.YData;
                data.y = barData.XData;
        end

        obj.layout.bargroupgap = 1-barData.BarWidth;

        nBar = sum({bars.BarLayout}=="grouped");
        if nBar > 1
            obj.layout.bargap = 0.2;
        else
            obj.layout.bargap = 0;
        end

        switch barData.BarLayout
            case "grouped"
                obj.layout.barmode = "group";
            case "stacked"
                obj.layout.barmode = "relative";
        end
    end

    data.marker = extractAreaFace(barData);
    data.marker.line = extractAreaLine(barData);

    data.showlegend = getShowLegend(barData);
end

function w = getRenderedBarWidth(obj, barData)
    % Extract actual bar width from MATLAB's rendered face vertex data.
    % Calls drawnow at most once per figure to populate vertex data.
    persistent lastFigure
    figHandle = obj.State.Figure.Handle;
    if isempty(lastFigure) || lastFigure ~= figHandle
        drawnow;
        lastFigure = figHandle;
    end

    w = barData.BarWidth;
    try
        vd = double(barData.Face.VertexData);
        if size(vd, 2) >= 4
            xVerts = vd(1, 1:4);
            w = max(xVerts) - min(xVerts);
        end
    catch
        % vertex data unavailable, fall back to BarWidth
    end
end
