% load count.dat
% n = length(count);
% year = 1990 * ones(1,n);
% month = 4 * ones(1,n);
% day = 18 * ones(1,n);
% hour = 1:n;
% minutes = zeros(1,n);
% xdate = datenum(year,month,day,hour,minutes,minutes);
% figure
% plot(xdate,count)
% datetick('x','HHPM')
% userdata.plotly.dateformat = 'HHPM'; 
% set(gca,'UserData',userdata); 

startDate = datenum('02-01-1962');
endDate = datenum('11-15-2012');
xData = linspace(startDate,endDate,50);
figure
plot(xData,rand(1,50))
datetick('x','yyyy','keeplimits')
userdata.plotly.xdateformat = 'yyyy';
set(gca,'UserData',userdata); 
p = plotlyfigure(gcf); 
plotly(p); 