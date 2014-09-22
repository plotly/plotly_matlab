load count.dat;
y = mean(count,2);
e = std(count,1,2);
p = plotlyfigure; 
errorbar(y,e,'xr')
update(p); 
plotly(p); 