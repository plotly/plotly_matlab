%%
% This is an example of how to create filled polygons on a plot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/fill.html |fill|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create a yellow triangle
figure;
x = [0.25, 1.0, 1.0];
y = [0.25, 0.25, 1.0];
fill(x, y, 'y');
hold on;

% Create an orange diamond
x = [2.0, 2.25, 2.0, 1.75];
y = [1.25, 1.55, 2.25, 1.5];
c = [1 0.8 0.3];
fill(x, y, c);

% Create a blue rectangle
left = 3.0;
right = left + 0.5;
bottom = 1.0;
top = bottom + 1;
x = [left left right right];
y = [bottom top top bottom];
fill(x, y, 'b');

% Create a purple transparent circle
xc = 3.0; yc = 1.0;
r = 0.5;
x = r*sin(-pi:0.1*pi:pi) + xc;
y = r*cos(-pi:0.1*pi:pi) + yc;
c = [0.6 0 1];
fill(x, y, c, 'FaceAlpha', 0.4);

% Create a light blue star
xc = 1.0; yc = 3.0;
t = (-1/4:1/10:3/4)*2*pi;
r1 = 0.5; r2 = 0.2;
r = (r1+r2)/2 + (r1-r2)/2*(-1).^[0:10];
x = r.*cos(t) + xc;
y = r2 - r.*sin(t) + yc;
c = [0.6 0.8 1.0];
fill(x, y, c);

%  Create a green transparent ellipse
xc = 0.75; yc = 2.5;
x = 0.4*sin(-pi:0.1*pi:pi) + xc;
y = 0.7*cos(-pi:0.1*pi:pi) + yc;
c = [0 0.5 0];
fill(x, y, c, 'FaceAlpha', 0.2);

% Create a red stop sign
t = (1/16:1/8:1)'*2*pi;
x = 0.4*sin(t) + 3;
y = 0.4*cos(t) + 3;
fill(x, y ,'r', 'FaceAlpha', 1);

% Set the axis limits
axis([0 4 0 4]);
axis square;

% Add a title
title('Filled Polygons');
