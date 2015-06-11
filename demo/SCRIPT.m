function SCRIPT
% code used in the preparation of the paper

%% Preamble
toolboxPath = '/Users/benvincent/git-local/delayDiscounting/ddToolbox';
addpath(genpath(toolboxPath)) 

projectPath = '/Users/benvincent/git-local/delayDiscounting/demo';
cd(projectPath)


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
% meaningful filename for this group-level data
saveName = 'methodspaper-kirby27.txt';

% create the group-level data object
kirbyData = dataClass(saveName);
kirbyData.loadDataFiles(fnames);


%% Analyse the data with the hierarchical model

hModel = modelHierarchical(toolboxPath);
% change defaults
hModel.setMCMCtotalSamples(500000); % default is 100,000

hModel.conductInference(kirbyData);
% plot all the results
hModel.plot(kirbyData)
% Calculate + plot Bayes Factor for G^m < 0
hModel.HTgroupSlopeLessThanZero(kirbyData)



% Modal values of m_p for all participants
% Export these point estimates into a text file and analyse with JASP
hModel.analyses.univariate.m.mode'














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