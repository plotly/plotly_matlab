%%
% This is an example of how to create a surface plot from a function in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/ezsurf.html |ezsurf|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create the plot using the functions
% x = sin(pi*u)*sin(pi*u)*cos(v) ; y = sin(pi*u)*sin(pi*u)*sin(v) ; z = u
% with - 1 < u < 1 and 0 < v < 2*pi
figure;
ezsurf('sin(pi*u)*sin(pi*u)*cos(v)', ...
          'sin(pi*u)*sin(pi*u)*sin(v)', ...
          'u', [-1 1 0 2*pi]);
      
% Change the view angle for the plot
view(135,15);
