CLASS = {'scatterseries'}; 

%%
% This is an example of how to add a vertical colorbar to a plot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/colorbar.html |colorbar|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Load sea elevation data
load seamount x y z;

% Create a scatter plot of the data
fig = figure;
scatter(x, y, 10, z, 'filled');

% Add title and axis labels
title('Undersea Elevation');
xlabel('Longitude');
ylabel('Latitude');

% Add a vertical color bar - default position is to the right of the plot
colorbar;

response = fig2plotly(fig,'name','mpg_vertical_colorbar');
plotly_url = response.url;
