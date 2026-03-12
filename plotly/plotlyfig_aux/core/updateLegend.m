function obj = updateLegend(obj, legIndex)
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

    %-STANDARDIZE UNITS-%
    legendunits = obj.State.Legend(legIndex).Handle.Units;
    fontunits = obj.State.Legend(legIndex).Handle.FontUnits;
    obj.State.Legend(legIndex).Handle.Units = 'normalized';
    obj.State.Legend(legIndex).Handle.FontUnits = 'points';

    %-LEGEND DATA STRUCTURE-%
    legend_data = obj.State.Legend(legIndex).Handle;

    % only displays last legend as global Plotly legend
    obj.layout.legend = struct();

    obj.layout.showlegend = strcmpi(legend_data.Visible,'on');
    obj.layout.legend.x = legend_data.Position(1);
    obj.layout.legend.xref = 'paper';
    obj.layout.legend.xanchor = 'left';
    obj.layout.legend.y = legend_data.Position(2);
    obj.layout.legend.yref = 'paper';
    obj.layout.legend.yanchor = 'bottom';
    obj.layout.legend.traceorder = 'normal';

    if (strcmp(legend_data.Box, 'on') && strcmp(legend_data.Visible, 'on'))
        obj.layout.legend.borderwidth = legend_data.LineWidth;

        col = round(255*legend_data.EdgeColor);
        obj.layout.legend.bordercolor = getStringColor(col);

        col = round(255*legend_data.Color);
        obj.layout.legend.bgcolor = getStringColor(col);

        obj.layout.legend.font.size = legend_data.FontSize;
        obj.layout.legend.font.family = ...
                matlab2plotlyfont(legend_data.FontName);

        col = round(255*legend_data.TextColor);
        obj.layout.legend.font.color = getStringColor(col);
    end

    %-ASSIGN LEGENDRANK TO MATCH CUSTOM LEGEND ORDER-%
    % MATLAB's legend.PlotChildren stores plot handles in the order
    % specified by the user (e.g. legend(lines(ix),...) reorders them).
    % Instead of physically reordering obj.data, we use Plotly's
    % per-trace legendrank property so that legend entries appear in
    % the user-specified order regardless of data-array position.
    assignLegendRank(obj, legend_data);

    %-REVERT UNITS-%
    obj.State.Legend(legIndex).Handle.Units = legendunits;
    obj.State.Legend(legIndex).Handle.FontUnits = fontunits;
end

function assignLegendRank(obj, legendHandle)
    if ~isprop(legendHandle, 'PlotChildren')
        return
    end

    legendPlots = legendHandle.PlotChildren;
    nTraces = numel(obj.data);

    % Build a map from MATLAB plot handle to Plotly trace index.
    handleToTrace = containers.Map('KeyType','double','ValueType','double');
    for k = 1:nTraces
        h = obj.State.Plot(k).Handle;
        if isa(h,'handle') || (isscalar(h) && isgraphics(h))
            handleToTrace(double(h)) = k;
        end
    end

    % Walk the legend's PlotChildren in order and assign ascending
    % legendrank values to the corresponding Plotly traces.
    rank = 0;
    for k = 1:numel(legendPlots)
        key = double(legendPlots(k));
        if handleToTrace.isKey(key)
            rank = rank + 1;
            traceIdx = handleToTrace(key);
            obj.data{traceIdx}.legendrank = rank;
        end
    end
end
