%%
% This is an example of how to create a fitted curve with confidence bounds in MATLAB®.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Load the data for x, y, and yfit
load fitdata x y yfit;

% Create a scatter plot of the original x and y data
figure;
scatter(x, y, 'k');

% Plot the fit of the y data
line(x, yfit, 'color', 'k', 'linestyle', '-', 'linewidth', 2);

% Plot the confidence bounds
line(x, yfit + 0.3, 'color', 'r', 'linestyle', '--', 'linewidth', 2);
line(x, yfit - 0.3, 'color', 'r', 'linestyle', '--', 'linewidth', 2);

% Add a legend and axis labels
legend('Data', 'Localized Regression', 'Confidence Intervals', 2);
xlabel('X');
ylabel('Noisy');
