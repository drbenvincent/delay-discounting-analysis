function checkDependencies()

dependencies={...
	'https://github.com/drbenvincent/mcmc-utils-matlab',...
	'https://github.com/altmany/export_fig',...
	'https://github.com/drbenvincent/matjags',...
	'https://github.com/brian-lau/MatlabProcessManager',...
	'https://github.com/brian-lau/MatlabStan'};

originalPath = cd;

% THE ALGORITHM
for url=dependencies
	cloneOrUpdateDependency(url{:});
end

cd(originalPath)
end


function installPath = defineInstallPath()
if isempty(userpath)
	userpath('reset')
end
installPath = userpath;
% Fix the trailing ":" which only sometimes appears
installPath = removeTrailingColon(installPath);
end

function str = removeTrailingColon(str)
if str(end)==':'
	str(end)='';
end
end

function cloneOrUpdateDependency(url)
displayDependencyToCommandWindow(url);
repoName = getRepoNameFromUrl(url);
addpath(fullfile(defineInstallPath(),repoName));
if ~isRepoFolderOnPath(repoName)
	cloneGitHubRepo(url, defineInstallPath());
else
	updateGitHubRepo(defineInstallPath(),repoName);
end
end

function displayDependencyToCommandWindow(url)
weblinkCode = makeWeblinkCode(url);
displayClickableLinkToCommandWindow(url, weblinkCode);
end

function cloneGitHubRepo(repoAddress, installPath)
	try
		cd(installPath)
		command = sprintf('git clone %s.git', repoAddress);
		system(command);
	catch
		error('git clone failed')
	end
end

function onPath = isRepoFolderOnPath(repoName)
	onPath = exist(repoName,'dir')==7;
end

function updateGitHubRepo(installPath,repoName)
try
	cd(fullfile(installPath,repoName))
	system('git pull');
catch
	warning('Unable to update GitHub repository')
end
end

function repoName = getRepoNameFromUrl(url)
[~,repoName] = fileparts(url);
end
