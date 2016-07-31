function [data, model] = run_me()
%RUN_ME
% The code in this function provides a simple example of how to analyse
% delay discounting data. To run your own analysis, you can make a copy of 
% this function and update as appropriate.
%
% Click this to run the demo code (it will take a while to compute)
% <a href="matlab:[data, model] = run_me();">[data, model] = run_me();</a>
%
% MAIN ANALYSIS PROCEDURE -------------------------------------------------
%
% 1) Set the path of the toolbox folder:
% >> addpath('~/git-local/delay-discounting-analysis/ddToolbox')
%
% 2) Run the toolbox setup code. This MUST be done once, at the start of
% each Matlab analysis session:
% >> ddAnalysisSetUp();
%
% 3) Load your data:
% >> datapath = '~/git-local/delay-discounting-analysis/demo/data';
% >> data = DataClass(datapath, 'files', allFilesInFolder(datapath, 'txt'));
%
% 4) Run an analysis:
% >> model = model.conductInference()
%
% Get help about the optional arguments when conducting inference:
% >> help Model.conductInference
%
%
% OPTIONAL EXTRAS ---------------------------------------------------------
%
% You can save the data and model objects as follows. You don't have to
% save the data, as it's stored internally in the model object. However it
% could be useful to store the data if you wanted to analyse with a
% different model.
% >> save('my_analysis.mat', 'data', 'model')
%
% And load it again at a later date with:
% >> clear, load('my_analysis.mat')
%
% Plotting: If you did not ask the conductInference() method to plot then 
% you can generate the plots by:
% >> model.plot()
%
% You can inspect MCMC chains for diagnostic purposes by:
% >> model.plotMCMCchains({'m','c'})
% 
% If you analysed your data with a model which accounts for the magnitude
% effect, then you may want to work out what the discount rate, log(k),
% might be for a given reward magnitude. You can do this by:
% >> conditionalDiscountRateExample(model)
%
% You can get access to samples using code such as the following. They will
% be returned into a structure:
% >> samples = model.mcmc.getSamples({'m','c','alpha','epsilon'});
%
% 
% You can do many things with the samples. By way of example, you could
% conduct Bayesian hypothesis testing. For details, see the contents of
% this function:
% >> hypothesisTestScript(model)
%
%
% MORE INFORMATION --------------------------------------------------------
% For more information, see <a href="matlab: 
% web('https://github.com/drbenvincent/delay-discounting-analysis/wiki')">the GitHub wiki</a> or just tweet me <a href="matlab:web('https://twitter.com/inferencelab')">@inferencelab</a>
% for help.
%
%
% See also: DataClass, Model

% --------- USE THE CODE BELOW AS A TEMPLATE FOR YOUR OWN ANALYSES --------

% USERS TO REPLACE THIS CODE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
path_of_this_mfile = strrep(which(mfilename),[mfilename '.m'],'');
toolbox_path = fullfile(path_of_this_mfile,'..','ddToolbox');
datapath = fullfile(path_of_this_mfile,'datasets','kirby');
% WITH THIS (update the paths as appropriate) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% addpath('~/git-local/delay-discounting-analysis/ddToolbox')
% datapath = '~/git-local/delay-discounting-analysis/demo/data';
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Run setup routine
addpath(toolbox_path)
ddAnalysisSetUp();

% Load data
data = DataClass(datapath, 'files', allFilesInFolder(datapath, 'txt'));

% Create an analysis model
model = ModelHierarchicalME(data,...
	'saveFolder', 'analysis_with_hierarchical_magnitude_effect',...
	'pointEstimateType','median');

% Do some Bayesian inference (All arguments to this function are optional)
model = model.conductInference(...
	'sampler', 'stan',...					% {'jags', 'stan'}
	'shouldPlot', 'no',...					% {'no', 'yes'}
	'mcmcSamples', 10^5,...					% default is ???????????
	'chains', 4,...							% default is ???
	'burnin', 15000);						% default is ?????

%model.plot()
