%%
% This is an example of how to create a rose plot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/rose.html |rose|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Load sunspot data
load sunspotData sunspot;

% Create a rose plot with 24 sectors
figure;
rose(sunspot, 24);

% Add title
title('Sunspot Frequency');
