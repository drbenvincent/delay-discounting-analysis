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

%% Print welcome
help_url = 'https://github.com/drbenvincent/delay-discounting-analysis/wiki';
paper_doi = 'doi:10.3758/s13428-015-0672-2';
paper_doi_url = 'http://dx.doi.org/10.3758/s13428-015-0672-2';

fprintf('\n\n\n======================================================================================\n')
fprintf('You are now up and running with:\n')
fprintf('Hierarchical Bayesian estimation and hypothesis testing for delay discounting tasks\n\n')
disp(['More information available in the paper at: ' makeHyperlink(paper_doi, makeWeblinkCode(paper_doi_url))] )
disp(['Help can be found at: ' makeHyperlink(help_url, makeWeblinkCode(help_url))] )
fprintf('======================================================================================\n\n\n')
