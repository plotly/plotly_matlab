% Temporary diagnostic: default DataTipRows of a plain scatter and the
% hovertext plotlyfig derives from them (testSingleScatterPlotData)

fprintf('MATLAB %s\n', version);
f = figure("Visible", "off");
s = scatter(1, 1);
rows = s.DataTipTemplate.DataTipRows;
fprintf('%d DataTipRows\n', numel(rows));
for k = 1:numel(rows)
    v = rows(k).Value;
    try
        valueText = strjoin(string(v), " ");
    catch
        valueText = '<not convertible to string>';
    end
    fprintf('row %d: Label=%s  class(Value)=%s  Value=%s\n', ...
        k, rows(k).Label, class(v), valueText);
end

p = plotlyfig(f, "visible", "off");
if isfield(p.data{1}, "hovertext")
    fprintf('hoverinfo: %s\n', string(p.data{1}.hoverinfo));
    fprintf('hovertext: %s\n', strjoin(string(p.data{1}.hovertext), " | "));
else
    disp('no hovertext');
end
close(f);
