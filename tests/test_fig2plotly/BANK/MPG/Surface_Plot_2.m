%%
% This is an example of how to create a surface plot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/surf.html |surf|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Generate points for a cylinder with profile 2 + sin(t)
t = 0:pi/50:2*pi;
[x, y, z] = cylinder(2+sin(t));

% Create a surface plot using the surf function
fig = figure;
surf(x, y, z, 'LineStyle', 'none', 'FaceColor', 'interp');
colormap('summer');

% Turn off the axis and the grid
axis('square', 'off');
grid('off');

response = fig2plotly(fig,'name','mpg_surface_plot');
plotly_url = response.url;
