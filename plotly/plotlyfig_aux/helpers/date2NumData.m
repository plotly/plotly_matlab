function numData = date2NumData(dateData)
	numData = dateData;

	if isduration(dateData) || isdatetime(dateData)
		numData = datenum(dateData);
	end
end