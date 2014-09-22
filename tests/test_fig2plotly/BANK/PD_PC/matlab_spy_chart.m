fig = figure; 
B = bucky;
spy(B)

% PLOTLY 
p = plotlyfigure(gcf);
plotly(p,false);
plotly_url = p.Response.url; 

