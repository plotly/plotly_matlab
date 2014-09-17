function obj = updateErrorbarseries(obj, dataIndex)

% type: ...[DONE]
% symmetric: ...[DONE]
% array: ...[DONE]
% value: ...[NA]
% arrayminus: ...{DONE]
% valueminus: ...[NA]
% color: ...[DONE]
% thickness: ...[DONE]
% width: ...[DONE]
% opacity: ...[NOT SUPPORTED IN MATLAB]
% visible: ...[DONE]

%-------------------------------------------------------------------------%

%-ERRORBAR STRUCTURE-%
errorbar_data = get(obj.State.Plot.Handle);

%-ERRORBAR CHILDREN-%
errorbar_child = get(obj.State.Plot.Handle,'Children');

%-ERROR BAR LINE CHILD-%
errorbar_line_child_data = get(errorbar_child(2));

%-------------------------------------------------------------------------%

%-UPDATE LINESERIES-%
updateLineseries(obj, dataIndex);

%-------------------------------------------------------------------------%

%-errorbar mode-%
obj.data{dataIndex}.mode = 'markers';

%-------------------------------------------------------------------------%

%-errorbar visible-%
obj.data{dataIndex}.error_y.visible = true;

%-------------------------------------------------------------------------%

%-errorbar type-%
obj.data{dataIndex}.error_y.type = 'data';

%-------------------------------------------------------------------------%

%-errorbar symmetry-%
obj.data{dataIndex}.error_y.symmetric = false;

%-------------------------------------------------------------------------%

%-errorbar value-%
obj.data{dataIndex}.error_y.array = errorbar_data.UData;

%-------------------------------------------------------------------------%

%-errorbar valueminus-%
obj.data{dataIndex}.error_y.arrayminus = errorbar_data.LData;

%-----------------------------!STYLE!-------------------------------------%

if ~obj.PlotOptions.Strip
    %-errorbar thickness-%
    obj.data{dataIndex}.error_y.thickness = errorbar_line_child_data.LineWidth;
    
    %-------------------------------------------------------------------------%
    
    %-errorbar width-%
    obj.data{dataIndex}.error_y.width = obj.PlotlyDefaults.ErrorbarWidth;
    
    %-------------------------------------------------------------------------%
    
    %-errorbar color-%
    col = 255*errorbar_line_child_data.Color;
    obj.data{dataIndex}.error_y.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
    
    %-------------------------------------------------------------------------%
end
end