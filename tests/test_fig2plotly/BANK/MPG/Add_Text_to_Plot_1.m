CLASS = {'lineseries','lineseries','text','text','text'}; 

%%
% This is an example of how to add text to a plot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/text.html |text|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Load the points for creating a spline curve
load splineData points x y;

% Plot the points for the spline curve
fig = figure;
plot(points(:,1),points(:,2),':ok');
hold on;

% Plot the spline curve
plot(x, y, 'LineWidth', 2);
axis([.5 7 -.8 1.8]);

% Add a title and axis labels
title('The Convex-Hull Property');
xlabel('x');
ylabel('y');

% Label points 3, 4, & 5 of the spline curve
xt = points(3,1) - 0.05; yt = points(3,2) - 0.1;
text(xt, yt, 'Point 3', 'FontSize',12);

xt = points(4,1) - 0.05; yt = points(4,2) + 0.1;
text(xt, yt, 'Point 4', 'FontSize',12);

xt = points(5,1) + 0.15; yt = points(5,2) - 0.05;
text(6.1,.5, 'Point 5', 'FontSize',12);

response = fig2plotly(fig,'name','mpg_text_plot');
plotly_url = response.url;

