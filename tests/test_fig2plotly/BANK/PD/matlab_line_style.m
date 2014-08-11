
x = 0:pi/10:2*pi;
y1 = sin(x);
y2 = sin(x-0.25);
y3 = sin(x-0.5);

fig = figure;
plot(x,y1,'g',x,y2,'b--o',x,y3,'c*')

response = fig2plotly(fig,'name','matlab_line_style');
plotly_url = response.url;
