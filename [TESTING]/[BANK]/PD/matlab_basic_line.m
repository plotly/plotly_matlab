
x = linspace(-2*pi,2*pi);
y1 = sin(x);
y2 = cos(x);

fig = figure; 
plot(x,y1,x,y2)

% PLOTL Y
response = fig2plotly(fig,'name','matlab_basic_line');
plotly_url = response.url;
