subplot(2,2,1); 
 x = -2.9:0.2:2.9;                                       % Specify the bins to use
 y = randn(5000,1);                                      % Generate 5000 random data points
 hist(y,x);                                              % Draw histogram
 title('Histogram of Gaussian Data');                    % Add title
%Polar Coordinates: Matlab can also plot data in polar coordinates. Try the following code for example plot in polar coordinates
subplot(2,2,2);  
t = linspace(0,2*pi);                                   % Define t
 r = sin(2*t).*cos(2*t);                                 % Define r
 polar(t,r);                                             % Plot data in polar coordinate system
 title('Polar Plot');                                    % Add title
%3-D Plots
%Surface Plots: A surface plot in Matlab takes data in an evenly-spaced x-y grid, with z data at each (x,y) loaction and plots it as a mesh with the regions between the lines of the mesh filled-in. Try using the code below to create a mesh plot similar to the plot at the top of this tutorial.
subplot(2,2,3);  
[X,Y,Z] = peaks(30);                                    % Define X,Y and Z
 surf(X,Y,Z);                                            % Create surface plot
 xlabel('X-axis'), ylabel('Y-axis'), zlabel('Z-axis');   % Label axes
 title('Surface Plot');                                  % Add title
%Filled Contour Plots: Matlab can also be used to contour 3-D data (just like contouring elevation data in a DEM). The code below will contour some example 3-D data.
subplot(2,2,4);  
[X,Y,Z] = peaks;                                        % Define X, Y and Z
 contourf(X,Y,Z,12);                                     % Create filled contour plot with 12 contours
 xlabel('X-axis'), ylabel('Y-axis');                     % Label axes
 title('Filled Contour Plot');                           % Add title