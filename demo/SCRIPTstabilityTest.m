function SCRIPTstabilityTest
% tests the stability of the inferences made

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
kirbyData = DataClass(saveName);
kirbyData.loadDataFiles(fnames);


%% CHECK THE STABILITY OF THE INFERENCES ---------------------------
% Of the Hierarchical model
% We will use the same data, and fit multiple identical models to that
% data. We can then plot the variability in the inferences made to see how
% reliable the inferences are.
N=7; % fit the same data this many times
for n=1:N
	display(['Hierarchical model ' num2str(n),' of ' num2str(N)])
	
	tempModel = ModelHierarchical(toolboxPath);
	tempModel.conductInference(kirbyData);
	
	% thow the model away, just store the univariate analysis
	univariate(n) = tempModel.analyses.univariate;
	clear tempModel
end
figGroupedForestPlot(univariate)
% EXPORTING -------------------------
latex_fig(16, 8, 9)
myExport([], [], 'hierarchical-reliability-summaryStats')
% -----------------------------------

% ***************************************************** 
% Now do the same, but for the seperate-parameter model
for n=1:N
	display(['Separate model ' num2str(n),' of ' num2str(N)])
	
	tempModel = ModelSeperate(toolboxPath);
	tempModel.conductInference(kirbyData);
	
	% thow the model away, just store the univariate analysis
	univariate(n) = tempModel.analyses.univariate;
	clear tempModel
end
figGroupedForestPlot(univariate)
% EXPORTING -------------------------
latex_fig(16, 8, 9)
myExport([], [], 'separate-reliability-summaryStats')
% -----------------------------------

