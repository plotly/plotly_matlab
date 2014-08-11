%%
% This is an example of how to create a 3D plot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/plot3.html |plot3|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Load the spectra data
load spectraData masscharge time spectra;

% Create the 3D plot
figure;
plot3(masscharge, time, spectra);
box on;

% Set the viewing angle and the axis limits
view(26, 42);
axis([500 900 0 22 0 4e8]);

% Add title and axis labels
xlabel('Mass/Charge (M/Z)');
ylabel('Time');
zlabel('Ion Spectra');
title('Extracted Spectra Subset');
