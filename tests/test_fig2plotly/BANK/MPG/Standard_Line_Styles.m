%%
% This is an example showing standard line styles available in MATLAB® plots.
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

% Plot the lines from the Bessel functions using standard line styles
figure;
plot(x, y0, 'r-', x, y1, 'g--', x, y2, 'b:', x, y3, 'k-.');
