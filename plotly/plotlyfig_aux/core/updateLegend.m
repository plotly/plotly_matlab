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
    legendunits = get(obj.State.Legend(legIndex).Handle, 'Units');
    fontunits = get(obj.State.Legend(legIndex).Handle, 'FontUnits');
    set(obj.State.Legend(legIndex).Handle, 'Units', 'normalized');
    set(obj.State.Legend(legIndex).Handle, 'FontUnits', 'points');

    %-LEGEND DATA STRUCTURE-%
    legend_data = obj.State.Legend(legIndex).Handle;

    % only displays last legend as global Plotly legend
    legend = struct();

    obj.layout.showlegend = strcmpi(get(legend_data, 'Visible'), "on");
    tmpPosition = get(legend_data, 'Position');
    legend.x = tmpPosition(1);
    legend.xref = "paper";
    legend.xanchor = "left";
    legend.y = tmpPosition(2);
    legend.yref = "paper";
    legend.yanchor = "bottom";
    legend.traceorder = "normal";

    if (strcmp(get(legend_data, 'Box'), "on") && strcmp(get(legend_data, 'Visible'), "on"))
        legend.borderwidth = get(legend_data, 'LineWidth');
        legend.bordercolor = getStringColor(round(255*get(legend_data, 'EdgeColor')));
        legend.bgcolor = getStringColor(round(255*get(legend_data, 'Color')));
        legend.font.size = get(legend_data, 'FontSize');
        legend.font.family = matlab2plotlyfont(get(legend_data, 'FontName'));
        legend.font.color = getStringColor(round(255*get(legend_data, 'TextColor')));
    end
    obj.layout.legend = legend;

    %-ASSIGN LEGENDRANK TO MATCH CUSTOM LEGEND ORDER-%
    % MATLAB's legend.PlotChildren stores plot handles in the order
    % specified by the user (e.g. legend(lines(ix),...) reorders them).
    % Instead of physically reordering obj.data, we use Plotly's
    % per-trace legendrank property so that legend entries appear in
    % the user-specified order regardless of data-array position.
    assignLegendRank(obj, legend_data);

    %-REVERT UNITS-%
    set(obj.State.Legend(legIndex).Handle, 'Units', legendunits);
    set(obj.State.Legend(legIndex).Handle, 'FontUnits', fontunits);
end

function assignLegendRank(obj, legendHandle)
    if isprop(legendHandle, "PlotChildren")
        legendPlots = get(legendHandle, 'PlotChildren');
        nPlots = obj.State.Figure.NumPlots;

        % Build a map from MATLAB plot handle to Plotly trace index.
        % NOTE: obj.data may contain more entries than obj.State.Plot (e.g.
        % phantom scatter traces added by updateAxisMultipleYAxes for yyaxis
        % visibility), so iterate over the real plot count, not numel(obj.data).
        handleToTrace = containers.Map("KeyType", "double", "ValueType", "double");
        for k = 1:nPlots
            h = obj.State.Plot(k).Handle;
            if isa(h, "handle") || (isscalar(h) && isgraphics(h))
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
        return
    end

    % Octave path: the legend text children are created in reverse
    % display order (the last text child is the topmost entry for
    % vertical legends, leftmost for horizontal). This order is set at
    % legend creation time and does not depend on rendering, so it works
    % even for invisible figures. Match each entry's label to the trace
    % name.
    kids = get(legendHandle, 'children');
    texts = [];
    for k = 1:numel(kids)
        if strcmp(get(kids(k), 'type'), 'text')
            texts(end+1) = kids(k); %#ok<AGROW>
        end
    end
    if isempty(texts)
        return
    end

    rank = 0;
    for k = numel(texts):-1:1
        label = get(texts(k), 'string');
        for t = 1:numel(obj.data)
            if isfield(obj.data{t}, 'name') && strcmp(obj.data{t}.name, label)
                rank = rank + 1;
                obj.data{t}.legendrank = rank;
                break;
            end
        end
    end
end
