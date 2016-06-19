function SCRIPT
% Example use of the delay discounting analysis toolbox

%% User options
% When using JAGS as the MCMC sampler, you'll need at least 10^5 - 10^6
% total samples for good approximation of the posteriors. You can of course
% decrease this for testing purposes.
numberOfMCMCSamples = 10^5; 

% ** You should update the following lines according for your system **
% Note: on a mac '~' corresponds to your home dir eg '/Users/myusername'
projectPath = '~/git-local/delay-discounting-analysis/demo';
toolboxPath = '~/git-local/delay-discounting-analysis/ddToolbox';


%% Preamble
cd(projectPath)
toolboxPath = setToolboxPath(toolboxPath);
mcmc.setPlotTheme('fontsize',16, 'linewidth',1)


%% Load data

% define a path to the data files
pathToData='data';

% create a cell array of participant files to import
fnames={'AC-kirby27-DAYS.txt',...
'CS-kirby27-DAYS.txt',...
'NA-kirby27-DAYS.txt',...
'SB-kirby27-DAYS.txt',...
'bv-kirby27.txt',...
'rm-kirby27.txt',...
'vs-kirby27.txt',...
'BL-kirby27.txt',...
'EP-kirby27.txt',...
'JR-kirby27.txt',...
'KA-kirby27.txt',...
'LJ-kirby27.txt',...
'LY-kirby27.txt',...
'SK-kirby27.txt',...
'VD-kirby27.txt'};

% Optional participant exclusion.
%fnames = excludeTheseParticipants(fnames, {'SK-kirby27.txt', 'VD-kirby27.txt'})

% load data into a Data object
myData = DataClass(pathToData);
myData.loadDataFiles(fnames);


%% Analyse the data with the hierarchical model

% 1) Create a model object
saveFolder = 'methodspaper-kirby27';
hModel = ModelHierarchicalME(toolboxPath, 'JAGS', myData, saveFolder);
% optionally override MCMC defaults
hModel.setMCMCtotalSamples(numberOfMCMCSamples);
hModel.setMCMCnumberOfChains(4);

% 2) Do MCMC sampling
hModel.conductInference();

% 3) Export estimates and plotting
hModel.exportParameterEstimates('includeGroupEstimates', true,...
	'includeCI',false);

hModel.posteriorPredictive();
hModel.plot()

% you can use this type of command to inspect mcmc chains
hModel.plotMCMCchains({'m','c'})
hModel.plotMCMCchains({'m_group','c_group', 'alpha_group', 'epsilon_group'})


%% Example of a script written to conduct Hypothesis tests
hypothesisTestScript(hModel)


%% Getting access to samples
% If you want to get access to the full posterior distributions, then you
% can ask for the samples.
% The precise way how this works might change as I am updating the
% internals of the code. But currently, the method is:
someSamples = hModel.mcmc.getSamples({'m','c'});


%% Discount rate for a particular reward magnitude
% You may be interested in the discount rate (at the group and participant
% levels) at a particular reward magnitude. The method
% conditionalDiscountRatePlots() plots participant and group level
% conditional posterior (predictive) distributions. That is...
% The posterior distribution of discount rate (log(k)) for a given reward
% magnitude.
%
% Below we calculate and plot the discount rates for reward magnitudes of 
% £100 and £1,000

figure(1), clf
plotFlag=true;
ax(1) = subplot(1,2,1);
hModel.conditionalDiscountRates(100, plotFlag);
ax(2) = subplot(1,2,2);
hModel.conditionalDiscountRates(1000, plotFlag);
linkaxes(ax,'xy')



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
h_me_updated = ModelHierarchicalMEUpdated(toolboxPath, 'JAGS', myData, saveFolder);
h_me_updated.sampler.setMCMCtotalSamples(numberOfMCMCSamples);
h_me_updated.conductInference();
h_me_updated.exportParameterEstimates('includeCI',false);
h_me_updated.plot()
h_me_updated.posteriorPredictive();


%% Hierarchical model, estimate discount rate = log(k), no magnitude effect
h_logk = ModelHierarchicalLogK(toolboxPath, 'JAGS', myData, 'hierarchical_logk');
h_logk.sampler.setMCMCtotalSamples(numberOfMCMCSamples);
h_logk.conductInference();
h_logk.exportParameterEstimates('includeCI',false);
h_logk.plot()
h_logk.posteriorPredictive();


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
m_logk.sampler.setMCMCtotalSamples(numberOfMCMCSamples);
m_logk.conductInference();
m_logk.exportParameterEstimates('includeCI',false);
m_logk.plot()
m_logk.posteriorPredictive();


% =========================================================================
% MODELS BELOW TREAT PARTICIPANTS INDEPENDENTLY, NO HIERARCHICAL ESTIMATION
% These could be useful in some situations, but we loose the advantages of
% hierarchical estimation.

%% Independent participants (non-hierarchical) estimation of the magnitude effect
warning('Chain convergence issues: priors need to be refined.')
s_me = ModelSeparateME(toolboxPath, 'JAGS', myData, 'separate_ME');
s_me.sampler.setMCMCtotalSamples(numberOfMCMCSamples);
s_me.conductInference();
s_me.exportParameterEstimates('includeCI',false);
s_me.plot()
s_me.posteriorPredictive();

%% Independent participants (non-hierarchical) estimation of log(k)
s_logk = ModelSeparateLogK(toolboxPath, 'JAGS', myData, 'separate_logk');
s_logk.sampler.setMCMCtotalSamples(numberOfMCMCSamples);
s_logk.conductInference();
s_logk.exportParameterEstimates('includeCI',false);
s_logk.plot()
s_logk.posteriorPredictive();

%% Compare hierarchical and non-hierarchical inferences for log(k) models
figure
subplot(2,1,1)
plotLOGKclusters(s_logk.mcmc, s_logk.data, [0.7 0 0], 'mode')
title('non-hierarchical')

subplot(2,1,2)
plotLOGKclusters(h_logk.mcmc, h_logk.data, [0.7 0 0], 'mode')
title('hierarchical')

subplot(2,1,2), a=axis; subplot(2,1,1), axis(a);



return
