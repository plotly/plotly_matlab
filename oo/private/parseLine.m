function line_str = parseLine(d)

%build marker struct
    line_str = [];
    % ommitted: '-' = solid by default
    if strcmp('--', d.LineStyle)
        line_str.dash = 'dash';
    end
    if strcmp(':', d.LineStyle)
        line_str.dash = 'dot';
    end
    if strcmp('-.', d.LineStyle)
        line_str.dash = 'dashdot';
    end
    
    line_str.width = d.LineWidth;
    color_field=[];
    if isfield(d, 'Color')
        color_field = d.Color;
    else
        if isfield(d, 'EdgeColor')
            color_field = d.EdgeColor;
        end
    end
    
    colors = setColorProperty(color_field, [], [], []);
    if numel(colors{1})>0
        line_str.color = colors{1};
    end
    
end