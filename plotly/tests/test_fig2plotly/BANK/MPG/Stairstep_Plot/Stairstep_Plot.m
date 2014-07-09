%%
% This is an example of how to create a stair-step plot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/stairs.html |stairs|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Load data on beak length
load beaksData beaks;

% Calculate histograms for the beak data
minBeak = min(beaks);
maxBeak = max(beaks);
nbins = minBeak:0.2:maxBeak;
[nB, xB] = hist(beaks, nbins);

% Create a stair plot of beak sizes
figure;
stairs(xB, nB/sum(nB), 'b');

% Add title and axis labels
title('Ground finch beak sizes');
xlabel('Beak size in mm');
ylabel('Fraction of birds with beak size');
