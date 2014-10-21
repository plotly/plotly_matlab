
[X,Y,Z] = peaks;
fig = figure; 
contour(X,Y,Z,20)

% PLOTLY 
response = fig2plotly(fig,'filename','matlab_contour_subplots');
plotly_url = response.url; 
