z = rand(50)*4+10;
fig = figure;

colormap('hot');
imagesc(z);
colorbar;

% PLOTLY 
response = fig2plotly(fig,'filename','matlab_basic_heatmap');
plotly_url = response.url;
