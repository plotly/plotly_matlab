%%
% This is an example of how to display multiple images in a subplot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/image.html |image|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Read the data for the original image
original = imread('ngc6543a.jpg');

% Create the first image display using the image command
figure;
subplot(1, 2, 1);
image(original); 
axis square;

% Add title for first image
title('Original image');

% Create the data for the second image 
heatmap = mean(original, 3);

% Create the second image display using the image command
subplot(1, 2, 2);
image(heatmap);
colormap(hot);
axis square;

% Add title for the second image
title('Intensity Heat Map');
