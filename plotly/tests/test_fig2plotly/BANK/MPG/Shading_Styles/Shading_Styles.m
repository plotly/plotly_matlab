%%
% This is an example of how to change color shading style for surface and patch objects in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/shading.html |shading|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create a grid of x and y points
points = linspace(-2, 0, 20);
[X, Y] = meshgrid(points, -points);

% Define the function Z = f(X,Y)
Z = 2./exp((X-.5).^2+Y.^2)-2./exp((X+.5).^2+Y.^2);

% Faceted Shading
subplot(2, 2, 1);
surf(X, Y, Z); view(30, 30);
shading faceted;
title('Faceted Shading');

% Flat Shading
subplot(2, 2, 2);
surf(X, Y, Z); view(30, 30);
shading flat;
title('Flat Shading');

% Interpolated Shading
subplot(2, 2, 3);
surf(X, Y, Z); view(30, 30);
shading interp;
title('Interpolated Shading');

% Shading Commands
subplot(2, 2, 4, 'Visible', 'off');
text(0, .5, sprintf('%s\n%s\n%s', ...
    'shading faceted', 'shading flat', 'shading interp'), ...
    'VerticalAlignment', 'middle', ...
    'FontName', 'Courier New', ...
    'FontWeight', 'bold', ...
    'FontSize', 12);
