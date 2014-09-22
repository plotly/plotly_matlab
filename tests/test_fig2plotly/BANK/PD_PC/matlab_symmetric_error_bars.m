
x = 0:pi/10:pi;
y = sin(x);
e = std(y)*ones(size(x));

fig = figure; 
errorbar(x,y,e)

% PLOTLY 
p = plotlyfigure(gcf);
plotly(p,false);
plotly_url = p.Response.url; 

