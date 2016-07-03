function [env] = ddAnalysisSetUp(varargin)

p = inputParser;
p.FunctionName = mfilename;

p.addParameter('toolboxPath','',@isstr);
p.addParameter('projectPath','',@isstr);
p.addParameter('dataPath','', @isstr)


p.parse(varargin{:});
%parse(p, varargin{:});





%% Do the setup ==================================
cd(p.Results.projectPath)

%% Add toolboxPath to Matlab path
% expand home dir (~) to absolute path
if strncmp(p.Results.toolboxPath, '~', 1)
	toolboxPath = [getenv('HOME') p.Results.toolboxPath(2:end)];
end

if exist(p.Results.toolboxPath,'dir') == 7
	addpath(p.Results.toolboxPath)
else
	error('change the toolboxPath to point to the folder /ddToolbox')
end

%% Add subdirectories to Matlab path
try
	addSubFoldersToPath()
catch
	error('Some error in adding toolbox subpaths')
end

%% Ensure dependencies are installed and up-to-date.
checkDependencies();

%% Import mcmc-utils-matlab package
import mcmc.*

mcmc.setPlotTheme('fontsize',16, 'linewidth',1)


% outputs
env.toolboxPath = p.Results.toolboxPath;
env.projectPath = p.Results.projectPath;
env.dataPath	= p.Results.dataPath;

