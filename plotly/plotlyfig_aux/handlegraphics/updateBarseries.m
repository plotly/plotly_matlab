function obj = updateBarseries(obj,barIndex)
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

    % LINE:
    % color: ........[N/A]
    % width: ...[NA]
    % dash: ...[NA]
    % opacity: ...[NA]
    % shape: ...[NA]
    % smoothing: ...[NA]
    % outliercolor: ...[NA]
    % outlierwidth: ...[NA]
    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(barIndex).AssociatedAxis);

    %-BAR DATA STRUCTURE- %
    bar_data = obj.State.Plot(barIndex).Handle;

    %-BAR CHILD (PATCH) DATA STRUCTURE- %
    bar_child_data = bar_data.Children(1);

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    obj.data{barIndex}.xaxis = "x" + xsource;
    obj.data{barIndex}.yaxis = "y" + ysource;
    obj.data{barIndex}.visible = strcmp(bar_data.Visible,'on');
    obj.data{barIndex}.type = 'bar';
    obj.data{barIndex}.name = bar_data.DisplayName;

    switch bar_data.BarLayout
        case 'grouped'
            obj.layout.barmode = 'group';
        case 'stacked'
            obj.layout.barmode = 'stack';
    end

    obj.layout.bargroupgap = 1-bar_data.BarWidth;
    obj.layout.bargap = obj.PlotlyDefaults.Bargap;

    %-bar orientation-%
    switch bar_data.Horizontal
        case 'off'
            obj.data{barIndex}.orientation = 'v';
            obj.data{barIndex}.x = bar_data.XData;
            obj.data{barIndex}.y = bar_data.YData;
        case 'on'
            obj.data{barIndex}.orientation = 'h';
            obj.data{barIndex}.x = bar_data.YData;
            obj.data{barIndex}.y = bar_data.XData;
    end

    switch bar_data.Annotation.LegendInformation.IconDisplayStyle
        case "on"
            obj.data{barIndex}.showlegend = true;
        case "off"
            obj.data{barIndex}.showlegend = false;
    end

    %-bar opacity-%
    if ~ischar(bar_child_data.FaceAlpha)
        obj.data{barIndex}.opacity = bar_child_data.FaceAlpha;
    end

    %-bar marker-%
    obj.data{barIndex}.marker = extractPatchFace(bar_child_data);
end
