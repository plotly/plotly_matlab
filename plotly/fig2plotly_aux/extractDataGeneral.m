function data = extractDataGeneral(d, data)
% extractDataGeneral - copy general data struct attributes
%   data = extractDataGeneral(d, data)
%       d - a data struct from matlab describing data
%       data - a plotly data struct
% 
% For full documentation and examples, see https://plot.ly/api

if strcmpi(d.Type,'line')
data.x = d.XData;
data.y = d.YData;
else %look at children
   child_temp = get(d.Children(1)); 
   data.x = child_temp.XData; 
   data.y = child_temp.YData; 
end

if strcmp('on', d.Visible)
    data.visible = true;
else
    data.visible = false;
end

if numel(d.DisplayName)>0
  %  data.name = parseText(d.DisplayName);
  data.name = (d.DisplayName);
else
    data.showlegend = false;
end


end