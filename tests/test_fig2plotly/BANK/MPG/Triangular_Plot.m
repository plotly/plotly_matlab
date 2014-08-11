%%
% This is an example of how to create a triangular plot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/triplot.html |triplot|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create a set of points representing a point cloud
numpts = 192;
t = linspace( -pi, pi, numpts+1 )';
r = 0.1 + 5*sqrt( cos( 6*t ).^2 + (0.7).^2 );
x = r.*cos(t);
y = r.*sin(t);

% Construct a Delaunay Triangulation of the point set
dt  = DelaunayTri(x,y);
tri = dt(:,:);

% Create a triangle plot of the Delauney Triangulation
fig = figure;
triplot(tri,x,y);
axis equal;

% Add title and axis labels
title('Curve reconstruction from a point cloud');
xlabel('x');
ylabel('y');

response = fig2plotly(fig,'name','mpg_triangular_plot');
plotly_url = response.url;

