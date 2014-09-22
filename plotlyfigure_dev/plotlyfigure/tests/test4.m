p = plotlyfigure;

subplot(2,1,2);

a = area(rand(10,10));

for n = 1:length(a)
    ac = get(a(n),'Children');
    colormap bone
    set(ac,'Marker','*', 'MarkerEdgeColor',[rand rand rand],'LineWidth',3);
end

subplot(2,2,1);
s = stem(rand(1,10));
set(s,'LineWidth',3,'Color',[0.2 0.5  0.6],'MarkerEdgeColor',[0.4 0.2 0.1]);


subplot(2,2,2);
DAT = -1+2*rand(1,10); 
b = bar(DAT);


set(b,'FaceColor',[0.5 0.2 0.4],'EdgeColor',[0.2 0.2 0.1],'LineWidth',2); 
baseline = get(b,'BaseLine');
set(baseline,'LineWidth',5,'Color',[0 0.2 0.3],'LineStyle','--');

%update(p); 

%plotly(p); 

%plotly(p);
