function obj = updateLegendMultipleAxes(obj, legIndex)
    % x: ...[DONE]
    % y: ...[DONE]
    % traceorder: ...[DONE]
    % font: ...[DONE]
    % bgcolor: ...[DONE]
    % bordercolor: ...[DONE]
    % borderwidth: ...[DONE]
    % xref: ...[DONE]
    % yref: ...[DONE]
    % xanchor: ...[DONE]
    % yanchor: ...[DONE]

    %=====================================================================%
    %
    %-GET NECESSARY INFO FOR MULTIPLE LEGENDS-%
    %
    %=====================================================================%

    for traceIndex = 1:obj.State.Figure.NumPlots
        allNames{traceIndex} = obj.data{traceIndex}.name;
        allShowLegens(traceIndex) = obj.data{traceIndex}.showlegend;
        obj.data{traceIndex}.showlegend = false;
        obj.data{traceIndex}.legendgroup = obj.data{traceIndex}.name;

        axIndex = obj.getAxisIndex( ...
                obj.State.Plot(traceIndex).AssociatedAxis);
        [xSource, ySource] = findSourceAxis(obj, axIndex);
        xAxis = obj.layout.("xaxis" + xSource);
        yAxis = obj.layout.("yaxis" + ySource);

        allDomain(traceIndex, 1) = max(xAxis.domain);
        allDomain(traceIndex, 2) = max(yAxis.domain);
    end

    [~, groupIndex] = unique(string(allNames));

    for traceIndex = groupIndex'
    obj.data{traceIndex}.showlegend = allShowLegens(traceIndex);
    end

    %-STANDARDIZE UNITS-%
    legendUnits = obj.State.Legend(legIndex).Handle.Units;
    fontUnits = obj.State.Legend(legIndex).Handle.FontUnits;
    obj.State.Legend(legIndex).Handle.Units = 'normalized';
    obj.State.Legend(legIndex).Handle.FontUnits = 'points';

    %-LEGEND DATA STRUCTURE-%
    legendData = obj.State.Legend(legIndex).Handle;

    % only displays last legend as global Plotly legend
    obj.layout.legend = struct();

    obj.layout.showlegend = strcmpi(legendData.Visible,'on');
    obj.layout.legend.x = 1.005 * max(allDomain(:,1));
    obj.layout.legend.y = 1.001 * max(allDomain(:,2));
    obj.layout.legend.xref = 'paper';
    obj.layout.legend.yref = 'paper';
    obj.layout.legend.xanchor = 'left';
    obj.layout.legend.yanchor = 'top';

    if (strcmp(legendData.Box, 'on') && strcmp(legendData.Visible, 'on'))
        obj.layout.legend.traceorder = 'normal';
        obj.layout.legend.borderwidth = legendData.LineWidth;

        col = round(255*legendData.EdgeColor);
        obj.layout.legend.bordercolor = getStringColor(col);

        col = round(255*legendData.Color);
        obj.layout.legend.bgcolor = getStringColor(col);

        obj.layout.legend.font.size = legendData.FontSize;
        obj.layout.legend.font.family = ...
                matlab2plotlyfont(legendData.FontName);

        col = round(255*legendData.TextColor);
        obj.layout.legend.font.color = getStringColor(col);
    end

    %-REVERT UNITS-%
    obj.State.Legend(legIndex).Handle.Units = legendUnits;
    obj.State.Legend(legIndex).Handle.FontUnits = fontUnits;
end
