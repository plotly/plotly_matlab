%%
% This is an example of how to create an area plot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/area.html |area|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Load population data
load PopulationAge years population groups;

% Create the area plot using the area function
fig = figure;
area(years, population/1000000);
colormap winter;

% Add a legend
legend(groups, 'Location', 'NorthWest');

% Add title and axis labels
title('US Population by Age (1860 - 2000)');
xlabel('Years');
ylabel('Population in Millions');

response = fig2plotly(fig,'name','mpg_area_plot');
plotly_url = response.url;
