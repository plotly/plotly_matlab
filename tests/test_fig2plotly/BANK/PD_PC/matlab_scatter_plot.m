
% Load undersea elevation data
load seamount x y z;

% Create a scatter plot using the scatter function
fig = figure;
scatter(x, y, 10, z);

% Add title and axis labels
title('Undersea Elevation');
xlabel('Longitude');
ylabel('Latitude');

% PLOTLY 
p = plotlyfigure(gcf);
plotly(p,false);
plotly_url = p.Response.url; 
