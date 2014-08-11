%%
% This is an example of how to create a vertical bar chart in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/bar.html |bar|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create data for childhood disease cases
measles = [38556 24472 14556 18060 19549 8122 28541 7880 3283 4135 7953 1884];
mumps = [20178 23536 34561 37395 36072 32237 18597 9408 6005 6268 8963 13882];
chickenPox = [37140 32169 37533 39103 33244 23269 16737 5411 3435 6052 12825 23332];

% Create a vertical bar chart using the bar function
fig = figure;
bar(1:12, [measles' mumps' chickenPox'], 1);

% Set the axis limits
axis([0 13 0 40000]);

% Add title and axis labels
title('Childhood diseases by month');
xlabel('Month');
ylabel('Cases (in thousands)');

% Add a legend
legend('Measles', 'Mumps', 'Chicken pox');

response = fig2plotly(fig,'name','mpg_vertical_bar');
plotly_url = response.url;

