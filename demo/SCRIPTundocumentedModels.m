function SCRIPTundocumentedModels
% This script examines TWO models which are not documented in the paper,
% but which may be useful.
%
% The first (modelHierarchicalNOMAG) is based upon the modelHierarchical
% model, but which ignores the magnitude effect. It does not estimate a
% magnitide effect (parameters m, c) but instead just fits a single
% discount rate parameter (k).
%
% The second (modelHierarchicalMVN) is also based on modelHierarchical, but
% is more experimental. I thought that having a mutlivariate normal
% distribution over group-level parameters m & c might enable more prior
% knowledge to be provided. THIS MODEL DOES NOT CURRENTLY CONVERGE AND
% SHOULD NOT BE USED. I am experimenting with using STAN do conduct the
% MCMC inference and this MIGHT enable this model to converge.

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



%% UNDOCUMENTED

simpleModel = modelSimple(toolboxPath);
simpleModel.setMCMCtotalSamples(1000);
simpleModel.conductInference(singleData);
simpleModel.plot(singleData)



%% UNDOCUMENTED MODEL - DOESN'T APPEAR IN THE PAPER
% This model class (modelHierarchicalNOMAG) conducts hierarchical
% estimation, but it does not estimate a magnitude effect. It doesn't
% necessary assume that it does not exist, just that it does not try to
% estimate what the magnitude effect is. It on estimates a single log(k)
% parameter, it assumes it is constant over different reward magnitudes. 
%
% The main utility of this model is if you don't care about the magnitude
% effect, or if you have a monetary choice questionnaire with a fixed
% delayed reward protocol. If all the delayed reward magnitudes are the
% same, then you cannot do a good job of estimating the magnitude effect,
% and so this model is useful in that situation.

mNOMAG = modelHierarchicalNOMAG(toolboxPath);
mNOMAG.conductInference(kirbyData);
mNOMAG.plot(kirbyData)


return