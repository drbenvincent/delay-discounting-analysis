function T = ensureColumnsPresentInTable(T, nameValuePairs)
assert(istable(T))
assert(iscell(nameValuePairs))

for n = 1:2:numel(nameValuePairs)-1
	colName = nameValuePairs{n};
	val = nameValuePairs{n+1};
	if ~isColumnPresent(T, colName)
		newColumn = table(val.*ones( height(T), 1),...
			'VariableNames',{colName});
		T = [T newColumn];
	end
end
end

function isPresent = isColumnPresent(table, columnName)
isPresent = sum(strcmp(table.Properties.VariableNames,columnName))~=0;
end