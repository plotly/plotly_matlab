%%
% This is an example of how to produce a uniform lighting across the surfaces in MATLAB®. This lighting is good for viewing faceted surfaces.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/light.html |light|> and <http://www.mathworks.com/help/matlab/ref/lighting.html |lighting|> functions in MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create a grid of x and y points
points = linspace(-2, 0, 20);
[X, Y] = meshgrid(points, -points);

% Define the function Z = f(X,Y)
Z = 2./exp((X-.5).^2+Y.^2)-2./exp((X+.5).^2+Y.^2);

% "flat" lighting is good for faceted surfaces
surf(X, Y, Z); view(30, 30);
shading faceted;
light;
lighting flat;
title('lighting flat', 'FontName', 'Courier', 'FontSize', 14);
