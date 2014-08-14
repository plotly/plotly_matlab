%%
% This is an example of how to create two overlapping waves in 3 dimension in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/quiver3.html |quiver3|> and <http://www.mathworks.com/help/matlab/ref/fill3.html |fill3|> functions in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create some x data
x = linspace(0, 4*pi, 30);  

% Create two waves to plot
y1 = sin(x);              
y2 = sin(x-pi);           

% Plot the first wave in red and fill with color
u = zeros(size(x));
fig = figure;
hold on; 
fill3(x, y1, u, 'r', 'EdgeColor', 'r', 'FaceAlpha', 0.5); 

% Add arrows for the first wave                      
quiver3(x, u, u, u, y1, u, 0, 'r');      
 
% Plot the first wave in blue and fill with color
fill3(x, u, y2, 'b', 'EdgeColor', 'b', 'FaceAlpha', 0.5);     

% Add the arrows for the second wave
quiver3(x, u, u, u, u, y2, 0, 'b');      
                     
% Use equal axis scaling 
axis equal; 

response = fig2plotly(fig,'name','mpg_overlapping_3D_waves');
plotly_url = response.url;
