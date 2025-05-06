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


    if (strcmp(legend_data.Box, 'on') && strcmp(legend_data.Visible, 'on'))
        obj.layout.legend.traceorder = 'normal';
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

    %-REVERT UNITS-%
    obj.State.Legend(legIndex).Handle.Units = legendunits;
    obj.State.Legend(legIndex).Handle.FontUnits = fontunits;
end
