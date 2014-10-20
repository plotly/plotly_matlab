%%
% This is an example of how to create an errorbar plot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/errorbar.html |errorbar|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Load Fisher data for three varieties of iris
load fisheriris meas;

% Extract the data for each variety
setosa = meas(1:50, :);
virginica = meas(51:100, :);
versicolor = meas(101:150, :);

% Calculate the means and standard deviations for each variety
irisMeans = [mean(setosa); mean(virginica); mean(versicolor)];
irisSTDs =  [std(setosa); std(virginica); std(versicolor)];

% Draw error bar chart with means and standard deviations
figure;
errorbar(irisMeans, irisSTDs, 's');

% Add title and axis labels
title('Comparison of three species in the Fisher Iris data');
xlabel('Species of Iris');
ylabel('Mean size in mm');

% Change the labels for the tick marks on the x-axis
irisSpecies = {'Setosa', 'Virginica', 'Versicolor'};
set(gca, 'XTick', 1:3, 'XTickLabel', irisSpecies);

% Create labels for the legend
irisMeas = {'Sepal length', 'Sepal width', 'Petal length', 'Petal width'};
legend(irisMeas, 'Location', 'Northwest');
