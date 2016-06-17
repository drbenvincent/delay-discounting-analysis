% SCRIPT
% To test the Gaussian Random Walk model

%% Setup
cd('~/git-local/delay-discounting-analysis/demo-nonparametric')
toolboxPath = setToolboxPath('~/git-local/delay-discounting-analysis/ddToolbox');
mcmc.setPlotTheme('fontsize',16, 'linewidth',1)

%% Load data
fnames={'CR.txt','CS.txt','RG.txt'};
pathToData='data';
myData = DataClass(pathToData);
myData.loadDataFiles(fnames);

%% TEST GAUSSIAN RANDOM WALK MODEL
grw = ModelGaussianRandomWalkSimple(toolboxPath,...
	'JAGS', myData,...
	'ModelGaussianRandomWalkSimple',...
	'pointEstimateType','mode');
grw.sampler.setMCMCtotalSamples(10^4);
grw.sampler.setMCMCnumberOfChains(4);
grw.conductInference(); 
grw.plot()
