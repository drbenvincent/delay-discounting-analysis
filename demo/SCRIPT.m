function SCRIPT
% code used in the preparation of the paper

%% Preamble
% When you download and use this code, you will have to update these paths
% to the code you just downloaded. Wherever you put the code, we need to be
% pointed to */ddToolbox and */demo

% The ddToolbox folder contains the main analysis code. This is essential
% for using the software on your own dataset.
try
	% *** SET THIS TO THE PATH OF THE /ddToolbox FOLDER ***
	toolboxPath = '/Users/benvincent/git-local/delay-discounting-analysis/ddToolbox';
	% check that this folder exists
	if exist(toolboxPath,'dir')~=7
		error('change the toolboxPath to point to the folder /ddToolbox')
	end
	addpath(genpath(toolboxPath))
catch
	error('change the toolboxPath to point to the folder /ddToolbox')
end

% When you want to run the analysis on your own code, then you must update
% this path to point at the appropriate folder. This must be arranged in
% the same way as in the demo folder. In other words, we need participant
% data files in a folder called data, and a matlab script in the root demo
% folder (or whatever your project folder is called).
try
	% *** SET THIS TO THE PATH OF THE /ddToolbox FOLDER ***
	projectPath = '/Users/benvincent/git-local/delay-discounting-analysis/demo';
	cd(projectPath)
catch
	error('change the projectPath to point to the folder /delay-discounting-analysis/demo')
end	

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
pathToData='data';
myData = dataClass(saveName,pathToData);
myData.loadDataFiles(fnames);

% It is important to visualise your participant data. It may well be that
% some participant's have produced meaningless data, in which case you may
% want to discard these participants at this stage. The quickAnalysis()
% method of the dataClass provides some simple visualisation and analysis.
myData.quickAnalysis();

%% Analyse the data with the hierarchical model

% First we create a model object, which we will call hModel. This is an
% instance of the class 'modelHierarchical'
hModel = modelHierarchical(toolboxPath);

% Here we should change default parameters
hModel.setMCMCtotalSamples(5000); % default is 10^5
% If you have more than 2 cores on your machine you can uncomment this next
% line
%hModel.setMCMCnumberOfChains(4);

% This will initiate MCMC sampling. This can take some time to run,
% depending on number of samples, chains, computer speed and cores etc.
% It's probably best to start with a low number of MCMC samples to get a
% feel for how long the sampling takes.
hModel.conductInference(myData);

% Export posterior mode (and credible intervals) of all parameter and group
% level parameters to a text file
hModel.exportParameterEstimates(myData);

% Plot all the results
hModel.plot(myData)

%% Example research conclusions...

% Calculate Bayes Factor, and plot 95% CI on the posterior
hModel.HTgroupSlopeLessThanZero(myData)

% Summary information of the group and participant level infererences are
% stored in a structure in the model object, eg:
%  hModel.analyses.univariate
% So if you wanted to find the group level posterior mode for the slope of
% the magnitude effect, you can type:
%	hModel.analyses.univariate.glM
%	hModel.analyses.univariate.glM.CI95
% and if you wanted estimates for each participant, for example the slope
% of the magnitude effect, then you can type:
%	hModel.analyses.univariate.m.mode'

% Modal values of m_p for all participants
% Export these point estimates into a text file and analyse with JASP
%	hModel.analyses.univariate.m.mode'
%	hModel.analyses.univariate.m.CI95'

% This information can be more neatly arranged by putting into a Matlab
% table, for example
participant_level_m = array2table([hModel.analyses.univariate.m.mode' hModel.analyses.univariate.m.CI95'],...
	'VariableNames',{'posteriorMode' 'CI5' 'CI95'})


%% Discount rate for a particular reward magnitude
% You may be interested in the discount rate (at the group and participant
% levels) at a particular reward magnitude. The method
% conditionalDiscountRatePlots() plots participant and group level
% conditional posterior (predictive) distributions. That is...
% The posterior distribution of discount rate (log(k)) for a given reward
% magnitude.

% Below we calculate and plot the discount rates for reward magnitudes of
% £100 and £1,000

figure(1), clf
plotFlag=true;
ax(1) = subplot(1,2,1);
hModel.conditionalDiscountRates(100, plotFlag);
ax(2) = subplot(1,2,2);
hModel.conditionalDiscountRates(1000, plotFlag);
linkaxes(ax,'xy')

return