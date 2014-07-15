function data = extractPlotData(obj)
plot_data = get(obj.State.DataHandle(obj.State.CurrentDataHandleIndex)); 
data{obj.State.CurrentDataHandleIndex}.x = plot_data.XData;
data{obj.State.CurrentDataHandleIndex}.y = plot_data.XData; 
% data{obj.CurrentDataHandleIndex}.r; 
% data{obj.CurrentDataHandleIndex}.t;
% data{obj.CurrentDataHandleIndex}.mode;
% data{obj.CurrentDataHandleIndex}.name;
% data{obj.CurrentDataHandleIndex}.text;
% data{obj.CurrentDataHandleIndex}.error_y;
% data{obj.CurrentDataHandleIndex}.error_x;
% data{obj.CurrentDataHandleIndex}.marker;
% data{obj.CurrentDataHandleIndex}.line;
% data{obj.CurrentDataHandleIndex}.connectgaps;
% data{obj.CurrentDataHandleIndex}.fill;
% data{obj.CurrentDataHandleIndex}.fillcolor;
% data{obj.CurrentDataHandleIndex}.opacity;
% data{obj.CurrentDataHandleIndex}.textfont;
% data{obj.CurrentDataHandleIndex}.textposition;
% data{obj.CurrentDataHandleIndex}.xaxis;
% data{obj.CurrentDataHandleIndex}.yaxis;
% data{obj.CurrentDataHandleIndex}.showlegend;
% data{obj.CurrentDataHandleIndex}.stream;
% data{obj.CurrentDataHandleIndex}.visible;
% data{obj.CurrentDataHandleIndex}.type;
end

