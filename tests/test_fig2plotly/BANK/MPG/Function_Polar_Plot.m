%%
% This is an example of how to create a polar plot from a function in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/ezpolar.html |ezpolar|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create the plot using the function r(t) = 1 + cos(t)*sin(t)^2
figure;
ezpolar('1+cos(t)*sin(t)^2');
