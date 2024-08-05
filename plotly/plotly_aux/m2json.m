function valstr = m2json(val)
    if isstruct(val)
        valstr = struct2json(val);
    elseif iscell(val)
        valstr = cell2json(val);
    elseif isa(val, "numeric")
        sz = size(val);
        numDigits = max(arrayfun(@getPrecision, val));
        if isa(val,"single")
            numDigits = min(7, numDigits);
        else
            numDigits = min(15, numDigits);
        end
        fmt = sprintf("%%.%ig", numDigits);
        if sum(sz>1)>1 % 2D or higher array
            valsubstr = strings(1, sz(1));
            for i = 1:sz(1)
                formattedRowVal = arrayfun(@(x) sprintf(fmt, x), val(i,:));
                valsubstr(i) = strjoin(formattedRowVal, ",");
                valsubstr(i) = "[" + valsubstr(i) + "]";
            end
            valstr = strjoin(valsubstr, ",");
        else
            valstr = arrayfun(@(x) sprintf(fmt, x), val);
            valstr = strjoin(valstr, ",");
        end
        if length(val)>1
            valstr = "[" + valstr + "]";
        elseif isempty(val)
            valstr = "[]";
        end
        valstr = strrep(valstr,"-Inf", "null");
        valstr = strrep(valstr, "Inf", "null");
        valstr = strrep(valstr, "NaN", "null");
    elseif ischar(val)
         [r, ~] = size(val);
         % We can't use checkescape() if we have ['abc'; 'xyz']
         if r > 1
             valstr = cell2json(cellstr(val));
         else
             val = checkescape(val); % add escape characters
             valstr = sprintf('"%s"', val);
         end
    elseif islogical(val)
        if val
            valstr = "true";
        else
            valstr = "false";
        end
    elseif isdatetime(val)
        valstr = m2json(convertDate(val));
    elseif isstring(val)
        if isscalar(val)
            fh = @char;
        else
            fh = @cellstr;
        end
        valstr = m2json(fh(val));
    else
        valstr = "";
        warning("Failed to m2json encode class of type: %s", class(val));
    end
end

function numDigits = getPrecision(val)
    numDigits = strlength(sprintf("%.15g", val));
end
