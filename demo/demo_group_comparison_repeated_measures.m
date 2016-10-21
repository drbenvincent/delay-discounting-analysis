function [group1, group2] = demo_group_comparison_repeated_measures()
%demo_group_comparison
% The approch for group comparisons is very simple. Run a model to do
% parameter estimation, separately for each group. Then compare group-level
% discounting parameters.

warning('Code below this point is under active development')

path_of_this_mfile = strrep(which(mfilename),[mfilename '.m'],'');
toolbox_path = fullfile(path_of_this_mfile,'..','ddToolbox');

% Run setup routine
addpath(toolbox_path)
ddAnalysisSetUp();

%% Define common parameters.
% There's no need to do this as a separate step, but it helps to ensure
% both models are fit with the same parameters
mcmcparams = struct('nsamples', 10000,...
	'nchains', 4,...
	'nburnin', 2000);
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


warning('Code below this point is under active development')

%% Compare group level parameter estimates (repeated-measures)

% Firstly, we will visualise participant-level changes
n_participants = 10;
for p=1:n_participants
	person_group1_estimate = group1.coda.getSamplesAtIndex(p, {'logk'});
	person_group2_estimate = group2.coda.getSamplesAtIndex(p, {'logk'});
	differences(:,p) = person_group1_estimate.logk - person_group2_estimate.logk;
end

% TODO: maybe automate plots of parameter differences of each participant

mcmc.UnivariateDistribution(differences,...
	'XLabel','group 1 - group 2 ($\log(k)$)',...
	'plotHDI',false)

% If you have a repeated measures design, then we can either:
%
% 1) export point estimates of logk by participant and group, then analyse
% this with a stats package such as SPSS or JASP. This is probably the best
% thing to do before I have fully worked out the second approach.
%
% 2) go down the 'full-Bayesian' route. In this case we would work with
% full distributions rather than working with point estimates. For example,
% just as we looked at the distribution of differences between group level
% estimates, we could do this for each participant, and then look to see if
% we have meaningful group-level differences in these participant-level
% differences.
% While this would be an 'ok' thing to do, it is probably not the best or
% most kosher way of doing it. If we are doing hierarchical inference, then
% we may want a new model which estimates participant x condition discount
% rates, and then hierarchical estimates of participant discount rates etc.
% This needs some proper thought.

% METHOD 1)


% METHOD 2)

