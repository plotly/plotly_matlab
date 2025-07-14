function str = struct2json(s)
    if isscalar(s)
        str = oneStruct2json(s);
    else
        str = arrayfun(@oneStruct2json,s);
        str = sprintf("[%s]",strjoin(str,", "));
    end
end

function str = oneStruct2json(s)
    f = fieldnames(s);
    strList = cellfun(@(x) sprintf('"%s" : %s', x, m2json(s.(x))), f, 'un', 0);
    str = sprintf("{%s}", strjoin(strList, ", "));
end
