
x = -pi:pi/10:pi;
y = sin(x);
fig = figure('filename', 'Sample graph');
plot(x, y, '--rs');
% Label some points
for i=8:size(x,2)-8
text(x(i), y(i), 'Text');
end

% PLOTLY 
response = fig2plotly(fig,'filename','matlab_text_chart_basic');
plotly_url = response.url;
