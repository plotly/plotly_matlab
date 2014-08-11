
fig = figure; 
load seamount
s = 10;
c = linspace(1,10,length(x));
scatter(x,y,s,c)
zoom(2)

% PLOTLY 
response = fig2plotly(fig, 'name', 'matlab_seamount_scatter');
plotly_url = response.url;
