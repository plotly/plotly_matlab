function obj = updateBar(obj,barIndex)

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

    %-------------------------------------------------------------------------%

    %-AXIS INDEX-%
    axIndex = obj.getAxisIndex(obj.State.Plot(barIndex).AssociatedAxis);

    %-BAR DATA STRUCTURE- %
    barData = obj.State.Plot(barIndex).Handle;

    %-CHECK FOR MULTIPLE AXES-%
    [xSource, ySource] = findSourceAxis(obj, axIndex);

    %-------------------------------------------------------------------------%

    %-associate axis-%
    obj.data{barIndex}.xaxis = sprintf('x%d', xSource);
    obj.data{barIndex}.yaxis = sprintf('y%d', ySource);

    %-------------------------------------------------------------------------%

    %-set trace-%
    obj.data{barIndex}.type = 'bar';
    obj.data{barIndex}.name = barData.DisplayName;
    obj.data{barIndex}.visible = strcmp(barData.Visible,'on');

    %-------------------------------------------------------------------------%

    %-set plot data-%
    xData = barData.XData;
    yData = barData.YData;

    if isduration(xData) || isdatetime(xData), xData = datenum(xData); end
    if isduration(yData) || isdatetime(yData), yData = datenum(yData); end

    switch barData.Horizontal
        case 'off'
            obj.data{barIndex}.orientation = 'v';
            obj.data{barIndex}.x = xData;
            obj.data{barIndex}.y = yData;
            
        case 'on'
            obj.data{barIndex}.orientation = 'h';
            obj.data{barIndex}.x = yData;
            obj.data{barIndex}.y = xData;
    end

    %-------------------------------------------------------------------------%

    %-trace settings-%
    markerline = extractAreaLine(barData); 

    obj.data{barIndex}.marker = extractAreaFace(barData);
    obj.data{barIndex}.marker.line = markerline; 

    %-------------------------------------------------------------------------%

    %-layout settings-%
    obj.layout.bargroupgap = 1-barData.BarWidth;

    try
        obj.layout.bargap = obj.layout.bargap + 0.0625;
    catch
        obj.layout.bargap = 0.0625;
    end

    switch barData.BarLayout
        case 'grouped'
            obj.layout.barmode = 'group';
        case 'stacked'
            obj.layout.barmode = 'relative';
    end

    %-------------------------------------------------------------------------%

    %-bar showlegend-%
    leg = get(barData.Annotation);
    legInfo = get(leg.LegendInformation);

    switch legInfo.IconDisplayStyle
        case 'on'
            showleg = true;
        case 'off'
            showleg = false;
    end

    obj.data{barIndex}.showlegend = showleg;

    %-------------------------------------------------------------------------%
end


