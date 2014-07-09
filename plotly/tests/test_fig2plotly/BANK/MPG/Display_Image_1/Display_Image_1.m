%%
% This is an example of how to display a simple image in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/image.html |image|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Load the data for the North Atlantic image
load NAimage lng lat naimg;

% Create the image display using the image command
fig = figure;
image(lng, lat, naimg);

% Turn the axes off
axis off;

% Add title
title('North Atlantic');

fig2plotly(fig); 