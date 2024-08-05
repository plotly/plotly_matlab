function output = convertDate(date)
    date = convertToDateTime(date);
    if isDate(date)
        format = "yyyy-MM-dd";
    else
        format = "yyyy-MM-dd HH:mm:ss";
    end
    output = string(date, format);
end

function dt = convertToDateTime(input)
    if isdatetime(input)
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
