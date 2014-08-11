%%
% This is an example of how to create a polar plot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/polar.html |polar|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create data for the function
t = 0:0.01:2*pi;
r = abs(sin(2*t).*cos(2*t));

% Create a polar plot using the function polar
figure;
polar(t, abs(sin(2*t).*cos(2*t)));

% Add a title
title('abs(sin(2t)*cos(2t))');
