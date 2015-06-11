function testHierarchicalError
% Script used for the paper

close all

clear, clc

%% Preamble
% Path containing the package
toolboxPath = '/Users/benvincent/git-local/delayDiscounting/ddToolbox';
addpath(genpath(toolboxPath)) % add folder AND subfolders to path

% Project path
projectPath = '/Users/benvincent/git-local/delayDiscounting/demo';
% go to project path and 
cd(projectPath)


%% Create data object

% Step 1. Create a data object
fnames={'AC-kirby27-DAYS.txt',...
'CS-kirby27-DAYS.txt',...
'NA-kirby27-DAYS.txt',...
'SB-kirby27-DAYS.txt',...
'bv-kirby27.txt',...
'rm-kirby27.txt',...
'vs-kirby27.txt'};
saveName = 'methodspaper-kirby27.txt';

% create the group-level data object
kirbyData = data(fnames, saveName);





%% Analyse the data with the multi-level hierarchical model

% Step 2. Create model object
hModel = modelHierarchical(1, toolboxPath);

% Step 3: initiate inference, given the data object
hModel = hModel.conductInference(kirbyData);

% Step 4: run some analyses
hModel = hModel.doAnalysis();

% Step 5: analyse & plot
hModel.plot(kirbyData)



%% Now analyse the same data but with non-hierarchical (independent params) model

% create model object
sep = modelSeperate(1, toolboxPath);

% conduct inference on the data
sep = sep.conductInference(kirbyData);

% Conduct analyses
sep = sep.doAnalysis();

% Step 4: analyse & plot
sep.plot(kirbyData)						% plot everything
%sep.myHDIboxplotWrapper(kirbyData);	% plot the summary figures




%% Now do meta-analysis by comparing univariate values from each model

clear univariate
univariate(1) = hModel.analyses.univariate;
univariate(2) = sep.analyses.univariate;
% -----------------------------------
stackedGroupedForestPlot2(univariate)
% stackedGroupedForestPlot(hModel.analyses.univariate,...
% 	sep.analyses.univariate)
% EXPORTING -------------------------
latex_fig(16, 5, 8)
myExport([], [], 'CompareModels-summaryStats')
% -----------------------------------


return