function ddAnalysisSetUp()

initialDir = cd;

full = mfilename('fullpath');
[toolboxPath, ~] = fileparts(full);

% p = inputParser;
% p.FunctionName = mfilename;
% 
% p.addParameter('projectPath','',@isstr);
% p.addParameter('dataPath','', @isstr)
% 
% 
% p.parse(varargin{:});


%% Do the setup ==================================
cd(toolboxPath)

% Add subdirectories to Matlab path
try
	addSubFoldersToPath()
catch
	error('Some error in adding toolbox subpaths')
end

% Ensure dependencies are installed and up-to-date.
dependencies={...
	'https://github.com/drbenvincent/mcmc-utils-matlab',...
	'https://github.com/altmany/export_fig',...
	'https://github.com/drbenvincent/matjags',...
	'https://github.com/brian-lau/MatlabProcessManager',...
	'https://github.com/brian-lau/MatlabStan'};
checkGitHubDependencies(dependencies);

% Import mcmc-utils-matlab package
import mcmc.*
mcmc.setPlotTheme('fontsize',16, 'linewidth',1)

% % outputs
% env.toolboxPath = toolboxPath;
% env.projectPath = p.Results.projectPath;
% env.dataPath	= p.Results.dataPath;

cd(initialDir)