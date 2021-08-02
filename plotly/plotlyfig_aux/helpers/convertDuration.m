function [converted,type] = convertDuration(duration)
if (strcmpi(duration.Format,'s'))
    converted = seconds(duration);
    type = 'sec';

elseif (strcmpi(duration.Format,'m'))
    converted = minutes(duration);
    type = 'min';

elseif (strcmpi(duration.Format,'h'))
    converted = hours(duration); 
    type = 'hr';

elseif (strcmpi(duration.Format,'d'))
    converted = days(duration); 
    type = 'days';

elseif (strcmpi(duration.Format,'y'))
    converted = years(duration); 
    type = 'yrs';
else
    %no convertion is applied
    converted = duration;
    type = '';
end
end