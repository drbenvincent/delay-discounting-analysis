
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
h_me = ModelHierarchical(toolboxPath, 'JAGS', myData, 'hierarchical_ME');
h_me.sampler.setMCMCtotalSamples(10^4);
h_me.sampler.setMCMCnumberOfChains(2);
h_me.conductInference();
h_me.exportParameterEstimates();
h_me.plot()

HTgroupSlopeLessThanZero(h_me)

%% JAGS
s_me = ModelSeparate(toolboxPath, 'JAGS', myData, 'separate_ME');
s_me.sampler.setMCMCtotalSamples(10^3);
s_me.sampler.setMCMCnumberOfChains(2);
s_me.conductInference();
s_me.exportParameterEstimates();
s_me.plot()

%% JAGS
h_logk = ModelHierarchicalNOMAG(toolboxPath, 'JAGS', myData, 'hierarchical_logk');
h_logk.sampler.setMCMCtotalSamples(10^3);
h_logk.sampler.setMCMCnumberOfChains(2);
h_logk.conductInference();
h_logk.plot()
h_logk.exportParameterEstimates();
% h_logk.plotMCMCchains()
% h_logk.posteriorPredictive(); %<--- fix this



%% ModelHierarchical
% stanModel = ModelHierarchical(toolboxPath, 'STAN', myData, saveFolder);
% clc
% stanModel.conductInference();
% stanModel.sampler.stanFit
% 
% temp = stanModel.sampler.stanFit.extract('pars','logk_group').logk_group;
% hist(temp,100)
% 





%% ModelHierarchicalNOMAG
sModel = ModelHierarchicalNOMAG(toolboxPath, 'STAN', myData, 'stanModelHierarchicalNOMAG');
sModel.sampler.setStanHome('/Users/btvincent/cmdstan') 
clc
sModel.conductInference();
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