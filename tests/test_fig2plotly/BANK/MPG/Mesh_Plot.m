%%
% This is an example of how to create a 3D mesh plot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/mesh.html |mesh|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Load the error data
load errorData x y errors

% Create a mesh plot using the mesh function
figure;
mesh(x, y, errors);

% Set the view angle
view(150, 50);

% Add title and axis labels
title('Error at the Given Data Sites');
xlabel('x');
ylabel('y');
zlabel('Error');
