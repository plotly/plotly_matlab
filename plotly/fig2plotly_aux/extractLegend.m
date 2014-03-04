function legend = extractLegend(a)
% extractLegend - create a legend struct
%   [legend] = extractLegend(a)
%       a - a data struct from matlab describing an axis used as a legend
%       legend - a plotly legend struct
% 
% For full documentation and examples, see https://plot.ly/api

legend = {};

if strcmp(a.Visible, 'on')
    
    %POSITION
    legend.x = a.Position(1)+a.Position(3)/2;
    legend.y = a.Position(2)+a.Position(4)/2;    
    legend.xanchor = 'middle';
    legend.yanchor = 'middle';
  
end

end