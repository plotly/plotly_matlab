function obj = updateHeatmap(obj,heatIndex)

%-------------------------------------------------------------------------%

%-HEATMAP DATA STRUCTURE- %
heat_data = get(obj.State.Plot(heatIndex).Handle);
%-------------------------------------------------------------------------%

%-heatmap type-%
obj.data{heatIndex}.type = 'heatmap';

%-------------------------------------------------------------------------%

%-format data-%
obj.data{heatIndex}.x = heat_data.XData;
obj.data{heatIndex}.y = heat_data.YData;
obj.data{heatIndex}.z = heat_data.ColorData(end:-1:1, :);

%-------------------------------------------------------------------------%

%-heatmap colorscale-%
cmap = heat_data.Colormap;
len = length(cmap)-1;

for c = 1: length(cmap)
    col = 255 * cmap(c, :);
    obj.data{heatIndex}.colorscale{c} = { (c-1)/len , ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'  ]  };
end

%-------------------------------------------------------------------------%

%-setting plot-%
obj.data{heatIndex}.hoverinfo = 'text';
obj.data{heatIndex}.text = heat_data.ColorData(end:-1:1, :);
obj.data{heatIndex}.hoverlabel.bgcolor = 'white';

%-------------------------------------------------------------------------%

%-show colorbar-%
obj.data{heatIndex}.showscale = false;
if strcmpi(heat_data.ColorbarVisible, 'on')
    obj.data{heatIndex}.showscale = true;
end

%-------------------------------------------------------------------------%

%-hist visible-%
obj.data{heatIndex}.visible = strcmp(heat_data.Visible,'on');

%-------------------------------------------------------------------------%

end
