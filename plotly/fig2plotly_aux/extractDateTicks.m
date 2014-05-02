function [start, finish, t0, tstep] = extractDateTicks(tick_labels, ticks)

[start, finish, t0, tstep] = deal(zeros(0,0));

num_ticks = size(tick_labels,1);

if num_ticks<2
    return
end

date_nums = zeros(num_ticks,1);
dates_registered = 0;
for i=1:num_ticks
    try
        n=datenum(tick_labels(i,:));
    catch
        n=[];
        if num_ticks==numel(ticks)
            [y,mo,d,h,mi,s]=datevec(ticks(i));
            if y==str2num(tick_labels(i,:))
                n=datenum([y,mo,d,h,mi,s]);
            end
        end
    end
    
    if numel(n)>0
        dates_registered=dates_registered+1;
        date_nums(i) = n;
    end
    
end



if dates_registered==num_ticks
    %display('these are dates!')
    millis_from_epoch = zeros(num_ticks,1);
    for i=1:num_ticks
        millis_from_epoch(i) = (date_nums(i)-datenum(1970,1,1))*1000*60*60*24;
    end
    
    
    start = millis_from_epoch(1);
    finish = millis_from_epoch(end);
    t0 = millis_from_epoch(1);
    tstep = millis_from_epoch(2)-millis_from_epoch(1);
    
end



end