%%
% This is an example of how to create a 3D line plot from a function in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/ezplot.html |ezplot|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create the plot using the parametric functions
% x = cost(t), y = sin(t), and z = sin(5*t) for -pi < t < pi
figure;
ezplot3('cos(t)', 'sin(t)', 'sin(5*t)', [-pi pi]);
