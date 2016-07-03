% Ben's testing script

%% Setup stuff
% User options
projectPath = '~/git-local/delay-discounting-analysis/demo';		 % <--- set yourself
toolboxPath = '~/git-local/delay-discounting-analysis/ddToolbox';% <--- set yourself
dataPath		= 'data'; % <--- set yourself
numberOfMCMCSamples = 10^3; % set to 10^4 for faster, but less accurate inferences
chains = 2;

% Preamble
cd(projectPath)
setToolboxPath(toolboxPath);
mcmc.setPlotTheme('fontsize',16, 'linewidth',1)

% Load data
%filesToAnalyse = allFilesInFolder(dataPath, 'txt');
filesToAnalyse={'AC-kirby27-DAYS.txt',...
'CS-kirby27-DAYS.txt'};
myData = DataClass(dataPath);
myData.loadDataFiles(filesToAnalyse);


%% Do the analysis
h_me = ModelHierarchicalME(toolboxPath, 'JAGS', myData, 'hierarchical_ME',...
	'pointEstimateType','mode',...
	'mcmcSamples', numberOfMCMCSamples,...
	'chains', chains);
h_me.conductInference(); % TODO: Could return an MCMCFit object here ******
h_me.exportParameterEstimates();
h_me.plot()

hypothesisTestScript(h_me)
myExport('BayesFactorMLT1',...
	'saveFolder', h_me.saveFolder,...
	'prefix', h_me.modelType)

% Inspect mcmc chains
h_me.plotMCMCchains({'m','c'})
h_me.plotMCMCchains({'m_group','c_group', 'alpha_group', 'epsilon_group'})



%% Test other models below

% ModelHierarchicalMEUpdated
h_me_updated = ModelHierarchicalMEUpdated(toolboxPath, 'JAGS', myData, 'hierarchical_ME_updated',...
	'mcmcSamples', numberOfMCMCSamples,...
	'chains', chains);
h_me_updated.conductInference(); % TODO: Could return an MCMCFit object here ******
h_me_updated.exportParameterEstimates();
h_me_updated.plot()


% ModelHierarchicalLogK
h_logk = ModelHierarchicalLogK(toolboxPath, 'JAGS', myData, 'hierarchical_logk',...
	'mcmcSamples', numberOfMCMCSamples,...
	'chains', chains);
h_logk.conductInference();
h_logk.plot()
h_logk.exportParameterEstimates();

% ModelSeparateME
s_me = ModelSeparateME(toolboxPath, 'JAGS', myData, 'separate_ME',...
	'mcmcSamples', numberOfMCMCSamples,...
	'chains', chains);
s_me.conductInference();
s_me.exportParameterEstimates();
s_me.plot()

% ModelMixedLogK
m_logk = ModelMixedLogK(toolboxPath, 'JAGS', myData, 'mixed_logk',...
	'mcmcSamples', numberOfMCMCSamples,...
	'chains', chains);
m_logk.conductInference();
m_logk.exportParameterEstimates('includeCI',false);
m_logk.plot()

% ModelSeparateLogK
s_logk = ModelSeparateLogK(toolboxPath, 'JAGS', myData, 'separate_logk',...
	'mcmcSamples', numberOfMCMCSamples,...
	'chains', chains);
s_logk.conductInference();
s_logk.exportParameterEstimates();
s_logk.plot()


%% Compare hierarchical and non-hierarchical inferences for log(k) models
figure
subplot(2,1,1)
plotLOGKclusters(s_logk.mcmc, s_logk.data, [0.7 0 0], 'mode')
title('non-hierarchical')

subplot(2,1,2)
plotLOGKclusters(h_logk.mcmc, h_logk.data, [0.7 0 0], 'mode')
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
grw = ModelGaussianRandomWalkSimple(toolboxPath,...
	'JAGS', myData,...
	'ModelGaussianRandomWalkSimple',...
	'pointEstimateType','mode',...
	'mcmcSamples', numberOfMCMCSamples,...
	'chains', chains);
grw.conductInference(); 
grw.plot()





%% EXPERIMENTAL FEATURE FOR THE FUTURE -------------------
% --------------------------------------------------------



% %% ModelHierarchicalLogK
% sModel = ModelHierarchicalLogK(toolboxPath, 'STAN', myData, 'stanModelHierarchicalLogK');
% sModel.sampler.setStanHome('~/cmdstan')
% clc
% stanFit = sModel.conductInference();
% % ~~~~~~~~~~~~~~~~~
% sModel.plot()
% % ~~~~~~~~~~~~~~~~~
% 
% %% HOW TO GET STATS VALUES
% % can get summary by typing this into TERMINAL
% % bin/stansummary /Users/benvincent/git-local/delay-discounting-analysis/demo/output-1.csv
% 
% sModel.sampler.stanFit.print()
% 
% 
% 
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
