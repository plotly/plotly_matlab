%%
% This is an example of how to create a horizontal bar chart in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/barh.html |barh|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create the data for the temperatures and months
temperatures = [40.5 48.3 56.2 65.3 73.9 69.9 71.1 59.5 48.7 35.3 31.7 30.0];
months = {'Dec', 'Nov' 'Oct' 'Sep' 'Aug' 'Jul' 'Jun' 'May' 'Apr' 'Mar' 'Feb' 'Jan'};

% Plot the temperatures on a horizontal bar chart
figure;
barh(temperatures);

% Set the axis limits
axis([0 80 0 13]);

% Add a title
title('Boston Monthly Average Temperature - 2001');

% Change the Y axis tick labels to use the months
set(gca, 'YTickLabel', months);
