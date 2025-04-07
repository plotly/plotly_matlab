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

    data.marker = extractAreaFace(barData);
    data.marker.line = extractAreaLine(barData);

    obj.layout.bargroupgap = 1-barData.BarWidth;

    bars = findobj(obj.State.Plot(barIndex).AssociatedAxis.Children, ...
            "Type", "Bar");
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

    switch barData.Annotation.LegendInformation.IconDisplayStyle
        case "on"
            data.showlegend = true;
        case "off"
            data.showlegend = false;
    end
end
