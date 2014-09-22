%LINESERIES
subplot(2,2,1)
plot(1:0.1:20,cos(1:0.1:20),'LineStyle','--','LineWidth',2,'Color',[0.9 0.3 0.4]); 
hold on
plot(1:0.1:20,2*sin(1:0.1:20),'LineStyle','--','LineWidth',2,'Color',[0.2 0.9 0.1]); 
hold on
plot(1:0.1:20,3*cos(1:0.1:20),'LineStyle','--','LineWidth',2,'Color',[0.3 0.2 0.4]); 

%BARSERIES
subplot(2,2,2)
y = sin((-pi:pi).^2);
% Put the baseline at y = -0.2
h = bar(y,'BaseValue',0,'FaceColor',[0.9 0.6 0.2]);
% Get a handle to the baseline
hbl = get(h(1),'BaseLine');
% Change to a red dotted line
set(hbl,'Color','red','LineStyle',':')