
y = [1, 5, 3;
     3, 2, 7;
     1, 5, 3;
     2, 6, 1];
 
fig = figure; 
area(y)

response = fig2plotly(fig,'name','matlab_basic_area');
plotly_url = response.url;
