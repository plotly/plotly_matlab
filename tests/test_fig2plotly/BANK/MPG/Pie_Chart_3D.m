%%
% This is an example of how to create a 3D pie chart in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/pie3.html |pie3|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create some data
x = [1 3 0.5 2.5 2];

% Create a 3D pie chart using the pie3 function
figure;
explode = [0 1 0 0 0];
pie3(x, explode);

% Add a title
title('Pie3 Chart');
