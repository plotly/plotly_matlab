%%
% This is an example of how to create an line plot with legend in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/plot.html |plot|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Load data for the stock indices
load IndexData dates values series;

% Plot the stock index values versus time
figure;
plot(dates, values);

% Use dateticks for the x axis
datetick('x');

% Add title and axis labels
xlabel('Date');
ylabel('Index Value');
title ('Relative Daily Index Closings');

% Add a legend in the top, left corner
legend(series, 'Location', 'NorthWest');
