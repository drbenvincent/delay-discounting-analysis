%% Example use of the delay discounting analysis toolbox

% Add toolbox path and run setup routine
addpath('~/git-local/delay-discounting-analysis/ddToolbox')
ddAnalysisSetUp();

% Load data
datapath = '~/git-local/delay-discounting-analysis/demo/data';
myData = DataClass(datapath,...
	'files', allFilesInFolder(datapath, 'txt'));

% Create an analysis model
hModel = ModelHierarchicalME(myData,...
	'saveFolder', 'analysis_with_hierarchical_magnitude_effect',...
	'pointEstimateType','median');

% Do some Bayesian inference with JAGS or STAN
hModel = hModel.conductInference('jags',... % {'jags', 'stan'}
	'shouldPlot', 'no',...
	'mcmcSamples', 10^4); % TODO: add mcmcparams over-ride



%% Example things you can now do ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% If you did not opt to plot the outputs following inference, you can call:
hModel.plot()

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