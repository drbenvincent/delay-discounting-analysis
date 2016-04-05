
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
jagsModel = ModelHierarchicalNOMAG(toolboxPath, 'JAGS', myData, 'hierarchical_logk');
jagsModel.sampler.setMCMCtotalSamples(10^2);
jagsModel.conductInference();
jagsModel.exportParameterEstimates();
jagsModel.plot()


%% ModelHierarchical
% stanModel = ModelHierarchical(toolboxPath, 'STAN', myData, saveFolder);
% clc
% stanModel.conductInference();
% stanModel.sampler.stanFit
% 
% temp = stanModel.sampler.stanFit.extract('pars','logk_group').logk_group;
% hist(temp,100)
% 


%% Separate
sModel = ModelSeparate(toolboxPath, 'JAGS', myData, 'separatetest');
sModel.sampler.setMCMCtotalSamples(10^3);
sModel.conductInference();
sModel.plot()




%% ModelHierarchicalNOMAG
sModel = ModelHierarchicalNOMAG(toolboxPath, 'STAN', myData, 'stan-ModelHierarchicalNOMAG');
sModel.sampler.setStanHome('/Users/benvincent/cmdstan') 

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