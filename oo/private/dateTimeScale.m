function data = dateTimeScale(a, xaxis, yaxis,data)


if strcmp(xaxis.type, 'date')
    
   %rescale data
   
   x_range = a.XLim(2)-a.XLim(1);
   x_start = a.XLim(1);
   
   xaxis_range = xaxis.range(2)-xaxis.range(1);
   xaxis_start = xaxis.range(1);
   
   data.x = (data.x - x_start)* xaxis_range/x_range + xaxis_start;
    
end

if strcmp(yaxis.type, 'date')
    
   %rescale data
   
   y_range = a.YLim(2)-a.YLim(1);
   y_start = a.YLim(1);
   
   yaxis_range = yaxis.range(2)-yaxis.range(1);
   yaxis_start = yaxis.range(1);
   
   data.x = (data.y - y_start)* yaxis_range/y_range + yaxis_start;
    
end


end