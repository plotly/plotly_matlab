
x = -pi:pi/10:pi;
y = sin(x);
fig = figure('Name', 'Sample graph');
plot(x, y, '--rs');
% Label some points
for i=8:size(x,2)-8
text(x(i), y(i), 'Text');
end

% PLOTLY 
p = plotlyfigure(gcf);
plotly(p,false);
plotly_url = p.Response.url; 
