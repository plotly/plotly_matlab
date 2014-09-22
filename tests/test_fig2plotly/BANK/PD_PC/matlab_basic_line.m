
x = linspace(-2*pi,2*pi);
y1 = sin(x);
y2 = cos(x);

fig = figure; 
plot(x,y1,x,y2)

% PLOTLY 
p = plotlyfigure(gcf);
plotly(p,false);
plotly_url = p.Response.url; 

