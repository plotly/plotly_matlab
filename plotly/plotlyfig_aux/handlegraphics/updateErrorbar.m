function obj = updateErrorbar(obj, errorbarIndex)

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

%-------------------------------------------------------------------------%

%-ERRORBAR STRUCTURE-%
errorbar_data = get(obj.State.Plot(errorbarIndex).Handle);

%-------------------------------------------------------------------------%

%-UPDATE LINESERIES-%
updateLineseries(obj, errorbarIndex);

%-------------------------------------------------------------------------%

%-errorbar visible-%
obj.data{errorbarIndex}.error_y.visible = true;
obj.data{errorbarIndex}.error_x.visible = true;

%-------------------------------------------------------------------------%

%-errorbar type-%
obj.data{errorbarIndex}.error_y.type = 'data';
obj.data{errorbarIndex}.error_x.type = 'data';

%-------------------------------------------------------------------------%

%-errorbar symmetry-%
obj.data{errorbarIndex}.error_y.symmetric = false;

%-------------------------------------------------------------------------%

%-errorbar value-%
obj.data{errorbarIndex}.error_y.array = errorbar_data.YPositiveDelta;
obj.data{errorbarIndex}.error_x.array = errorbar_data.XPositiveDelta;

%-------------------------------------------------------------------------%

%-errorbar valueminus-%
obj.data{errorbarIndex}.error_y.arrayminus = errorbar_data.YNegativeDelta;
obj.data{errorbarIndex}.error_x.arrayminus = errorbar_data.XNegativeDelta;

%-------------------------------------------------------------------------%

%-errorbar thickness-%
obj.data{errorbarIndex}.error_y.thickness = errorbar_data.LineWidth;
obj.data{errorbarIndex}.error_x.thickness = errorbar_data.LineWidth;

%-------------------------------------------------------------------------%

%-errorbar width-%
obj.data{errorbarIndex}.error_y.width = obj.PlotlyDefaults.ErrorbarWidth;
obj.data{errorbarIndex}.error_x.width = obj.PlotlyDefaults.ErrorbarWidth;

%-------------------------------------------------------------------------%

%-errorbar color-%
col = 255*errorbar_data.Color;
obj.data{errorbarIndex}.error_y.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];
obj.data{errorbarIndex}.error_x.color = ['rgb(' num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ')'];

%-------------------------------------------------------------------------%

end