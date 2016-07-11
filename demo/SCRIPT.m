%% Example use of the delay discounting analysis toolbox

% Setup stuff
environment = ddAnalysisSetUp(...
	'toolboxPath', '~/git-local/delay-discounting-analysis/ddToolbox',...
	'projectPath', '~/git-local/delay-discounting-analysis/demo',...
	'dataPath', '~/git-local/delay-discounting-analysis/demo/data');

% Load data
myData = DataClass(environment.dataPath,...
	'files', allFilesInFolder(environment.dataPath, 'txt'));

% Run an analysis
saveFolder = 'methodspaper-kirby27';

hModel = ModelHierarchicalME('jags', myData, saveFolder,...
	'mcmcSamples', 10^5,... 
	'chains', 4,...
	'shouldPlot','all');
hModel.conductInference();




%% Example things you can now do

% Plot MCMC chains for diagnosic purposes
hModel.plotMCMCchains({'m','c'})
hModel.plotMCMCchains({'m_group','c_group', 'alpha_group', 'epsilon_group'})

% Get access to samples, put into a structure...
someSamples = hModel.mcmc.getSamples({'m','c'});

% ... to do things like conduct hypothesis testing 
hypothesisTestScript(hModel)

% Calculate discount rates for a given reward magnitude (for magnitude
% effect models)
conditionalDiscountRateExample(hModel)