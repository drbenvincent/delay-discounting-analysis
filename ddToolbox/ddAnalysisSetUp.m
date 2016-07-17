function [env] = ddAnalysisSetUp(varargin)


full = mfilename('fullpath');
[toolboxPath, ~] = fileparts(full);

p = inputParser;
p.FunctionName = mfilename;

%p.addParameter('toolboxPath','',@isstr);
p.addParameter('projectPath','',@isstr);
p.addParameter('dataPath','', @isstr)


p.parse(varargin{:});
%parse(p, varargin{:});





%% Do the setup ==================================
cd(p.Results.projectPath)

%% Add toolboxPath to Matlab path
% % expand home dir (~) to absolute path
% if strncmp(p.Results.toolboxPath, '~', 1)
% 	toolboxPath = [getenv('HOME') p.Results.toolboxPath(2:end)];
% end

% TODO: this is now redundant ?
% if exist(toolboxPath,'dir') == 7
% 	addpath(p.Results.toolboxPath)
% else
% 	error('change the toolboxPath to point to the folder /ddToolbox')
% end

%% Add subdirectories to Matlab path
try
	addSubFoldersToPath()
catch
	error('Some error in adding toolbox subpaths')
end

%% Ensure dependencies are installed and up-to-date.
dependencies={...
	'https://github.com/drbenvincent/mcmc-utils-matlab',...
	'https://github.com/altmany/export_fig',...
	'https://github.com/drbenvincent/matjags',...
	'https://github.com/brian-lau/MatlabProcessManager',...
	'https://github.com/brian-lau/MatlabStan'};
checkGitHubDependencies(dependencies);

%% Import mcmc-utils-matlab package
import mcmc.*

mcmc.setPlotTheme('fontsize',16, 'linewidth',1)


% outputs
env.toolboxPath = toolboxPath;
env.projectPath = p.Results.projectPath;
env.dataPath	= p.Results.dataPath;

