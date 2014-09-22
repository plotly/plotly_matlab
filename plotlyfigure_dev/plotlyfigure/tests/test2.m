
subplot(2,2,1);
Y = [1, 5, 3;
	3, 2, 7;
	1, 5, 3;
	2, 6, 1];
area(Y)
colormap summer
set(gca,'Layer','top')
title 'Stacked Area Plot'
subplot(2,2,2);
b = bar(-1 + 2*rand(1,20));
title 'My Bar Chart'
ch = get(b,'Children');
base_handle = get(b,'BaseLine');
set(base_handle,'LineWidth',10)
set(base_handle,'LineStyle','--','Color','red')
subplot(2,1,2);
title 'Sinusoidal Line Plot'
plot(0:0.01:10,sin(0:0.01:10),'r','LineWidth',10);
set(gcf,'Color',[0.3 0.9 0.5]);
p = plotlyfigure(gcf);
update(p);
