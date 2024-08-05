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
    set(obj.State.Legend(legIndex).Handle, 'Units', 'normalized');
    set(obj.State.Legend(legIndex).Handle, 'FontUnits', 'points');

    %-LEGEND DATA STRUCTURE-%
    legend_data = obj.State.Legend(legIndex).Handle;

    % only displays last legend as global Plotly legend
    obj.layout.legend = struct();

    %---------------------------------------------------------------------%

    %-layout showlegend-%
    obj.layout.showlegend = strcmpi(legend_data.Visible,'on');

    %---------------------------------------------------------------------%

    %-legend x-%
    obj.layout.legend.x = legend_data.Position(1);

    %---------------------------------------------------------------------%

    %-legend xref-%
    obj.layout.legend.xref = 'paper';

    %---------------------------------------------------------------------%

    %-legend xanchor-%
    obj.layout.legend.xanchor = 'left';

    %---------------------------------------------------------------------%

    %-legend y-%
    obj.layout.legend.y = legend_data.Position(2);

    %---------------------------------------------------------------------%

    %-legend yref-%
    obj.layout.legend.yref = 'paper';

    %---------------------------------------------------------------------%

    %-legend yanchor-%
    obj.layout.legend.yanchor = 'bottom';

    %---------------------------------------------------------------------%

    if (strcmp(legend_data.Box,'on') && strcmp(legend_data.Visible, 'on'))
        %-legend traceorder-%
        obj.layout.legend.traceorder = 'normal';

        %-----------------------------------------------------------------%

        %-legend borderwidth-%
        obj.layout.legend.borderwidth = legend_data.LineWidth;

        %-----------------------------------------------------------------%

        %-legend bordercolor-%
        col = 255*legend_data.EdgeColor;
        obj.layout.legend.bordercolor = sprintf("rgb(%f,%f,%f)", col);

        %-----------------------------------------------------------------%
        
        %-legend bgcolor-%
        col = 255*legend_data.Color;
        obj.layout.legend.bgcolor = sprintf("rgb(%f,%f,%f)", col);
        
        %-----------------------------------------------------------------%
        
        %-legend font size-%
        obj.layout.legend.font.size = legend_data.FontSize;
        
        %-----------------------------------------------------------------%
        
        %-legend font family-%
        obj.layout.legend.font.family = ...
                matlab2plotlyfont(legend_data.FontName);
        
        %-----------------------------------------------------------------%
        
        %-legend font colour-%
        col = 255*legend_data.TextColor;
        obj.layout.legend.font.color = sprintf("rgb(%f,%f,%f)", col);
    end

    %---------------------------------------------------------------------%

    %-REVERT UNITS-%
    set(obj.State.Legend(legIndex).Handle,'Units',legendunits);
    set(obj.State.Legend(legIndex).Handle,'FontUnits',fontunits);
end
