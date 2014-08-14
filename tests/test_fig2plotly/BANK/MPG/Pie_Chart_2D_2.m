%%
% This is an example of how to create an exploded pie chart in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/pie.html |pie|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Load the data for South American populations
load SouthAmericaPopulations populations countries;

% Calculate the total populations and percentage by country
total = sum(populations);
percent = populations/total;

% Create a pie chart with sections 3 and 6 exploded
figure;
explode = [0 0 1 0 0 1 0 0];
pie(percent, explode, countries);

% Add title
title('South American Population by Country');
