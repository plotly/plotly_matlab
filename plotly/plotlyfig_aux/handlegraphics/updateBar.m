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

    data.xaxis = sprintf("x%d", xSource);
    data.yaxis = sprintf("y%d", ySource);
    data.type = "bar";
    data.name = get(barData, 'DisplayName');
    data.visible = strcmp(get(barData, 'Visible'), "on");

    %-find all grouped bars on the same axis-%
    parentAxis = obj.State.Plot(barIndex).AssociatedAxis;
    bars = findobj(get(parentAxis, 'Children'), "Type", "Bar");

    %-check for multiple bar groups (cheap: just compare BarWidth values)-%
    barWidths = arrayfun(@(b) get(b, 'BarWidth'), bars);
    hasMultipleGroups = numel(unique(barWidths)) > 1 ...
            && strcmp(get(barData, 'BarLayout'), "grouped");

    if hasMultipleGroups
        %-MULTI-GROUP: use overlay mode with explicit positions/widths-%
        barWidth = getRenderedBarWidth(obj, barData);

        switch get(barData, 'Horizontal')
            case "off"
                data.orientation = "v";
                data.x = get(barData, 'XEndPoints');
                data.y = get(barData, 'YData');
            case "on"
                data.orientation = "h";
                data.x = get(barData, 'YData');
                data.y = get(barData, 'XEndPoints');
        end

        data.width = barWidth;
        obj.layout.barmode = "overlay";
        obj.layout.bargap = 0;
    else
        %-SINGLE GROUP: use plotly's built-in grouping-%
        switch get(barData, 'Horizontal')
            case "off"
                data.orientation = "v";
                data.x = get(barData, 'XData');
                data.y = get(barData, 'YData');
            case "on"
                data.orientation = "h";
                data.x = get(barData, 'YData');
                data.y = get(barData, 'XData');
        end

        obj.layout.bargroupgap = 1-get(barData, 'BarWidth');

        nBar = sum(strcmp(get(bars, 'BarLayout'), "grouped"));
        if nBar > 1
            obj.layout.bargap = 0.2;
        else
            obj.layout.bargap = 0;
        end

        switch get(barData, 'BarLayout')
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

    w = get(barData, 'BarWidth');
    try
        vd = double(get(get(barData, 'Face'), 'VertexData'));
        if size(vd, 2) >= 4
            xVerts = vd(1, 1:4);
            w = max(xVerts) - min(xVerts);
        end
    catch
        % vertex data unavailable, fall back to BarWidth
    end
end
