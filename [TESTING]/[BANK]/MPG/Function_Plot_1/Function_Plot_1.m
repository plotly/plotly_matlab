%%
% This is an example of how to create an line plot from a function in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/ezplot.html |ezplot|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create the plot using the lemniscate function f(x,y) = (x^2 + y^2)^2 - x^2 + y^2
figure;
ezplot('(x^2 + y^2)^2 - x^2 + y^2', [-1.1, 1.1], [-1.1, 1.1]);

% Adjust the colormap to plot the function in blue
colormap([0 0 1]);

% Add a multi-line title
title({'Lemniscate Function'; '(x^2 + y^2)^2 - x^2 + y^2'});
