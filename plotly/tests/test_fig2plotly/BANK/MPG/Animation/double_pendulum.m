function dy = double_pendulum(t, y, m, L)
% System of ODEs for a double pendulum (mass m and link length L)
%
% See http://en.wikipedia.org/wiki/Double_pendulum for the differential
% equations

% Copyright 2010 The MathWorks, Inc.

g = 9.81;

theta1 = y(1);       % angle 1
theta2 = y(2);       % angle 2
p1 = y(3);           % momentum
p2 = y(4);           % momentum

% The derivatives
dy(1) = 6/(m*L^2) * (2*p1-3*cos(theta1-theta2)*p2) / ...
   (16-9*cos(theta1-theta2)^2);

dy(2) = 6/(m*L^2)*(8*p2-3*cos(theta1-theta2)*p1) / ...
   (16-9*cos(theta1-theta2)^2);

dy(3) = -1/2*m*L^2*(dy(1)*dy(2)*sin(theta1-theta2)+3*g/L*sin(theta1));

dy(4) = -1/2*m*L^2*(-dy(1)*dy(2)*sin(theta1-theta2)+g/L*sin(theta2));

dy = dy(:);