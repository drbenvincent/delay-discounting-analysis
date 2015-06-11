function SCRIPT_grid
% code used in the preparation of the paper

%% Preamble
toolboxPath = '/Users/benvincent/git-local/delayDiscounting/ddToolbox';
addpath(genpath(toolboxPath)) 

projectPath = '/Users/benvincent/git-local/delayDiscounting/demo';
cd(projectPath)



%% Create data object

% create a cell array of which participant files to import
fnames={'bv-BSLICES.txt',...
'rm-BSLICES.txt',...
'vs-BSLICES'};
% Participant-level data will be aggregated into a larger group-level text
% file and saved in \data\groupLevelData for inspection. Choose a
% meaningful filename for this group-level data
saveName = 'methodspaper-grid.txt';

% create the group-level data object
gridData = dataClass(saveName);
gridData.loadDataFiles(fnames);


%% Analyse the data with the hierarchical model

gModel = modelHierarchical(toolboxPath);
% change some options
gModel.setMCMCtotalSamples(50000);
gModel.setBurnIn(10000);
gModel.setMCMCnumberOfChains(2);

gModel.conductInference(gridData);
gModel.plot(gridData)










%% Analyse the same data but with non-hierarchical (independent params) model
% 
% sep = modelSeperate(toolboxPath);
% sep.setMCMCtotalSamples(10000);
% sep.conductInference(kirbyData);
% sep.plot(kirbyData)
% 
% 
%% Now do meta-analysis by comparing univariate values from each model
% clear univariate
% univariate(1) = hModel.analyses.univariate;
% univariate(2) = sep.analyses.univariate;
% % -----------------------------------
% figGroupedForestPlot(univariate)
% % EXPORTING -------------------------
% latex_fig(16, 5, 8)
% myExport([], [], 'CompareModels-summaryStats')
% % -----------------------------------

return