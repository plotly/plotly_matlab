%%
% This is an example of how to create an x-axis semilog plot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/semilogx.html |semilogx|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Load the response data
load responseData frequency magnitude;

% Create an x-axis semilog plot using the semilogx function
f = figure;
semilogx(frequency, magnitude);

% Set the axis limits and turn on the grid
axis([min(frequency) max(frequency) -6.5 6.5]);
grid on;

% Add title and axis labels
title('Magnitude Response (dB)');
xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');

fig2plotly(f,'strip',1)
