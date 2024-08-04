function valstr = m2json(val)
    if isstruct(val)
        valstr = struct2json(val);
    elseif iscell(val)
        valstr = cell2json(val);
    elseif isa(val, "numeric")
        sz = size(val);
        if isa(val,"single")
            precision = "7";
        else
            precision = "15";
        end
        fmt = "%." + precision + "g,";
        if length(find(sz>1))>1 % 2D or higher array
            valstr = "";
            for i = 1:sz(1)
                valsubstr = sprintf(fmt, val(i,:));
                valsubstr = valsubstr(1:(end-1));
                valstr = valstr + ", [" + valsubstr + "]";
            end
            valstr = valstr(3:end); % trail leading commas
        else
            valstr = [sprintf(fmt, val)];
            valstr = valstr(1:(end-1));
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
