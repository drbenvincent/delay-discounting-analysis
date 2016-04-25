function [sucess] = checkDependencies()
% Install dependencies

% See if we have a userpath

if isempty(userpath)
	userpath('reset')
end

installPath = userpath;
installPath = installPath(1:end-1);
originalPath = cd;

dependencies={...
'mcmc-utils-matlab', 'https://github.com/drbenvincent/mcmc-utils-matlab';...
'export_fig', 'https://github.com/altmany/export_fig';...
'matjags', 'https://github.com/drbenvincent/matjags'};

display(dependencies);

try
	sucess = ensureDependenciesExist(installPath, dependencies);
	cd(originalPath)
	sucess = true;
catch
	cd(originalPath)
	sucess = false;
end

display(sucess)
end


function sucess = ensureDependenciesExist( installPath, dependencies )
addpath(installPath)
% check if dependencies exist on the matlab patch
for n=1:size(dependencies,1)
	repoName = dependencies{n,1};
	addpath(fullfile(installPath,repoName))
	if ~isRepoOnPath(repoName)
		address = dependencies{n,2};
		sucess = cloneGitHubRepo(address, installPath);
		addpath(fullfile(installPath,repoName))
	else
		sucess = updateGitHubRepo(installPath,repoName);
		sucess = true;
	end
end

end


function sucess = cloneGitHubRepo(repoAddress, installPath)
	try
		cd(installPath)
		command = sprintf('git clone %s.git', repoAddress);
		system(command);
		sucess = true;
	catch
		sucess = false;
		error('git clone failed')
	end
end

function onPath = isRepoOnPath(repoName)
	onPath = exist(repoName,'dir')==7;
end

function sucess = updateGitHubRepo(installPath,repoName)
try
	cd(fullfile(installPath,repoName))
	display(repoName)
	system('git pull');
	sucess=true;
catch
	sucess = false;
end
end