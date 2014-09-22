
x = linspace(-2*pi,2*pi);
y = linspace(0,4*pi);
[X,Y] = meshgrid(x,y);
Z = sin(X)+cos(Y);

fig = figure;
contour(X,Y,Z)

% PLOTLY 
p = plotlyfigure(gcf);
plotly(p,false);
plotly_url = p.Response.url; 

