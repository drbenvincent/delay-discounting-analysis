% Example use of the delay discounting analysis toolbox

%% Setup stuff
environment = ddAnalysisSetUp(...
	'toolboxPath', '~/git-local/delay-discounting-analysis/ddToolbox',...
	'projectPath', '~/git-local/delay-discounting-analysis/demo',...
	'dataPath', '~/git-local/delay-discounting-analysis/demo/data');

%% Load data
filesToAnalyse = allFilesInFolder(environment.dataPath, 'txt');
myData = DataClass(environment.dataPath);
myData.loadDataFiles(filesToAnalyse);


%% Run an analysis
numberOfMCMCSamples = 10^5; % set to 10^4 for faster, but less accurate inferences
saveFolder = 'methodspaper-kirby27';

hModel = ModelHierarchicalME('jags', myData, saveFolder,...
	'mcmcSamples', numberOfMCMCSamples,... % optional
	'chains', 4); % optional

hModel.conductInference();
hModel.exportParameterEstimates();
hModel.plot()


%% Example things you can now do

% Go and look at the plots and parameter estimates that were just saved

% Plot MCMC chains for diagnosic purposes
hModel.plotMCMCchains({'m','c'})
hModel.plotMCMCchains({'m_group','c_group', 'alpha_group', 'epsilon_group'})

% Get access to samples, put into a structure...
someSamples = hModel.mcmc.getSamples({'m','c'});

% ... to do thins like conduct hypothesis testing 
hypothesisTestScript(hModel)

% Calculate discount rates for a given reward magnitude (for magnitude
% effect models)
conditionalDiscountRateExample(hModel)