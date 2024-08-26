function str = struct2json(s)
    f = fieldnames(s);
    strList = cellfun(@(x) sprintf('"%s" : %s', x, m2json(s.(x))), f, 'un', 0);
    str = sprintf("{%s}", strjoin(strList, ", "));
end
