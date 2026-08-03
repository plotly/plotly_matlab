function str = cell2json(s)
	strList = cellfun(@(x) char(m2json(x)), s, 'un', 0);
	str = sprintf("[%s]", strjoin(strList, ", "));
end
