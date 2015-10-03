classdef dataClass < handle
	%data A class to load and handle data
	%   Detailed explanation goes here

	
	properties (GetAccess = public, SetAccess = private)
		participantFilenames
		
		nParticipants
		totalTrials
		
		participantLevel
		covariateSupplied
		covariateProbeVals
		
		groupTable
		observedData
		
		saveName
	end



	methods (Access = public)

		% =================================================================
		function obj=dataClass(saveName)
			% create empty tables
			obj.groupTable = table();
			obj.participantLevel(1).table = table();
			
			% by default assume we do not have any covariate data
			obj.covariateSupplied = false;

			% create a savename
			[PATHSTR,NAME,EXT] = fileparts(saveName);
			obj.saveName = NAME;
			display('You have created a dataClass object')
		end
		% =================================================================
		
		
		function [obj] = loadDataFiles(obj,fnames)
			% fnames should be a cell array of filenames
			
			for n=1:numel(fnames) % loop over fnames, each time importing
				
				fname = fnames{n};
				
				% Load tab separated .txt file with rows labelled: A, B, D, R. This
				% will load the data into T, which is a 'table' data type, see:
				% http://uk.mathworks.com/help/matlab/tables.html
				rawData = readtable(fullfile('data',fname), 'delimiter','tab');
				
				% add a new column defining the participant ID
				ID = ones( height(rawData), 1) * n;
				participantTable = [rawData table(ID)];
				
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
			
			%% Copy the observed data into a structure
			maxTrials = max([obj.participantLevel.trialsForThisParticant]);
			nParticipants = numel(obj.participantLevel);
			% create an empty matrix which we then fill with data
			obj.observedData.A = NaN(nParticipants, maxTrials);
			for p=1:nParticipants
				Tp = obj.participantLevel(p).trialsForThisParticant;
				obj.observedData.A(p,[1:Tp]) = obj.participantLevel(p).data.A;
				obj.observedData.B(p,[1:Tp]) = obj.participantLevel(p).data.B;
				obj.observedData.DA(p,[1:Tp]) = obj.participantLevel(p).data.DA;
				obj.observedData.DB(p,[1:Tp]) = obj.participantLevel(p).data.DB;
				obj.observedData.R(p,[1:Tp]) = obj.participantLevel(p).data.R;
			end
			% T is a vector containing number of trials for each participant
			obj.observedData.T = [obj.participantLevel.trialsForThisParticant];
			
% 			% Copy the observed data into a structure
% 			%obj.observedData = table2struct(obj.groupTable);
% 			obj.observedData.A = obj.groupTable.A;
% 			obj.observedData.B = obj.groupTable.B;
% 			obj.observedData.DA = obj.groupTable.DA;
% 			obj.observedData.DB = obj.groupTable.DB;
% 			obj.observedData.R = obj.groupTable.R;
% 			obj.observedData.ID = obj.groupTable.ID;

			
			% calculate more things
			obj.totalTrials = height(obj.groupTable);
			obj.nParticipants = max(obj.groupTable.ID);
			obj.participantFilenames = fnames;
			
			
			% by default assume we do not have any covariate data
			obj.covariateSupplied = false;
			% set all covariate values to zero
			covariateValues = zeros([1, obj.nParticipants]);
			obj.setCovariateValues(covariateValues);

			
			% save
			st=cd;
			cd('data')
			mkdir('groupLevelData')
			writetable(obj.groupTable,obj.saveName,...
				'delimiter','tab')
			fprintf('A copy of the group-level dataset just constructed has been saves as a text file:\n%s\n',...
				fullfile(pwd,obj.saveName));
			cd(st)
			
			display('The following participant-level data files were imported:')
			display(fnames')
		end
		
		
		
		
		% 		function T = loadFile(obj, fname)
		% 			% Load tab separated .txt file with rows labelled: A, B, D, R. This
		% 			% will load the data into T, which is a 'table' data type, see:
		% 			% http://uk.mathworks.com/help/matlab/tables.html
		% 			T = readtable(fullfile('data',fname), 'delimiter','tab');
		% 		end
		
		
		function [data] = getParticipantData(obj,participant)
			% grabs data just from one participant.
			data = obj.participantLevel(participant).data;
			data.trialsForThisParticant =...
				obj.participantLevel(participant).trialsForThisParticant;
		end
		
		
		
		
		function [obj] = addData(obj, thisTrialData)
			% adds one trial worth of data
			% we assume this is happening in the context of live fitting
			% during an adaptive experimental procedure, so we are only
			% dealing with one participant
			
			% append to bottom of table
			obj.participantLevel(1).table = [obj.participantLevel(1).table ; thisTrialData];
			
			% copy to groupTable
			obj.groupTable = obj.participantLevel(1).table;
			
			% Copy the observed data into a structure
			obj.observedData.A = obj.groupTable.A;
			obj.observedData.B = obj.groupTable.B;
			obj.observedData.DA = obj.groupTable.DA;
			obj.observedData.DB = obj.groupTable.DB;
			obj.observedData.R = obj.groupTable.R;
			%obj.observedData.ID = obj.groupTable.ID;
			
			% calculate more things
			obj.totalTrials = height(obj.groupTable);
			obj.nParticipants = 1;
		end
		
				
		
		
		function quickAnalysis(obj)
			
			% Here we are going to look over participants
			% - create an overview plot of all participants
			% - create participant level plots of data etc
			figure(1), clf
			figure(2), clf
			cols = 4;
			rows = obj.nParticipants / cols;
			%z=ceil(sqrt(obj.nParticipants));
			
			for n=1:obj.nParticipants
				% COMPUTE
				datap = getParticipantData(obj, n);
				[logk, kvec, err] = quickAndDirtyEstimateOfLogK(datap);
				
				% ADD TO OVERVIEW PLOT
				figure(1)
				subplot(cols,rows,n)
				semilogx(kvec, err)
				axis tight
				ylim([0 obj.participantLevel(n).trialsForThisParticant])
				vline(exp(logk));
				title(['particpant ' num2str(n)])
				set(gca,'XTick',logspace(-5,2,8))
				
				% PARTICIPANT PLOT
				figure(2), clf
				subplot(1,2,1)
				plotRawDataNOMAG(datap), axis square
				subplot(1,2,2)
				semilogx(kvec, err)
				axis tight
				ylim([0 obj.participantLevel(n).trialsForThisParticant])
				vline(exp(logk));
				title(['particpant ' num2str(n)])
				axis square
				% EXPORTING ---------------------
				figure(2)
				latex_fig(16, 8, 6)
				myExport(obj.saveName, 'dataSummary-', ['participant' num2str(n)])
				% -------------------------------
			
			end
			
			% EXPORTING ---------------------
			figure(1)
			latex_fig(16, 8, 6)
			myExport(obj.saveName, 'dataSummary-', [])
			% -------------------------------

		end
		
		
		
		function obj = setCovariateValues(obj,covariateValues)
			% set the values
			obj.observedData.covariate = covariateValues;	
			% If the values are not all zero, then we are dealing with a 
			% dataset where meaningful covariate data has been provided.
			if sum((covariateValues==0)~=1) > 0 
				display('COVARIATE DATA SUPPLIED')
				obj.covariateSupplied = true;
				% create a vector of probe covariate values for
				% visualisation purposes
				
				% set default values
				obj.observedData.covariateProbeVals = linspace( min(covariateValues), max(covariateValues) ,20);
			else
				display('COVARIATE DEFINED AS NOT PRESENT')
			end
		end
		
		function obj = setCovariateProbeValues(obj, CovariateProbeValues)
			obj.observedData.covariateProbeVals = CovariateProbeValues;
		end
		
		
		
	end

end
