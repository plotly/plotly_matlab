CLASS = {'image'}; 


%%
% This is an example of how to add a horizontal colorbar to a plot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/colorbar.html |colorbar|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Load spine data
load spine X;

% Create an image plot of the spine data
fig = figure;
imagesc(X);
colormap bone;

% Add a horizontal colorbar to the bottom of the plot
colorbar('SouthOutside');
axis square;

response = fig2plotly(fig,'name','mpg_horizontal_colorbar');
plotly_url = response.url;
