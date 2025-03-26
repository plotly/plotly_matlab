function [converted,type] = convertDuration(duration)
    switch (duration.Format)
        case 's'
            converted = seconds(duration);
            type = 'sec';
        case 'm'
            converted = minutes(duration);
            type = 'min';
        case 'h'
            converted = hours(duration);
            type = 'hr';
        case 'd'
            converted = days(duration);
            type = 'days';
        case 'y'
            converted = years(duration);
            type = 'yrs';
        otherwise
            % no conversion is applied
            converted = duration;
            type = '';
    end
end
