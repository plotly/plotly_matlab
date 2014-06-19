function legend = extractLegend(a)
% extractLegend - create a legend struct
%   [legend] = extractLegend(a)
%       a - a data struct from matlab describing an axis used as a legend
%       legend - a plotly legend struct
%
% For full documentation and examples, see https://plot.ly/api

legend = {};

if strcmp(a.Visible, 'on')
    
    legend.traceorder = 'reversed';
    %POSITION
    x_ref = a.Position(1)+a.Position(3)/2;
    y_ref = a.Position(2)+a.Position(4)/2;
    if x_ref>0.333
        if x_ref>0.666
            legend.x = a.Position(1)+a.Position(3);
            legend.xanchor = 'right';
        else
            legend.x = a.Position(1)+a.Position(3)/2;
            legend.xanchor = 'middle';
        end
    else
        legend.x = a.Position(1);
        legend.xanchor = 'left';
    end
    
    if y_ref>0.333
        if y_ref>0.666
            legend.y = a.Position(2)+a.Position(4);
            legend.yanchor = 'top';
        else
            legend.y = a.Position(2)+a.Position(4)/2;
            legend.yanchor = 'middle';
        end
    else
        legend.y = a.Position(2);
        legend.yanchor = 'bottom';
    end
    
    
    
end

end