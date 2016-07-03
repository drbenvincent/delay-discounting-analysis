function SCRIPT
% Example use of the delay discounting analysis toolbox

%% Setup stuff
toolboxPath = '~/git-local/delay-discounting-analysis/ddToolbox'; % <--- set yourself
projectPath = '~/git-local/delay-discounting-analysis/demo';      % <--- set yourself
dataPath	= '~/git-local/delay-discounting-analysis/demo/data'; % <--- set yourself
numberOfMCMCSamples = 10^5; % set to 10^4 for faster, but less accurate inferences
cd(projectPath)
setToolboxPath(toolboxPath);
mcmc.setPlotTheme('fontsize',16, 'linewidth',1)

%% Load data
filesToAnalyse = allFilesInFolder(dataPath, 'txt');
myData = DataClass(dataPath);
myData.loadDataFiles(filesToAnalyse);

%% Run an analysis
saveFolder = 'methodspaper-kirby27';

hModel = ModelHierarchicalME(toolboxPath, 'jags', myData, saveFolder,...
	'mcmcSamples', numberOfMCMCSamples,... % optional
	'chains', 4); % optional

hModel.conductInference();
hModel.exportParameterEstimates();
hModel.plot()


%% Example things you can now do

% 1) plot MCMC chains for diagnosic purposes
hModel.plotMCMCchains({'m','c'})
hModel.plotMCMCchains({'m_group','c_group', 'alpha_group', 'epsilon_group'})

% 2) Run scripts to conduct hypothesis testing
hypothesisTestScript(hModel)

% 3) Get access to samples, put into a structure
someSamples = hModel.mcmc.getSamples({'m','c'});

% 4) Calculate discount rates for a given reward magnitude (for magnitude
% effect models)
conditionalDiscountRateExample(hModel)





% =========================================================================
% DEMONSTRATION OF USING ALTERNATIVE MODELS
% =========================================================================
%
% Note:
% - we are using the same data object that we loaded above
% - but we are analysing that data with different probabilistic models
% - outputs are saved to subfolders
% - if you use these models for research to be published you may want to
% make sure the priors specified in the models are reasonable for your
% research context
%
% Warning: While these models often work fine, there have been convergence
% issues with some datasets that I have tried. So I may well be
% investigating alternative parameterisations and priors etc.


%% Updated prior model
% Since publication, I have tested the analysis code on a wider range of
% datasets and have found it necessary to update some of the the priors in
% order to have more reliable MCMC chain convergence.
saveFolder = 'hierarchical_updated_priors';
h_me_updated = ModelHierarchicalMEUpdated(toolboxPath, 'jags', myData, saveFolder,...
	'mcmcSamples', numberOfMCMCSamples,... % optional
	'chains', 4); % optional
h_me_updated.conductInference();
h_me_updated.exportParameterEstimates();
h_me_updated.plot()



%% Hierarchical model, estimate discount rate = log(k), no magnitude effect
h_logk = ModelHierarchicalLogK(toolboxPath, 'jags', myData, 'hierarchical_logk',...
	'mcmcSamples', numberOfMCMCSamples,... % optional
	'chains', 4); % optional
h_logk.conductInference();
h_logk.exportParameterEstimates();
h_logk.plot()




%% Mixed model, estimate discount rate = log(k), no magnitude effect
% logk: non-hierarchical, we just have a prior of logk which applies to
%		each participant
% epsilon: hierarchical
% alpha: hierarchical
% Note that *group* level logk values reported are determined by your prior
% over logk. Participant-level logk is our posterior over logk, determined
% by the data and the prior, but is NOT influenced by other participants in
% the sample.
m_logk = ModelMixedLogK(toolboxPath, 'jags', myData, 'mixed_logk',...
	'mcmcSamples', numberOfMCMCSamples,... % optional
	'chains', 4); % optional
m_logk.conductInference();
m_logk.exportParameterEstimates();
m_logk.plot()



% =========================================================================
% MODELS BELOW TREAT PARTICIPANTS INDEPENDENTLY, NO HIERARCHICAL ESTIMATION
% These could be useful in some situations, but we loose the advantages of
% hierarchical estimation.

%% Independent participants (non-hierarchical) estimation of the magnitude effect
warning('Chain convergence issues: priors need to be refined.')
s_me = ModelSeparateME(toolboxPath, 'jags', myData, 'separate_ME',...
	'mcmcSamples', numberOfMCMCSamples,... % optional
	'chains', 4); % optional
s_me.conductInference();
s_me.exportParameterEstimates();
s_me.plot()


%% Independent participants (non-hierarchical) estimation of log(k)
s_logk = ModelSeparateLogK(toolboxPath, 'jags', myData, 'separate_logk',...
	'mcmcSamples', numberOfMCMCSamples,... % optional
	'chains', 4); % optional
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

end



