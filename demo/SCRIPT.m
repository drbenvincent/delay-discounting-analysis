function SCRIPT
% code used in the preparation of the paper

%% Preamble
% Ensure the current directory is the 'project folder'
cd('~/git-local/delay-discounting-analysis/demo')
% Update the path below to point toward the '/ddToolbox' folder
toolboxPath = setToolboxPath('~/git-local/delay-discounting-analysis/ddToolbox');

mcmc.setPlotTheme('fontsize',16, 'linewidth',1)

%% Create data object

% create a cell array of which participant files to import
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

% You can use this function if you would like to exlude participants.
%fnames = excludeTheseParticipants(fnames, {'SK-kirby27.txt', 'VD-kirby27.txt'})

% Participant-level data will be aggregated into a larger group-level data
% file. This is also saved for inspection, but is not used in later code.

pathToData='data';
myData = DataClass(pathToData);
myData.loadDataFiles(fnames);


%% Analyse the data with the hierarchical model

% First we create a model object, which we will call hModel. This is an
% instance of the class 'ModelHierarchical'
saveFolder = 'methodspaper-kirby27';
hModel = ModelHierarchicalME(toolboxPath, 'JAGS', myData, saveFolder);
% hModel.setMCMCtotalSamples(10^6);
% hModel.setMCMCnumberOfChains(4);

% This will initiate MCMC sampling. This can take some time to run.
hModel.conductInference();

hModel.exportParameterEstimates();

hModel.plot()

% Inspect mcmc chains
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

% TOD0: fix this
% figure(1), clf
% plotFlag=true;
% ax(1) = subplot(1,2,1);
% hModel.conditionalDiscountRates(100, plotFlag);
% ax(2) = subplot(1,2,2);
% hModel.conditionalDiscountRates(1000, plotFlag);
% linkaxes(ax,'xy')



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
h_me_updated.sampler.setMCMCtotalSamples(10^5);
h_me_updated.conductInference();
h_me_updated.exportParameterEstimates();
h_me_updated.plot()


%% Hierarchical model, estimate discount rate = log(k), no magnitude effect
h_logk = ModelHierarchicalLogK(toolboxPath, 'JAGS', myData, 'hierarchical_logk');
h_logk.sampler.setMCMCtotalSamples(10^5);
h_logk.conductInference();
h_logk.plot()


% =========================================================================
% MODELS BELOW TREAT PARTICIPANTS INDEPENDENTLY, NO HIERARCHICAL ESTIMATION
% These could be useful in some situations, but we loose the advantages of
% hierarchical estimation.

%% Independent participants (non-hierarchical) estimation of the magnitude effect
warning('Chain convergence issues: priors need to be refined.')
s_me = ModelSeparateME(toolboxPath, 'JAGS', myData, 'separate_ME');
s_me.sampler.setMCMCtotalSamples(10^5);
s_me.conductInference();
s_me.exportParameterEstimates();
s_me.plot()

%% Independent participants (non-hierarchical) estimation of log(k)
s_logk = ModelSeparateLogK(toolboxPath, 'JAGS', myData, 'separate_logk');
s_logk.sampler.setMCMCtotalSamples(10^5);
s_logk.conductInference();
s_logk.exportParameterEstimates();
s_logk.plot()

return
