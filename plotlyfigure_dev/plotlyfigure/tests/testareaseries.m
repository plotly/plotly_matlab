for n = 1:10
    subplot(5,2,n)
    area(rand(10,20))
    grid on
    title(['areaplot' num2str(n)]);
end

p = plotlyfigure(gcf); 
plotly(p); 

%plotly low level edits
for n = 1:length(p.data)
    p.data{n}.opacity = n/length(p.data); 
end

%vs.... 
