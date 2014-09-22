a = get(gcf,'Children');
userdata.plotly.xdateformat = 'yyyy'; 
set(a(1),'UserData',userdata);
userdate.plotly.xdateformat = 'ddmmmyy';
set(a(2),'UserData',userdata);
set(a(3),'UserData',userdata);
p = plotlyfigure(gcf); 