%%
% This is an example of how to create a 2D quiver plot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/quiver.html |quiver|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create a grid of x and y points
[x, y] = meshgrid(-2:.2:2);

% Create the function z(x,y) and its gradient
z = x.*exp(-x.^2 - y.^2);
[dx, dy] = gradient(z, .2, .2);

% Create a contour plot of x, y, and z using the contour function
figure;
contour(x,y,z);
hold on;

% Create a quiver plot of x, y, and the gradients using the quiver function
q = quiver(x, y, dx, dy);

% Set the axis limits
xlim([-2 2]);
ylim([-2 2]);

% Add title and axis labels
title('x*exp(-x^2-y^2)');
xlabel('x');
ylabel('x');
