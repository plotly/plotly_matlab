
x = linspace(-2*pi,2*pi);
y = linspace(0,4*pi);
[X,Y] = meshgrid(x,y);
Z = sin(X)+cos(Y);

fig = figure;
contour(X,Y,Z)

% PLOTLY 
response = fig2plotly(fig,'name','matlab_meshgrid_contour');
plotly_url = response.url;
