fig = figure; 
B = bucky;
spy(B)

% PLOTLY 
response = fig2plotly(fig,'filename','matlab_spy_chart');
plotly_url = response.url;
