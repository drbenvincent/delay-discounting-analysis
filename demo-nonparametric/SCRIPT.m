% SCRIPT
% To test the Gaussian Random Walk model
% This model is most appropriate when applied to data focussing on finding
% indifference points for a set number of delays. Ie, not the Kirby dataset
% because all delays are unique.

%% Setup
cd('~/git-local/delay-discounting-analysis/demo-nonparametric')
toolboxPath = setToolboxPath('~/git-local/delay-discounting-analysis/ddToolbox');
mcmc.setPlotTheme('fontsize',16, 'linewidth',1)

%% Load data
fnames={'CA-gain.txt', 'CA-loss.txt',...
	'CR-gain.txt', 'CR-loss.txt',...
	'CS-gain.txt', 'CS-loss.txt',...
	'RG-gain.txt', 'RG-loss.txt',...
	'ScT-gain.txt', 'ScT-loss.txt'};
% 'CR.txt','CS.txt','RG.txt',...
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
