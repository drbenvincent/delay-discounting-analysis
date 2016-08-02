classdef DataLegacy < handle
	%DataLegacy Should support older versions of Matlab without
	%Tables.

	properties (GetAccess = public, SetAccess = private)
		participantFilenames
		dataFolder
		nParticipants
		totalTrials
		IDname

		participantLevel

		groupTable
		observedData
	end


	methods (Access = public)

		% =================================================================
		function obj=DataLegacy(dataFolder)

			obj.dataFolder = dataFolder;
			display('You have created a Data object')
		end
		% =================================================================


		function [obj] = loadDataFiles(obj,fnames)
			% INPUT:
			% - fnames	a cell arrage of filenames of participant data

			obj.nParticipants = numel(fnames);
			obj.participantFilenames = fnames;

			for n=1:obj.nParticipants
				obj.IDname{n} = obj.extractParticipantInitialsFromFilename(fnames{n});
				participantStruct = obj.importParticipantData( fullfile(obj.dataFolder,fnames{n}) );
				participantStruct = obj.appendParticipantIDcolumn(participantStruct, n);
				obj.participantLevel(n).struct = participantStruct;
				obj.participantLevel(n).trialsForThisParticant = size(participantStruct.R,1);
			end

			obj.constructObservedDataForMCMC()
			obj.exportGroupDataFile()
			obj.totalTrials = numel(obj.groupTable.R);

			display('The following participant-level data files were imported:')
			display(fnames')
		end

		function exportGroupDataFile(obj)
			obj.buildGroupDataTable();
			saveLocation = fullfile(obj.dataFolder,'groupLevelData');
			if ~exist(saveLocation, 'dir'), mkdir(saveLocation), end
			obj.exportGroupData(obj.groupTable, fullfile(saveLocation,'COMBINED_DATA.txt'))
			fprintf('A copy of the group-level dataset just constructed has been saved as a text file:\n%s\n',...
				fullfile(saveLocation,'COMBINED_DATA.txt'));
		end

		function buildGroupDataTable(obj)
			% create a group level structure, fieldnames correspond to
			% columns.
			fieldnames = fields(obj.participantLevel(1).struct);
			for f = 1:numel(fieldnames)
				obj.groupTable.(fieldnames{f}) = [];
				for p=1:obj.nParticipants
					obj.groupTable.(fieldnames{f}) = ...
						[ obj.groupTable.(fieldnames{f}) ; ...
						obj.participantLevel(p).struct.(fieldnames{f})];
				end
			end
		end

		function [data] = getParticipantData(obj,participant)
			% grabs data just from one participant.
			% OUTPUTS:
			% a structure with fields
			%  - A, B, DA, DB, R, ID (all column vectors)
			%  - trialsForThisParticant (a single value)

			data = obj.participantLevel(participant).struct;

			data.trialsForThisParticant =...
				obj.participantLevel(participant).trialsForThisParticant;
		end

		function constructObservedDataForMCMC(obj)
			% construct a structure of ObservedData which will provide input to
			% the MCMC process.
			maxTrials = max([obj.participantLevel.trialsForThisParticant]);
			% create an empty matrix which we then fill with data.
			obj.observedData.A  = NaN(obj.nParticipants, maxTrials);
			obj.observedData.B  = NaN(obj.nParticipants, maxTrials);
			obj.observedData.DA = NaN(obj.nParticipants, maxTrials);
			obj.observedData.DB = NaN(obj.nParticipants, maxTrials);
			obj.observedData.R  = NaN(obj.nParticipants, maxTrials);
			for p=1:obj.nParticipants
				Tp = obj.participantLevel(p).trialsForThisParticant;
				obj.observedData.A(p,[1:Tp]) = obj.participantLevel(p).struct.('A');
				obj.observedData.B(p,[1:Tp]) = obj.participantLevel(p).struct.('B');
				obj.observedData.DA(p,[1:Tp]) = obj.participantLevel(p).struct.('DA');
				obj.observedData.DB(p,[1:Tp]) = obj.participantLevel(p).struct.('DB');
				obj.observedData.R(p,[1:Tp]) = obj.participantLevel(p).struct.('R');
			end

			% T is a vector containing number of trials for each participant
			obj.observedData.T = [obj.participantLevel.trialsForThisParticant];
		end

	end


	methods(Static)

		function participantInitials = extractParticipantInitialsFromFilename(fname)
			participantInitials = strtok(fname, '-');
		end

		function participantStruct = appendParticipantIDcolumn(participantStruct, n)
			nTrials = size(participantStruct.R,1);
			participantStruct.ID = ones( nTrials, 1) * n;
		end

		function participantStruct = importParticipantData(filePath)
			% tdfread imports into a structure, fields correspond to column
			% titles. Data in fields are column vectors
			participantStruct = tdfread(filePath);
		end

		function exportGroupData(groupStruct, savePath)
			tdfwrite(savePath, groupStruct);
		end

	end

end
