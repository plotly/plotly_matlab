%%
% This is an example of how to create a simple pie chart in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/pie.html |pie|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Load the data for US population by age 1860-2000
load populationAge population groups

% Get the population for each age group for the year 2000 
age2000 = population(15, :);

% Create a pie chart using the pie function -- use age groups as labels
figure;
pie(age2000, groups);

% Add title
title('US population by age for the year 2000');
