
fig = figure; 
load seamount
s = 10;
c = linspace(1,10,length(x));
scatter(x,y,s,c)
zoom(2)

% PLOTLY 
p = plotlyfigure(gcf);
plotly(p,false);
plotly_url = p.Response.url; 

