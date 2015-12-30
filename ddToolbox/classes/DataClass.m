classdef DataClass < handle
	%data A class to load and handle data
	%   Detailed explanation goes here

	properties (GetAccess = public, SetAccess = private)
		participantFilenames
		dataFolder
		nParticipants
		totalTrials
		IDname

		participantLevel
		covariateSupplied
		%covariateProbeVals

		groupTable
		observedData

		saveName
	end


	methods (Access = public)

		% =================================================================
		function obj=DataClass(saveName, dataFolder)
			% create empty tables
			obj.groupTable = table();
			obj.participantLevel(1).table = table();
			% where the data is
			obj.dataFolder = dataFolder;
			% by default assume we do not have any covariate data
			obj.covariateSupplied = false;
			% create a savename
			[PATHSTR,NAME,EXT] = fileparts(saveName);
			obj.saveName = NAME;
			display('You have created a DataClass object')
		end
		% =================================================================


		function [obj] = loadDataFiles(obj,fnames)
			% fnames should be a cell array of filenames

			% TODO: TIDY UP WHAT IS HAPPENING HERE

			for n=1:numel(fnames) % loop over fnames, each time importing
				fname = fnames{n};
				% Load tab separated .txt file with rows labelled: A, B, D, R. This
				% will load the data into T, which is a 'table' data type, see:
				% http://uk.mathworks.com/help/matlab/tables.html
				rawData = readtable(fullfile(obj.dataFolder,fname), 'delimiter','tab');

				% add a new column defining the participant ID
				ID = ones( height(rawData), 1) * n;
				participantTable = [rawData table(ID)];

				% add column of participant filenames (all identical
				% entries) for easier identification of participants in
				% plots
				participantInitials = strtok(fnames{n}, '-');
				obj.IDname{n} = participantInitials;
				% TODO: Don't need the 2 lines below, but keep for
				% reference in case it's useful.
				%IDname = table(repmat(participantInitials,height(rawData),1), 'VariableNames',{'IDname'});
				%participantTable = [participantTable IDname];

				% complete participant level data
				obj.participantLevel(n).table = participantTable;
				obj.participantLevel(n).trialsForThisParticant = height(participantTable);
				obj.participantLevel(n).data.A = obj.participantLevel(n).table.A;
				obj.participantLevel(n).data.B = obj.participantLevel(n).table.B;
				obj.participantLevel(n).data.DA = obj.participantLevel(n).table.DA;
				obj.participantLevel(n).data.DB = obj.participantLevel(n).table.DB;
				obj.participantLevel(n).data.R = obj.participantLevel(n).table.R;
				obj.participantLevel(n).data.ID = obj.participantLevel(n).table.ID;

				% append participant to group table
				obj.groupTable = [obj.groupTable;participantTable];
			end
			
			% CREATE UNKNOWN PARTICIPANT HERE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			n = numel(fnames)+1;
			obj.IDname{n} = 'UNKNOWN';
			obj.participantLevel(n).table = [];
			obj.participantLevel(n).trialsForThisParticant=1;
			obj.participantLevel(n).data.A = 1;
			obj.participantLevel(n).data.B = 2;
			obj.participantLevel(n).data.DA = 0;
			obj.participantLevel(n).data.DB = 1;
			obj.participantLevel(n).data.R = NaN;
			obj.participantLevel(n).data.ID = obj.IDname{n};
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			%% Copy the observed data into a structure
			maxTrials = max([obj.participantLevel.trialsForThisParticant]);
			nParticipants = numel(obj.participantLevel);
			% create an empty matrix which we then fill with data
			obj.observedData.A  = NaN(nParticipants, maxTrials);
			obj.observedData.B  = NaN(nParticipants, maxTrials);
			obj.observedData.DA = NaN(nParticipants, maxTrials);
			obj.observedData.DB = NaN(nParticipants, maxTrials);
			obj.observedData.R  = NaN(nParticipants, maxTrials);
			for p=1:nParticipants
				Tp = obj.participantLevel(p).trialsForThisParticant;
				obj.observedData.A(p,[1:Tp]) = obj.participantLevel(p).data.A;
				obj.observedData.B(p,[1:Tp]) = obj.participantLevel(p).data.B;
				obj.observedData.DA(p,[1:Tp]) = obj.participantLevel(p).data.DA;
				obj.observedData.DB(p,[1:Tp]) = obj.participantLevel(p).data.DB;
				obj.observedData.R(p,[1:Tp]) = obj.participantLevel(p).data.R;
			end
			
% 			% we need to provide some fake question data to the made up
% 			% participant. We need to do this because the values feed into the
% 			% deterministic nodes (VA and VB).
% 			obj.observedData.A(end,1)=1;
% 			obj.observedData.B(end,1)=2;
% 			obj.observedData.DA(end,1)=0;
% 			obj.observedData.DB(end,1)=1;
			
			% T is a vector containing number of trials for each participant
			obj.observedData.T = [obj.participantLevel.trialsForThisParticant];

			% calculate more things
			obj.totalTrials = height(obj.groupTable);
			obj.nParticipants = nParticipants; 
			obj.participantFilenames = fnames;

			% by default, assume we do not have any covariate data
			obj.covariateSupplied = false;
% 			% set all covariate values to zero
% 			covariateValues = zeros([1, obj.nParticipants]);
% 			obj.setCovariateValues(covariateValues);

			% save
			saveLocation = fullfile(obj.dataFolder,'groupLevelData');
			if ~exist(saveLocation, 'dir'), mkdir(saveLocation), end
			writetable(obj.groupTable,...
				fullfile(saveLocation,obj.saveName),...
				'delimiter','tab')
			fprintf('A copy of the group-level dataset just constructed has been saves as a text file:\n%s\n',...
				fullfile(saveLocation,obj.saveName));

			display('The following participant-level data files were imported:')
			display(fnames')
		end


		function [data] = getParticipantData(obj,participant)
			% grabs data just from one participant.
			data = obj.participantLevel(participant).data;
			data.trialsForThisParticant =...
				obj.participantLevel(participant).trialsForThisParticant;
		end


		% function [obj] = addData(obj, thisTrialData)
		% 	% adds one trial worth of data
		% 	% we assume this is happening in the context of live fitting
		% 	% during an adaptive experimental procedure, so we are only
		% 	% dealing with one participant

		% 	% append to bottom of table
		% 	obj.participantLevel(1).table = [obj.participantLevel(1).table ; thisTrialData];

		% 	% copy to groupTable
		% 	obj.groupTable = obj.participantLevel(1).table;

		% 	% Copy the observed data into a structure
		% 	obj.observedData.A = obj.groupTable.A;
		% 	obj.observedData.B = obj.groupTable.B;
		% 	obj.observedData.DA = obj.groupTable.DA;
		% 	obj.observedData.DB = obj.groupTable.DB;
		% 	obj.observedData.R = obj.groupTable.R;
		% 	%obj.observedData.ID = obj.groupTable.ID;

		% 	% calculate more things
		% 	obj.totalTrials = height(obj.groupTable);
		% 	obj.nParticipants = 1;
		% end


		%% DEPRICATED
		% function quickAnalysis(obj)
		% 	% *********
		% 	% NOTE TO SELF: This function needs to be improved. I need to
		% 	% plug in plotting functions for:
		% 	% - discount function plots when all DA==0
		% 	% - discount surface plots when not all DA==0
		% 	% *********
		%
		% 	for n=1:obj.nParticipants
		% 		datap = getParticipantData(obj, n);
		% 		[logk, kvec, prop_explained] = obj.quickAndDirtyEstimateOfLogK(datap);
		%
		% 		figure(1), clf, drawnow
		% 		subplot(1,2,1) % plot raw data
		% 		plot3DdataSpace(datap, []);
		%
		% 		subplot(1,2,2) % plot quick & dirty analysis
		% 		semilogx(kvec, prop_explained)
		% 		axis tight
		% 		ylim([0 1])
		% 		vline(exp(logk));
		% 		title(['particpant ' num2str(n)])
		% 		xlabel('discount rate (k)')
		% 		ylabel({'proportion of responses consistent with';'1-param hyperbolic discount function'})
		% 		axis square
		% 		% EXPORTING ---------------------
		% 		figure(1)
		% 		latex_fig(16, 8, 6)
		% 		myExport(obj.saveName, 'dataSummary-', ['participant' num2str(n)]);
		% 		% -------------------------------
		% 	end
		% end


% 		function obj = setCovariateValues(obj,covariateValues)
% 			% set the values
% 			obj.observedData.covariate = covariateValues;
% 			% If the values are not all zero, then we are dealing with a
% 			% dataset where meaningful covariate data has been provided.
% 			if sum((covariateValues==0)~=1) > 0
% 				display('COVARIATE DATA SUPPLIED')
% 				obj.covariateSupplied = true;
% 				% create a vector of probe covariate values for
% 				% visualisation purposes
% 
% 				% set default values
% 				obj.observedData.covariateProbeVals = linspace( min(covariateValues), max(covariateValues) ,20);
% 			else
% 				display('COVARIATE DEFINED AS NOT PRESENT')
% 			end
% 		end


% 		function obj = setCovariateProbeValues(obj, CovariateProbeValues)
% 			obj.observedData.covariateProbeVals = CovariateProbeValues;
% 		end

	end


	methods(Static)
		%% DEPRICATED
		% function [logk, kvec, prop_explained] = quickAndDirtyEstimateOfLogK(data)
		% 	% Given the response data for this participant, do a very quick and dirty
		% 	% estimate of the likely log discount rate (logk). This is used as initial
		% 	% parameters for the MCMC process.
		%
		% 	%% 1-parameter hyperbolic discount function --------------------------------
		% 	% v = b ./ (1+(k*d)
		% 	% NOTE: This functions wants the discount rate (k), NOT the log(k)
		% 	V = @(d,k,b) bsxfun(@rdivide, b, 1+bsxfun(@times,k,d) );
		%
		% 	%% vector of discount rates (k) to examine ---------------------------------
		% 	kvec = logspace(-8,2,1000);
		%
		% 	presentSubjectiveValue = V( data.DB, kvec, data.B);
		% 	chooseDelayed = bsxfun(@minus, presentSubjectiveValue, data.A) >1;
		% 	err = bsxfun(@minus, data.R, chooseDelayed);
		% 	err = sum(abs(err));
		%
		% 	% calc proportion of responses explained
		% 	prop_explained = (data.trialsForThisParticant - err) / data.trialsForThisParticant;
		%
		% 	%[~, index] = max(prop_explained);
		% 	k_optimal = kvec( argmax(prop_explained) );
		% 	logk = log(k_optimal);
		% end
	end

end
