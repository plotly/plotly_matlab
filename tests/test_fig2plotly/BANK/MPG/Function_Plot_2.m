%%
% This is an example of how to create an line plot from a function in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/ezplot.html |ezplot|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create a series of lines for the function f(x,y) = y^2 - x^2 + c
figure;
ezplot('y^2 - x^2 + 4', [-3 3], [-3 3]); hold on;
ezplot('y^2 - x^2 + 2', [-3 3], [-3 3]);
ezplot('y^2 - x^2',     [-3 3], [-3 3]);
ezplot('y^2 - x^2 - 2', [-3 3], [-3 3]);
ezplot('y^2 - x^2 - 4', [-3 3], [-3 3]);

% Adjust the colormap to plot the function in blue
colormap([0 0 1]);
grid on;

% Add title
title('y^2 - x^2 - c = 0 for c = -4, 4');
