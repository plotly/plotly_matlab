p = plotlyfigure; 

subplot(2,2,1);
s1 = stem(rand(1,10),'LineWidth',2,'Color',[0.2 0.8 0.3]); 
subplot(2,2,3); 
s2 = stem(rand(1,10),'LineWidth',2,'Color',[0.1 0.4 0.8]); 
subplot(1,2,2);
s3 = stem(rand(1,10),'LineWidth',2,'Color',[0.9 0.1 0.8]); 

update(p); 
plotly(p); 
