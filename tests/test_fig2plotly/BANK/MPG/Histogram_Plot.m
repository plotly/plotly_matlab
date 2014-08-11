%%
% This is an example of how to create a histogram plot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/hist.html |hist|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Load nucleotide data
load nucleotideData ncount;

% Create the histogram using the hist function
fig = figure;
hist(ncount);
colormap summer;

% Add a legend
legend('A', 'C', 'G', 'T');

% Add title and axis labels
title('Histogram of nucleotide type distribution');
xlabel('Occurrences');
ylabel('Number of sequence reads');

resp = fig2plotly(fig); 
resp.url 