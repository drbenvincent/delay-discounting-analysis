% Ben's testing script

toolboxPath = setToolboxPath('/Users/benvincent/git-local/delay-discounting-analysis/ddToolbox')
cd('/Users/benvincent/git-local/delay-discounting-analysis/demo')
setPlotTheme

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

pathToData='data';
myData = DataClass(pathToData);
myData.loadDataFiles(fnames);


%% JAGS
h_me = ModelHierarchicalME(toolboxPath, 'JAGS', myData, 'hierarchical_ME');
h_me.sampler.setMCMCtotalSamples(10^4);
h_me.sampler.setMCMCnumberOfChains(2);
h_me.conductInference(); % TODO: Could return an MCMCFit object here ******
h_me.exportParameterEstimates();
h_me.plot()

hypothesisTestScript(h_me)

% Inspect mcmc chains
h_me.plotMCMCchains({'m','c'})
h_me.plotMCMCchains({'m_group','c_group', 'alpha_group', 'epsilon_group'})


%% JAGS - updated
h_me = ModelHierarchicalMEUpdated(toolboxPath, 'JAGS', myData, 'hierarchical_ME_updated');
h_me.sampler.setMCMCtotalSamples(10^4);
h_me.sampler.setMCMCnumberOfChains(2);
h_me.conductInference(); % TODO: Could return an MCMCFit object here ******
h_me.exportParameterEstimates();
h_me.plot()


%% JAGS
h_logk = ModelHierarchicalLogK(toolboxPath, 'JAGS', myData, 'hierarchical_logk');
h_logk.sampler.setMCMCtotalSamples(10^5);
h_logk.sampler.setMCMCnumberOfChains(2);
h_logk.conductInference();
h_logk.plot()
h_logk.exportParameterEstimates();
% h_logk.plotMCMCchains()
% h_logk.posteriorPredictive(); %<--- fix this

%% JAGS - ME
s_me = ModelSeparateME(toolboxPath, 'JAGS', myData, 'separate_ME');
s_me.sampler.setMCMCtotalSamples(10^5);
s_me.sampler.setMCMCnumberOfChains(2);
s_me.conductInference();
s_me.exportParameterEstimates();
s_me.plot()

%% JAGS - separate logk
s_logk = ModelSeparateLogK(toolboxPath, 'JAGS', myData, 'separate_logk');
s_logk.sampler.setMCMCtotalSamples(10^5);
s_logk.sampler.setMCMCnumberOfChains(2);
s_logk.conductInference();
s_logk.exportParameterEstimates();
s_logk.plot()











%% EXPERIMENTAL FEATURE FOR THE FUTURE -------------------
% --------------------------------------------------------



%% ModelHierarchicalLogK
sModel = ModelHierarchicalLogK(toolboxPath, 'STAN', myData, 'stanModelHierarchicalLogK');
sModel.sampler.setStanHome('/Users/btvincent/cmdstan')
clc
stanFit = sModel.conductInference();
% ~~~~~~~~~~~~~~~~~
sModel.plot()
% ~~~~~~~~~~~~~~~~~

%% HOW TO GET STATS VALUES
% can get summary by typing this into TERMINAL
% bin/stansummary /Users/benvincent/git-local/delay-discounting-analysis/demo/output-1.csv

sModel.sampler.stanFit.print()




sModel.sampler.stanFit
clf
sModel.sampler.stanFit.print()

temp = sModel.sampler.stanFit.extract('pars','logk_group').logk_group;
hist(temp,100)

temp = sModel.sampler.stanFit.extract('pars','epsilon_group').epsilon_group;
hist(temp,100)

temp = sModel.sampler.stanFit.extract('pars','alpha_group').alpha_group;
hist(temp,100)

% EXTRACT ALL
all = sModel.sampler.stanFit.extract('permuted',true);


%stanModel.sampler.stanFit.traceplot() % use with care
