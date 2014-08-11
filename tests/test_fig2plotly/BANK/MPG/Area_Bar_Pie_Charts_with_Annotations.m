%%
% This is an example of creating area charts, bar charts, and pie charts with some annotation in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/fill.html |fill|>, <http://www.mathworks.com/help/matlab/ref/bar.html |bar|>, <http://www.mathworks.com/help/matlab/ref/text.html |text|>, and <http://www.mathworks.com/help/matlab/ref/pie.html |pie|> functions in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Set up data
t  = 0:0.01:2*pi;
x1 = -pi/2:0.01:pi/2;
x2 = -pi/2:0.01:pi/2;
y1 = sin(2*x1);
y2 = 0.5*tan(0.8*x2);
y3 = -0.7*tan(0.8*x2);
rho = 1 + 0.5*sin(7*t).*cos(3*t);
x = rho.*cos(t);
y = rho.*sin(t);

% Create the left plot (filled plots, errorbars, texts)
fig = figure;
subplot(121);
hold on;
h(1) = fill(x, y, [0 .7 .7]);
set(h(1), 'EdgeColor', 'none');

h(2) = fill([x1, x2(end:-1:1)], [y1, y2(end:-1:1)], [.8 .8 .6]);
set(h(2), 'EdgeColor', 'none');

h(3) = line(x1, y1, 'LineWidth', 1.5, 'LineStyle', ':');
h(4) = line(x2, y2, 'Linewidth', 1.5, 'LineStyle', '--', 'Color', 'red');
h(5) = line(x2, y3, 'Linewidth', 1.5, 'LineStyle', '-.', 'Color', [0 .5 0]);

% Create error bars
err = abs(y2-y1);
hh = errorbar(x2(1:15:end), y3(1:15:end), err(1:15:end), 'r');
h(6) = hh(1);

% Create annotations
text(x2(15), y3(15), '\leftarrow \psi = -.7tan(.8\theta)', ...
   'FontWeight', 'bold', 'FontName', 'times-roman', ...
   'Color', [0 0.5 0], 'FontAngle', 'italic');
text(x2(10), y2(10),'\leftarrow \psi = .5tan(.8\theta)', ...
   'FontWeight', 'bold', 'FontName', 'times-roman',...
   'Color', 'red', 'FontAngle', 'italic');

text(0, -1.65, 'Text box', 'EdgeColor', [.3 0 .3], ...
   'HorizontalAlignment', 'center', ...
   'VerticalAlignment', 'middle', 'LineStyle', ':', ...
   'FontName', 'palatino', 'Margin', 4, 'BackgroundColor', [.8 .8 1], ...
   'LineWidth', 1);

% Adjust axes properties
axis equal;
set(gca, 'Box', 'on', 'LineWidth', 1, 'Layer', 'top', ...
   'XMinorTick', 'on', 'YMinorTick', 'on', 'XGrid', 'off', 'YGrid', 'on', ...
   'TickDir', 'out', 'TickLength', [.015 .015], 'XLim', x1([1,end]),...
   'FontName', 'avantgarde', 'Fontsize', 10, 'FontWeight', 'normal', ...
   'FontAngle', 'italic');

xlabel('theta (\theta)', 'FontName', 'bookman', 'FontSize', 12, ...
   'FontWeight', 'bold');
ylabel('value(\Psi)', 'FontName', 'helvetica', 'FontSize', 12, ...
   'FontWeight', 'bold', 'FontAngle', 'normal');
title('Cool Plot', 'FontName','palatino', 'FontSize', 18, ...
   'FontWeight', 'bold', 'FontAngle', 'italic', 'Color', [.3 .3 0]);
legh = legend(h, 'blob', 'diff', 'sin(2\theta)', 'tan', 'tan2', 'error',1);
set(legh, 'FontName', 'helvetica', 'FontSize', 8, 'FontAngle', 'italic');

% Create the upper right plot (bar chart)
subplot(222);
bar(rand(10,5), 'stacked');
set(gca, 'Box', 'on', 'LineWidth', .5, 'Layer', 'top', ...
   'XMinorTick', 'on', 'YMinorTick', 'on', 'XGrid', 'on', 'YGrid', 'on', ...
   'TickDir', 'in', 'TickLength', [.015 .015], 'XLim', [0 11], ...
   'FontName', 'helvetica', 'FontSize', 8, 'FontWeight', 'normal', ...
   'YAxisLocation', 'right');
xlabel('bins', 'FontName', 'avantgarde', 'FontSize', 10, ...
   'FontWeight', 'normal');
yH = ylabel('y val (\xi)', 'FontName', 'bookman', 'FontSize', 10, ...
   'FontWeight', 'normal');
set(yH, 'Rotation', -90, 'VerticalAlignment', 'bottom');
title('Bar Graph', 'FontName', 'times-roman', 'FontSize', 12, ...
   'FontWeight', 'bold', 'Color', [0 .7 .7]);

% Create the bottom right plot (pie chart)
subplot(224);
pie([2 4 3 5], {'North', 'South', 'East', 'West'});
tP = get(get(gca, 'Title'), 'Position');
set(get(gca, 'Title'), 'Position', [tP(1), 1.2, tP(3)]);
title('Pie Chart', 'FontName', 'avantgarde', 'FontSize', 12, ...
   'FontWeight', 'bold', 'FontAngle', 'italic', 'Color', [.7 0 .7]);
th = findobj(gca, 'Type', 'text');
set(th, 'FontName', 'bookman', 'FontWeight', 'bold', 'FontAngle', 'italic');

response = fig2plotly(fig,'name','mpg_area_bar_pie');
plotly_url = response.url;

