%%
% This is an example of how to create a surface plot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/surf.html |surf|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create a grid of x and y points
points = linspace(-2, 2, 40);
[X, Y] = meshgrid(points, points);

% Define the function Z = f(X,Y)
Z = 2./exp((X-.5).^2+Y.^2)-2./exp((X+.5).^2+Y.^2);

% Create the surface plot using the surf command
fig = figure;
surf(X, Y, Z);

response = fig2plotly(fig,'name','mpg_surface_plot');
plotly_url = response.url;

