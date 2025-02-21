function obj = updateErrorbarseries(obj, errorbarIndex)
    % type: ...[DONE]
    % symmetric: ...[DONE]
    % array: ...[DONE]
    % value: ...[NA]
    % arrayminus: ...{DONE]
    % valueminus: ...[NA]
    % color: ...[DONE]
    % thickness: ...[DONE]
    % width: ...[DONE]
    % opacity: ---[TODO]
    % visible: ...[DONE]

    %-ERRORBAR STRUCTURE-%
    errorbar_data = obj.State.Plot(errorbarIndex).Handle;

    %-ERRORBAR CHILDREN-%
    errorbar_child = obj.State.Plot(errorbarIndex).Handle.Children;

    %-ERROR BAR LINE CHILD-%
    errorbar_line_child_data = errorbar_child(2);

    %-UPDATE LINESERIES-%
    updateLineseries(obj, errorbarIndex);

    obj.data{errorbarIndex}.error_y.visible = true;
    obj.data{errorbarIndex}.error_y.type = 'data';
    obj.data{errorbarIndex}.error_y.symmetric = false;
    obj.data{errorbarIndex}.error_y.array = errorbar_data.UData;
    obj.data{errorbarIndex}.error_y.arrayminus = errorbar_data.LData;
    obj.data{errorbarIndex}.error_y.thickness = errorbar_line_child_data.LineWidth;
    obj.data{errorbarIndex}.error_y.width = obj.PlotlyDefaults.ErrorbarWidth;

    %-errorbar color-%
    col = round(255*errorbar_line_child_data.Color);
    obj.data{errorbarIndex}.error_y.color = sprintf("rgb(%d,%d,%d)", col);
end
