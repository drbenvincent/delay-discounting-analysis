function ddAnalysisSetUp()

initialDir = cd;

full = mfilename('fullpath');
[toolboxPath, ~] = fileparts(full);

%% Do the setup
cd(toolboxPath)

% Add subdirectories to Matlab path
addSubFoldersToPath()

% Ensure dependencies are installed and up-to-date.
fid = fopen('dependencies.txt');
dependencies = textscan(fid,'%s','Delimiter','\n');
fclose(fid);
dependencies = dependencies{:};
checkGitHubDependencies(dependencies);

% Import mcmc-utils-matlab package
import mcmc.*
mcmc.setPlotTheme('fontsize',16, 'linewidth',1)

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
