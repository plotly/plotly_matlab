function data = extractDataGeneral(d, data)
% extractDataGeneral - copy general data struct attributes
%   data = extractDataGeneral(d, data)
%       d - a data struct from matlab describing data
%       data - a plotly data struct
% 
% For full documentation and examples, see https://plot.ly/api

if (strcmp(d.Type,'line')||strcmp(d.Type,'patch')); 
data.x = d.XData;
data.y = d.YData;
else %look at children (this should look for line/patch children) 
   child_temp = get(d.Children(1)); 
   if(any(d.Children))
   data.x = child_temp.XData; 
   data.y = child_temp.YData; 
   else
       %no children and not a line or a patch? 
   end
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