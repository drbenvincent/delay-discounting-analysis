function SCRIPT
% code used in the preparation of the paper

%% Preamble
% When you download and use this code, you will have to update these paths
% to the code you just downloaded. Wherever you put the code, we need to be
% pointed to */ddToolbox and */demo

% The ddToolbox folder contains the main analysis code. This is essential
% for using the software on your own dataset.
toolboxPath = '/Users/benvincent/git-local/delay-discounting-analysis/ddToolbox';
addpath(genpath(toolboxPath)) 

% When you want to run the analysis on your own code, then you must update
% this path to point at the appropriate folder. This must be arranged in
% the same way as in the demo folder. In other words, we need participant
% data files in a folder called data, and a matlab script in the root demo
% folder (or whatever your project folder is called).
projectPath = '/Users/benvincent/git-local/delay-discounting-analysis/demo';
cd(projectPath)

% set some graphics preferences
setPlotTheme

%% Create data object

% create a cell array of which participant files to import
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
% Participant-level data will be aggregated into a larger group-level text
% file and saved in \data\groupLevelData for inspection. Choose a
% meaningful filename for this group-level data. This data is not used, it
% is just provided so you can confirm everything is working properly.
saveName = 'methodspaper-kirby27.txt';

% create the group-level data object
kirbyData = dataClass(saveName);
kirbyData.loadDataFiles(fnames);


%% Analyse the data with the hierarchical model

% First we create a model object, which we will call hModel. This is an
% instance of the class 'modelHierarchical'
hModel = modelHierarchical(toolboxPath);

% Here we should change default parameters
hModel.setMCMCtotalSamples(500000); % default is 100,000

% This will initiate MCMC sampling. This can take some time to run,
% depending on number of samples, chains, computer speed and cores etc.
% It's probably best to start with a low number of MCMC samples to get a
% feel for how long the sampling takes.
hModel.conductInference(kirbyData);

% Plot all the results
hModel.plot(kirbyData)

%% Example research conclusions...

% Calculate Bayes Factor, and plot 95% CI on the posterior
hModel.HTgroupSlopeLessThanZero(kirbyData)

% Modal values of m_p for all participants
% Export these point estimates into a text file and analyse with JASP
hModel.analyses.univariate.m.mode'


return