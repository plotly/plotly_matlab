%%
% This is an example of how to create a 3D quiver plot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/quiver3.html |quiver3|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create a grid of x,y, and z values
[x, y, z] = meshgrid(-0.8:0.2:0.8, -0.8:0.2:0.8, -0.8:0.8:0.8);

% Calculate homogenous turbulence values at each (x,y,z)
u = sin(pi*x).*cos(pi*y).*cos(pi*z);
v = -cos(pi*x).*sin(pi*y).*cos(pi*z);
w = sqrt(2/3)*cos(pi*x).*cos(pi*y).*sin(pi*z);

% Draw a 3 dimensional quiver plot using the quiver3 function
figure;
quiver3(x, y, z, u, v, z);

% Set the axis limits
axis([-1 1 -1 1 -1 1]);

% Add title and axis labels
title('Turbulence Values');
xlabel('x');
ylabel('x');
zlabel('z');
