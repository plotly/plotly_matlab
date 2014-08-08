%%
% This is an example of how to create a 3D ribbon plot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/ribbon.html |ribbon|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create a grid of x and y points
[x, y] = meshgrid(-2:0.2:2,-2:0.2:2);

% Calculate the response values at each point
R = (1./(x.^2+(y-1).^2).^(1/2)) - (1./(x.^2+(y+1).^2).^(1/2));

% Create a ribbon point using the ribbon function
figure;
ribbon(R);

% Add title and axis labels
title('Response');
xlabel('x');
ylabel('y');
zlabel('z');
