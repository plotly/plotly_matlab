%%
% This is an example of how to create a mesh plot from a function in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/ezmesh.html |ezmesh|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create the mesh plot using the function f(x,y) = y^2 - x^2
figure;
ezmesh('y^2 - x^2', [-3 3], [-3 3]);
