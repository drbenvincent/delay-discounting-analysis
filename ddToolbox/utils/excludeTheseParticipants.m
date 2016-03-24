function fnamesWhiteList = excludeTheseParticipants(fnames, exludeList)
% take a cell array of strings and remove entries in excludeList

count=1;
for fCount = 1:numel(fnames)
	nameOnWhiteList=false;
	for eCount = 1:numel(exludeList)
		if strcmp(fnames{fCount}, exludeList{eCount})
			nameOnWhiteList=true;
			continue
		end
	end
	if ~nameOnWhiteList
			% add to new list
			fnamesWhiteList{count} = fnames{fCount};
			count=count+1;
		end
end
return