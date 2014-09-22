fig = figure; 
[X,Y,Z] = peaks;
contour(X,Y,Z,20)

% PLOTLY 
p = plotlyfigure(gcf);
plotly(p,false);
plotly_url = p.Response.url; 

