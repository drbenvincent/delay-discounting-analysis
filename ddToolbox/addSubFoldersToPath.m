function addSubFoldersToPath()

pathOfThisFunction = mfilename('fullpath');
[currentpath, ~, ~]= fileparts(pathOfThisFunction);
allSubpaths = strsplit( genpath(currentpath) ,':');
blacklist={'.git','.ignore','.graffle'};

pathsToAdd={};
for n=1:numel(allSubpaths)
	if shouldAddThisPath(allSubpaths(1,n),blacklist)
		pathsToAdd{end+1} = allSubpaths{n};
	end
end

display('Temporarily adding toolbox subdirecties to the path: ')
fprintf('\t%s\n',pathsToAdd{:})
addpath( strjoin(pathsToAdd, ':') )
end

function addThisPath = shouldAddThisPath(path,blacklist)
addThisPath = true;
for ignoreStr = blacklist
	if isStringMatch(path,ignoreStr)
		addThisPath=false;
	end
end
end

function matchFound = isStringMatch(str,pattern)
matchFound = any(~cellfun('isempty',strfind(str,char(pattern))));
% 2015a throws error without pattern being a char (ie need char(pattern)).
end
