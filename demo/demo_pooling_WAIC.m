% demo_pooling_WAIC
% This example examines how level of pooling (hierarchical inference)
% effects the model complexity. We will fit the kirby dataset with various
% models and examine what we get from the WAIC model comparison.

%% setup
toolbox_path = '~/git-local/delay-discounting-analysis/ddToolbox';
addpath(toolbox_path)
datapath = '~/git-local/delay-discounting-analysis/demo/datasets/kirby';

addpath(toolbox_path)
ddAnalysisSetUp();

% Running this multiple times will result in slightly different model
% comparison results. For real model comparison contexts, eg for research
% papers, then you'd want to ensire your posteriors are good
% approximations. Best way to start is by increasing the number of MCMC
% samples.
mcmc_params = struct('nsamples', 10000,...
		'nchains', 4,...
		'nburnin', 2000);

%% Set up the data to be analysed
myData = Data(datapath, 'files', allFilesInFolder(datapath, 'txt'));
	
%% Fit multiple models to the dataset

modelA = ModelSeparateLogK(...
	myData,...
	'savePath', fullfile(pwd,'output','modelA'),...
	'mcmcParams', mcmc_params);

modelB = ModelMixedLogK(...
	myData,...
	'savePath', fullfile(pwd,'output','modelB'),...
	'mcmcParams', mcmc_params);
	
modelC = ModelHierarchicalLogK(...
	myData,...
	'savePath', fullfile(pwd,'output','modelC'),...
	'mcmcParams', mcmc_params);

modelD = ModelHierarchicalMEUpdated(...
	myData,...
	'savePath', fullfile(pwd,'output','modelD'),...
	'mcmcParams', mcmc_params);


%% Examine WAIC stats for models
waic = [modelA.WAIC_stats,...
	modelB.WAIC_stats,...
	modelC.WAIC_stats,...
	modelD.WAIC_stats];

waic_comparison_table = waic.compare()

waic.plot()

figure(2), clf

%% Examine WAIC stats for models
waic = [modelA.WAIC_stats,...
	modelB.WAIC_stats,...
	modelC.WAIC_stats];

waic_comparison_table = waic.compare()

waic.plot()