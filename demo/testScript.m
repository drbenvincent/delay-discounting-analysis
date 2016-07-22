function testScript

numberOfMCMCSamples = 10^3;
chains = 2;

%% Setup
addpath('~/git-local/delay-discounting-analysis/ddToolbox')
ddAnalysisSetUp();

%% Load data
datapath = '~/git-local/delay-discounting-analysis/demo/data';
%filesToAnalyse = allFilesInFolder(datapath, 'txt');
filesToAnalyse={'AC-kirby27-DAYS.txt', 'CS-kirby27-DAYS.txt'};
%filesToAnalyse={'AC-kirby27-DAYS.txt'};
myData = DataClass(datapath, 'files', filesToAnalyse);


%% Do the analysis, loop over each of the models
sampler = 'jags';
listOfModels = {'ModelHierarchicalME',...
	'ModelHierarchicalMEUpdated',...
	'ModelSeparateME',...
	'ModelMixedLogK',...
	'ModelSeparateLogK',...
	'ModelHierarchicalLogK'};

for n = 1:numel(listOfModels)
	modelName = listOfModels{n};
	makeModelFunction = str2func(modelName);
	
	all_models(n).model = makeModelFunction(myData,...
		'saveFolder', modelName,...
		'pointEstimateType','mode');
	
	all_models(n).model = all_models(n).model.conductInference(...
		sampler,... % {'jags', 'stan'}
		'mcmcSamples',numberOfMCMCSamples,...
		'chains',chains,...
		'shouldPlot','yes'); % TODO: add mcmcparams over-ride
end





%% Do the analysis, loop over each of the models
sampler = 'stan';
listOfModels = {'ModelSeparateLogK','ModelMixedLogK','ModelHierarchicalLogK'};

for n = 1:numel(listOfModels)
	modelName = listOfModels{n};
	makeModelFunction = str2func(modelName);
	
	all_models(n).model = makeModelFunction(myData,...
		'saveFolder', modelName,...
		'pointEstimateType','mode');
	
	all_models(n).model = all_models(n).model.conductInference(...
		sampler,... % {'jags', 'stan'}
		'mcmcSamples',10^3,...
		'shouldPlot','no'); % TODO: add mcmcparams over-ride
end










%% Compare hierarchical and non-hierarchical inferences for log(k) models
figure
subplot(2,1,1)
plotLOGKclusters(all_models.(ModelSeparateLogK).mcmc, all_models.(ModelSeparateLogK).data, [0.7 0 0], 'mode')
title('non-hierarchical')

subplot(2,1,2)
plotLOGKclusters(all_models.(ModelHierarchicalLogK).mcmc, all_models.(ModelHierarchicalLogK).data, [0.7 0 0], 'mode')
title('hierarchical')

subplot(2,1,2), a=axis; subplot(2,1,1), axis(a);




%% test all plot functions, without re-running fit
% h_me.plot()
% h_me_updated.plot()
% h_logk.plot()
% s_me.plot()
% s_logk.plot()








%% GAUSSIAN RANDOM WALK MODEL
% *** This model is NOT really appropriate to apply to the Kirby data, but
% I am including it here to see what it will do. ***
grw = ModelGaussianRandomWalkSimple('JAGS', myData,...
	'saveFolder', 'ModelGaussianRandomWalkSimple',...
	'pointEstimateType','mode',...
	'mcmcSamples', numberOfMCMCSamples,...
	'chains', chains,...
	'shouldPlot','all');
grw = grw.conductInference(); 



%% HOW TO GET STATS VALUES
% can get summary by typing this into TERMINAL
% bin/stansummary /Users/benvincent/git-local/delay-discounting-analysis/demo/output-1.csv
%
% sModel.sampler.stanFit.print()
% 
% sModel.sampler.stanFit
% clf
% sModel.sampler.stanFit.print()
% 
% temp = sModel.sampler.stanFit.extract('pars','logk_group').logk_group;
% hist(temp,100)
% 
% temp = sModel.sampler.stanFit.extract('pars','epsilon_group').epsilon_group;
% hist(temp,100)
% 
% temp = sModel.sampler.stanFit.extract('pars','alpha_group').alpha_group;
% hist(temp,100)
% 
% % EXTRACT ALL
% all = sModel.sampler.stanFit.extract('permuted',true);
%stanModel.sampler.stanFit.traceplot() % use with care
