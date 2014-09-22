% subplot(2,1,1); 
% plot(1:10,'LineWidth',10,'Color',[0.2 0.2 0.6]); 
% t = title('MY DATA'); 
% set(t,'FontWeight','bold','FontSize',20); 
% grid on; 
% set(gca,'LineWidth',1.5); 
% 
% subplot(2,2,3); 
% plot(1:10,'LineWidth',10,'Color',[0.5 0.6 0.1]); 
% t = title('MY DATA'); 
% set(t,'FontWeight','bold','FontSize',20); 
% grid on; 
% set(gca,'LineWidth',1.5); 
% 
% 
% subplot(2,2,4); 
% plot(1:10,'LineWidth',10,'Color',[0.5 0.2 0.7]); 
% t = title('MY DATA'); 
% set(t,'FontWeight','bold','FontSize',20); 
% grid on; 
% set(gca,'LineWidth',1.5); 
% 
% p = plotlyfigure(gcf); 
%plotly(p); 


x = (1:30);
y = 1:30;
r = 1000*(1:30);
c = randi(10, size(x));
p = plotlyfigure; 

s = scatter(x, y, r, c, 'filled', 'MarkerEdgeColor', 'k');
% g = get(s,'Children'); 

% for i = 1:length(g)
%     set(g(i),'CDataMap','direct'); 
% end


