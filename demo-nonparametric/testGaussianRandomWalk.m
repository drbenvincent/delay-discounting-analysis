% testGaussianRandomWalk

cd('~/git-local/delay-discounting-analysis/demo-nonparametric')
toolboxPath = setToolboxPath('~/git-local/delay-discounting-analysis/ddToolbox');

mcmc.setPlotTheme('fontsize',16, 'linewidth',1)

%% Load data
fnames={'CR-gain.txt',...
'CR-loss.txt',...
'CS-gain.txt',...
'CS-loss.txt',...
'RG-gain.txt',...
'RG-loss.txt'};

pathToData='data';
myData = DataClass(pathToData);
myData.loadDataFiles(fnames);

%%
nSamples = 10^4;
nChains = 4;


%% TEST GAUSSIAN RANDOM WALK MODEL
grw = ModelGaussianRandomWalkSimple(toolboxPath,...
	'JAGS', myData,...
	'ModelGaussianRandomWalkSimple',...
	'pointEstimateType','mode');
grw.sampler.setMCMCtotalSamples(nSamples);
grw.sampler.setMCMCnumberOfChains(nChains);
grw.conductInference(); % TODO: Could return an MCMCFit object here ******
grw.plot()


% %% TEST GAUSSIAN RANDOM WALK MODEL
% grw = ModelGaussianRandomWalkComplex(toolboxPath,...
% 	'JAGS', myData,...
% 	'hierarchical_GRW',...
% 	'pointEstimateType','mode');
% grw.sampler.setMCMCtotalSamples(nSamples);
% grw.sampler.setMCMCnumberOfChains(nChains);
% grw.conductInference(); % TODO: Could return an MCMCFit object here ******
% grw.plot()
