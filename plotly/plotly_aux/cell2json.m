function str = cell2json(s)
	strList = string(cellfun(@m2json, s, 'un', 0));
	str = sprintf("[%s]", strjoin(strList, ", "));
end
