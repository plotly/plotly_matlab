fig = figure; 
[X,Y,Z] = peaks;
contour(X,Y,Z,20)

% PLOTLY 
response = fig2plotly(fig,'filename','matlab_simple_contour');
plotly_url = response.url;
