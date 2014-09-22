fig = figure;
plot([1,2,3], [10,20,30]);
txt = {'first line', 'second line'};
xlabel(txt);
ylabel(txt);
text(2, 20, txt);
title(txt);

% PLOTLY 
p = plotlyfigure(gcf);
plotly(p,false);
plotly_url = p.Response.url; 

