function output = convertDate(date)
    date = convertToDateTime(date);
    if isDate(date)
        format = 'yyyy-mm-dd';
    else
        format = 'yyyy-mm-dd HH:MM:SS';
    end
    if is_octave()
        output = sprintf('%04d-%02d-%02d', year(date), month(date), day(date));
        if ~isDate(date)
            output = sprintf('%s %02d:%02d:%02d', output, ...
                hour(date), minute(date), round(second(date)));
        end
    else
        output = datestr(date, format);
    end
end

function dt = convertToDateTime(input)
    if isa(input, "datetime")
        dt = input;
        return
    elseif isnumeric(input)
        % Assume input is a datenum
        dt = datetime(input, 'ConvertFrom', 'datenum');
    elseif ischar(input) || isstring(input)
        % Assume input is a date string
        dt = datetime(input);
    else
        error('Unsupported date type');
    end
end

function tf = isDate(dt)
    tf = all([hour(dt), minute(dt), second(dt)] == 0);
end
