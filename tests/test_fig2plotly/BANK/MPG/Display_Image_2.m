%%
% This is an example of how to display a simple image in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/image.html |image|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Load the data for the mandrill image
load mandrill X map;

% Create the image display using the image command
figure;
image(X);

% Use the colormap specified in the image data file
colormap(map);

% Turn the axes off
axis off;

% Add title
title('Mandrill');
