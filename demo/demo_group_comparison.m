function [group1, group2] = demo_group_comparison()
%demo_group_comparison
% The approch for group comparisons is very simple. Run a model to do
% parameter estimation, separately for each group. Then compare group-level
% discounting parameters.

path_of_this_mfile = strrep(which(mfilename),[mfilename '.m'],'');
toolbox_path = fullfile(path_of_this_mfile,'..','ddToolbox');

% Run setup routine
addpath(toolbox_path)
ddAnalysisSetUp();

%% Define common parameters.
% There's no need to do this as a separate step, but it helps to ensure
% both models are fit with the same parameters
mcmcparams = struct('nsamples', 1000,...
	'nchains', 4,...
	'nburnin', 100);
pointEstimateType = 'median';
					 
%% Analyse group 1 
datapath1 = fullfile(path_of_this_mfile,'datasets','group_comparison','group1');
group1 = ModelHierarchicalLogK(...
	Data(datapath1, 'files', allFilesInFolder(datapath1, 'txt')),...
	'savePath', fullfile(pwd,'output','group1'),...
	'pointEstimateType', pointEstimateType,...
	'sampler', 'jags',...
	'shouldPlot', 'no',...
	'shouldExportPlots', false,...
	'mcmcParams', mcmcparams);
					 
%% Analyse group 2 
datapath2 = fullfile(path_of_this_mfile,'datasets','group_comparison','group2');
group2 = ModelHierarchicalLogK(...
	Data(datapath2, 'files', allFilesInFolder(datapath2, 'txt')),...
	'savePath', fullfile(pwd,'output','group2'),...
	'pointEstimateType', pointEstimateType,...
	'sampler', 'jags',...
	'shouldPlot', 'no',...
	'shouldExportPlots', false,...
	'mcmcParams', mcmcparams);

%% Compare group level parameter estimates
% ******* NOTE THAT THIS CODE WILL BE IMPROVED AND SIMPLIFIED, BUT THIS IS
% ENOUGH TO GET THINGS WORKING FOR GROUP-LEVEL COMPARISONS ****************

% Now we extract the mcmc samples of the group level log(k).
% Note that the group level inferences are modelled (basically) as an
% unobserved participant who is coded as 'number of participants + 1' So
% you need to get this number right for your dataset.
group_level_participant_index = 11;

group1_estimates = group1.coda.getSamplesAtIndex(group_level_participant_index, {'logk'}); 
group2_estimates = group2.coda.getSamplesAtIndex(group_level_participant_index, {'logk'});

group_logk_difference = group1_estimates.logk - group2_estimates.logk;

% You could now plot this distribution of differences very simply as:
% >>  hist(group_logk_difference, 31)
%
% but we can use my mcmc-utils-matlab repository code...

mcmc.UnivariateDistribution(group_logk_difference,...
	'XLabel','group 1 - group 2 ($\log(k)$)',...
	'pointEstimateType', pointEstimateType,...
	'shouldPlotPointEstimate', true)
title('Differences in group level $\log(k)$', 'Interpreter','latex')

% Now you can make decisions about whether there are group level
% differences based upon whether the 95% credible region overlaps with zero
% (ie no group difference) or not.


