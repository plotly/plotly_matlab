
y = [1, 5, 3;
     3, 2, 7;
     1, 5, 3;
     2, 6, 1];
 
fig = figure; 
area(y)

% PLOTLY 
p = plotlyfigure(gcf);
plotly(p,false);
plotly_url = p.Response.url; 

