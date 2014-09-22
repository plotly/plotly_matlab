z = rand(50)*4+10;
fig = figure;

colormap('hot');
imagesc(z);
colorbar;

% PLOTLY 
p = plotlyfigure(gcf);
plotly(p,false);
plotly_url = p.Response.url; 

