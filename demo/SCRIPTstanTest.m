function SCRIPTstanTest
% Testing the experimental support for doing MCMC sampling with STAN

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





% %% Create single-observer data object
% fnames={'bv-kirby27.txt'};
% saveName = 'testing.txt';
% % create the data object
% singleData = dataClass(saveName);
% singleData.loadDataFiles(fnames);


%% SIMPLE MODEL -----------------------------------
stanTestModel = modelSimple(toolboxPath);
stanTestModel.setSampler('STAN');
stanTestModel.setMCMCtotalSamples(50000);
stanTestModel.conductInference(singleData);
stanTestModel.plot(singleData)


%% SEPERATE MODEL -----------------------------------
stanTestModel = modelSeperate(toolboxPath);
stanTestModel.setMCMCtotalSamples(1000);
stanTestModel.conductInference(singleData);
stanTestModel.plot(singleData)


return