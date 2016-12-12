function checkGitHubDependencies(dependencies)
% This function takes a cell array of url's to hithub repositories, loop through
% them and ensure they exist on the path, or clone them to your local machine.
%
% Example input:
%
% dependencies={...
% 	'https://github.com/drbenvincent/mcmc-utils-matlab',...
% 	'https://github.com/altmany/export_fig'};

assert(iscellstr(dependencies),'Input to function should be a cell array of url''s to github repositories')

% ensure dependencies is a row
if iscolumn(dependencies)
	dependencies = dependencies';
end
assert(isrow(dependencies))

for url=dependencies
	processDependency(url{:});
end

end


function processDependency(url)
displayDependencyToCommandWindow(url);
repoName = getRepoNameFromUrl(url);
if ~isRepoFolderOnPath(repoName)
	targetPath = fullfile(defineInstallPath(),repoName);
	targetPath = removeTrailingColon(targetPath);
	cloneGitHubRepo(url, repoName, targetPath);
else
	updateGitHubRepo(defineInstallPath(),repoName);
end
end

function displayDependencyToCommandWindow(url)
disp( makeHyperlink(url, makeWeblinkCode(url)) )
end

function repoName = getRepoNameFromUrl(url)
[~,repoName] = fileparts(url);
end

function installPath = defineInstallPath()
% installPath will be the Matlab userpath (eg /Users/Username/Documents/MATLAB)
if isempty(userpath)
	userpath('reset')
end
installPath = userpath;
% Fix the trailing ":" which only sometimes appears (or ";" on PC)
installPath = removeTrailingColon(installPath);
end

function str = removeTrailingColon(str)
if str(end)==systemDelimiter()
	str(end)='';
end
end

function onPath = isRepoFolderOnPath(repoName)
	onPath = exist(repoName,'dir')==7;
end

function cloneGitHubRepo(repoAddress, repoName, installPath)
% ensure the folder exists
%targetPath = removeTrailingColon(fullfile(defineInstallPath(),repoName));
ensureFolderExists(installPath);
addpath(installPath);
% do the cloning
originalPath = cd;
try
	cd(defineInstallPath())
	command = sprintf('git clone %s.git', repoAddress)
	[status, cmdout] = system(command)
catch ME
	rethrow(ME)
end
cd(originalPath)
end

function updateGitHubRepo(installPath,repoName)
originalPath = cd;
try
	cd(fullfile(installPath,repoName))
	[status, cmdout] = system('git pull');
catch ME
	rethrow(ME)
	%warning('Unable to update GitHub repository')
end
cd(originalPath)
end



% TODO: Work out how to make this work in Matlab
% function results = exectuteFunctionInPathProvided(func, targetPath)
%     originalPath = cd;
%     cd(targetPath)
%     results = func();
%     cd(originalPath)
% end
