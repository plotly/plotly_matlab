
% some random points
x = normrnd(5,1,100,1);

% a simple histogram
fig = figure;
hist(x)

% PLOTLY 
response = fig2plotly(fig,'name','matlab_basic_histogram');
plotly_url = response.url;
