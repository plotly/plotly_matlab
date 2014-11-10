data.yy = [1:2:100];
data.tt = 1:50;
g = plotlygrid(data, 'filename', ['gridtest' num2str(floor(100*rand))]);
g.plotly; 