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
    tmpChildren = get(bar_data, 'Children');
    bar_child_data = tmpChildren(1);

    %-CHECK FOR MULTIPLE AXES-%
    [xsource, ysource] = findSourceAxis(obj,axIndex);

    obj.data{barIndex}.xaxis = sprintf("x%d", xsource);
    obj.data{barIndex}.yaxis = sprintf("y%d", ysource);
    obj.data{barIndex}.visible = strcmp(get(bar_data, 'Visible'),'on');
    obj.data{barIndex}.type = 'bar';
    obj.data{barIndex}.name = get(bar_data, 'DisplayName');

    switch get(bar_data, 'BarLayout')
        case 'grouped'
            obj.layout.barmode = 'group';
        case 'stacked'
            obj.layout.barmode = 'stack';
    end

    obj.layout.bargroupgap = 1-get(bar_data, 'BarWidth');
    obj.layout.bargap = obj.PlotlyDefaults.Bargap;

    %-bar orientation-%
    switch get(bar_data, 'Horizontal')
        case 'off'
            obj.data{barIndex}.orientation = 'v';
            obj.data{barIndex}.x = get(bar_data, 'XData');
            obj.data{barIndex}.y = get(bar_data, 'YData');
        case 'on'
            obj.data{barIndex}.orientation = 'h';
            obj.data{barIndex}.x = get(bar_data, 'YData');
            obj.data{barIndex}.y = get(bar_data, 'XData');
    end

    obj.data{barIndex}.showlegend = getShowLegend(bar_data);

    %-bar opacity-%
    if ~ischar(get(bar_child_data, 'FaceAlpha'))
        obj.data{barIndex}.opacity = get(bar_child_data, 'FaceAlpha');
    end

    %-bar marker-%
    obj.data{barIndex}.marker = extractPatchFace(bar_child_data);

    %-bar width: set when multiple bar series with different BarWidth-%
    parentAxis = obj.State.Plot(barIndex).AssociatedAxis;
    allBars = findobj(get(parentAxis, 'Children'), 'Type', 'hggroup');
    barWidths = [];
    for b = 1:numel(allBars)
        if isprop(allBars(b), 'barwidth')
            barWidths(end+1) = get(allBars(b), 'barwidth');
        end
    end
    if numel(unique(barWidths)) > 1
        obj.layout.barmode = 'overlay';
        obj.layout.bargap = 0;
        if isprop(bar_child_data, 'XData')
            xData = get(bar_child_data, 'XData');
            if ~isempty(xData)
                obj.data{barIndex}.width = max(xData(:,1)) - min(xData(:,1));
            end
        end
    end
end
