%%
% This is an example of how to create a contour plot from a function in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/ezcontourf.html |ezcontourf|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create the contour plot using the function f(x,y) = sin(3*x)*cos(x+y)
figure;
ezcontourf('sin(3*x)*cos(x+y)', [0, 3, 0, 3]);

% Change the default colormap to 'spring'
colormap('spring');
