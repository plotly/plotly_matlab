%%
% This is an example showing standard colors available in MATLAB® plots.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/plot.html |plot|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Generate some data using the besselj function
x = 0:0.2:10;
y0 = besselj(0,x);
y1 = besselj(1,x);
y2 = besselj(2,x);
y3 = besselj(3,x);
y4 = besselj(4,x);
y5 = besselj(5,x);
y6 = besselj(6,x);

% Plot the lines from the Bessel functions using standard line colors
figure;
plot(x, y0, 'r', x, y1, 'g', x, y2, 'b', x, y3, 'c', ...
    x, y4, 'm', x, y5, 'y', x, y6, 'k');
