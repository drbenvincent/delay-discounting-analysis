function delimiter = systemDelimiter()
if ismac
		delimiter = ':';
	elseif ispc
		delimiter = ';';
end
end