% Ben's testing script

%% Setup
cd('~/git-local/delay-discounting-analysis/demo')
toolboxPath = setToolboxPath('~/git-local/delay-discounting-analysis/ddToolbox');
mcmc.setPlotTheme('fontsize',16, 'linewidth',1)

nSamples = 10^5;
nChains = 4;

%% Load data
% fnames={'AC-kirby27-DAYS.txt',...
% 'CS-kirby27-DAYS.txt',...
% 'NA-kirby27-DAYS.txt',...
% 'SB-kirby27-DAYS.txt',...
% 'bv-kirby27.txt',...
% 'rm-kirby27.txt',...
% 'vs-kirby27.txt',...
% 'BL-kirby27.txt',...
% 'EP-kirby27.txt',...
% 'JR-kirby27.txt',...
% 'KA-kirby27.txt',...
% 'LJ-kirby27.txt',...
% 'LY-kirby27.txt',...
% 'SK-kirby27.txt',...
% 'VD-kirby27.txt'};

fnames={'AC-kirby27-DAYS.txt',...
'CS-kirby27-DAYS.txt',...
'NA-kirby27-DAYS.txt',...
'SB-kirby27-DAYS.txt'};

pathToData='data';
myData = DataClass(pathToData);
myData.loadDataFiles(fnames);





%% JAGS
h_me = ModelHierarchicalME(toolboxPath, 'JAGS', myData, 'hierarchical_ME',...
	'pointEstimateType','mode');
h_me.sampler.setMCMCtotalSamples(nSamples);
h_me.sampler.setMCMCnumberOfChains(nChains);
h_me.conductInference(); % TODO: Could return an MCMCFit object here ******
h_me.exportParameterEstimates('includeGroupEstimates',false);
h_me.plot()


hypothesisTestScript(h_me)
myExport('BayesFactorMLT1',...
	'saveFolder', h_me.saveFolder,...
	'prefix', h_me.modelType)

% Inspect mcmc chains
h_me.plotMCMCchains({'m','c'})
h_me.plotMCMCchains({'m_group','c_group', 'alpha_group', 'epsilon_group'})


%% JAGS - updated
h_me_updated = ModelHierarchicalMEUpdated(toolboxPath, 'JAGS', myData, 'hierarchical_ME_updated');
h_me_updated.sampler.setMCMCtotalSamples(nSamples);
h_me_updated.sampler.setMCMCnumberOfChains(nChains);
h_me_updated.conductInference(); % TODO: Could return an MCMCFit object here ******
h_me_updated.exportParameterEstimates();
h_me_updated.plot()


%% JAGS
h_logk = ModelHierarchicalLogK(toolboxPath, 'JAGS', myData, 'hierarchical_logk');
h_logk.sampler.setMCMCtotalSamples(nSamples);
h_logk.sampler.setMCMCnumberOfChains(nChains);
h_logk.conductInference();
h_logk.plot()
h_logk.exportParameterEstimates();
% h_logk.plotMCMCchains()
% h_logk.posteriorPredictive(); %<--- fix this

%% JAGS - ME
s_me = ModelSeparateME(toolboxPath, 'JAGS', myData, 'separate_ME');
s_me.sampler.setMCMCtotalSamples(nSamples);
s_me.sampler.setMCMCnumberOfChains(nChains);
s_me.conductInference();
s_me.exportParameterEstimates();
s_me.plot()


%% Mixed model, estimate discount rate = log(k), no magnitude effect
% logk: non-hierarchical, we just have a prior of logk which applies to
%		each participant
% epsilon: hierarchical
% alpha: hierarchical
% Note that *group* level logk values reported are determined by your prior
% over logk. Participant-level logk is our posterior over logk, determined
% by the data and the prior, but is NOT influenced by other participants in
% the sample.
m_logk = ModelMixedLogK(toolboxPath, 'JAGS', myData, 'mixed_logk');
m_logk.sampler.setMCMCtotalSamples(nSamples);
m_logk.sampler.setMCMCnumberOfChains(nChains);
m_logk.conductInference();
m_logk.exportParameterEstimates('includeCI',false);
m_logk.plot()

%% JAGS - separate logk
s_logk = ModelSeparateLogK(toolboxPath, 'JAGS', myData, 'separate_logk');
s_logk.sampler.setMCMCtotalSamples(nSamples);
s_logk.sampler.setMCMCnumberOfChains(nChains);
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
h_me.plot()
h_me_updated.plot()
h_logk.plot()
s_me.plot()
s_logk.plot()








%% GAUSSIAN RANDOM WALK MODEL
% *** This model is NOT really appropriate to apply to the Kirby data, but
% I am including it here to see what it will do. ***
grw = ModelGaussianRandomWalkSimple(toolboxPath,...
	'JAGS', myData,...
	'ModelGaussianRandomWalkSimple',...
	'pointEstimateType','mode');
grw.sampler.setMCMCtotalSamples(10^4);
grw.sampler.setMCMCnumberOfChains(4);
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
