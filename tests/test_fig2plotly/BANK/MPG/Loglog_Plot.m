%%
% This is an example of how to create a log-log plot in MATLAB®.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/loglog.html |loglog|> function in the MATLAB® documentation.
%
% Go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012 The MathWorks, Inc.

% Create a set of values for the damping factor
zeta = [0.01 .02 0.05 0.1 .2 .5 1 ];

% Define a color for each damping factor
colors = ['r' 'g' 'b' 'c' 'm' 'y' 'k'];

% Create a range of frequency values equally spaced logarithmically
w = logspace(-1, 1, 1000);

% Plot the gain vs. frequency for each of the seven damping factors
figure;
for i = 1:7
    a = w.^2 - 1;
    b = 2*w*zeta(i);
    gain = sqrt(1./(a.^2 + b.^2));
    loglog(w, gain, 'color', colors(i), 'linewidth', 2);
    hold on;
end

% Set the axis limits
axis([0.1 10 0.01 100]);

% Add a title and axis labels
title('|G|(\omega) vs \omega');
xlabel('\omega');
ylabel('|G|(\omega)');

% Turn the grid on
grid on;
