function addSubFoldersToPath()
blacklist={'.git','.ignore','.graffle'}; % TODO: inject this rather than define it here
allSubpaths = getAllSubpaths();
pathsToAdd = filterPaths(allSubpaths,blacklist);
add2path(pathsToAdd);
end

function allSubpaths = getAllSubpaths()
    pathOfThisFunction = mfilename('fullpath');
    [currentpath, ~, ~]= fileparts(pathOfThisFunction);
	allSubpaths = strsplit(genpath(currentpath), systemDelimiter());
end

function add2path(pathsToAdd)
    disp('Temporarily adding toolbox subdirecties to the path: ')
    fprintf('\t%s\n',pathsToAdd{:})
    addpath( strjoin(pathsToAdd, systemDelimiter()) )    
end

% TODO: should be able to filter using some kind of set operation, rather than having these 3 functions below
function pathsToAdd = filterPaths(allSubpaths,blacklist)
    pathsToAdd={};
    for n=1:numel(allSubpaths)
    	if shouldAddThisPath(allSubpaths(1,n),blacklist)
    		pathsToAdd{end+1} = allSubpaths{n};
    	end
    end    
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
if verLessThan('matlab','9.1')
    matchFound = any(~cellfun('isempty',strfind(str,char(pattern))));
else
    matchFound = any(~cellfun('isempty',strfind(str,pattern)));
end
end
