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

		groupTable
		observedData
	end


	methods (Access = public)

		% =================================================================
		function obj=DataClass(dataFolder)
			try
				table();
			catch
				error( strcat('ERROR: This version of Matlab does not support the Table data type. ',...
					'You will need to call DataClassLegacy() instead of DataClass().'))
			end
			obj.dataFolder = dataFolder;
			display('You have created a Data object')
		end
		% =================================================================


		function [obj] = loadDataFiles(obj,fnames)
			% INPUT:
			% - fnames	a cell arrage of filenames of participant data

			obj.nParticipants = numel(fnames);
			obj.participantFilenames = fnames;

			fnameType = 'all'; % {'all', 'ID'}
			for n=1:obj.nParticipants
				switch fnameType
					case {'all'}
						[~,obj.IDname{n},~] = fileparts(fnames{n}); % just get filename
					case{'ID'}
						obj.IDname{n} = getPrefixOfString(fnames{n},'-')
				end
				%obj.IDname{n} = obj.extractParticipantInitialsFromFilename(fnames{n});
				%obj.IDname{n} = obj.extractIDfromFilename(fnames{n});
				participantTable = readtable(fullfile(obj.dataFolder,fnames{n}), 'delimiter','tab');
				participantTable = obj.appendParticipantIDcolumn(participantTable, n);
 				obj.participantLevel(n).table = participantTable;
 				obj.participantLevel(n).trialsForThisParticant = height(participantTable);
			end

			obj.constructObservedDataForMCMC()
			obj.exportGroupDataFile()
			obj.totalTrials = height(obj.groupTable);

			display('The following participant-level data files were imported:')
			display(fnames')
		end

		function exportGroupDataFile(obj)
			obj.buildGroupDataTable();
			saveLocation = fullfile(obj.dataFolder,'groupLevelData');
			if ~exist(saveLocation, 'dir'), mkdir(saveLocation), end
			writetable(obj.groupTable,...
				fullfile(saveLocation,'COMBINED_DATA.txt'),...
				'delimiter','tab')
			fprintf('A copy of the group-level dataset just constructed has been saved as a text file:\n%s\n',...
				fullfile(saveLocation,'COMBINED_DATA.txt'));
		end

		function buildGroupDataTable(obj)
			obj.groupTable = table();
			for n=1:obj.nParticipants
				obj.groupTable = [obj.groupTable; obj.participantLevel(n).table];
			end
		end

		function [dataStruct] = getParticipantData(obj,participant)
			% grabs data just from one participant.
			% OUTPUTS:
			% a structure with fields
			%  - A, B, DA, DB, R, ID (all column vectors)
			%  - trialsForThisParticant (a single value)

			dataStruct = table2struct(obj.participantLevel(participant).table,...
				'ToScalar',true);

			dataStruct.trialsForThisParticant =...
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
				obj.observedData.A(p,[1:Tp]) = obj.participantLevel(p).table.('A');
				obj.observedData.B(p,[1:Tp]) = obj.participantLevel(p).table.('B');
				obj.observedData.DA(p,[1:Tp]) = obj.participantLevel(p).table.('DA');
				obj.observedData.DB(p,[1:Tp]) = obj.participantLevel(p).table.('DB');
				obj.observedData.R(p,[1:Tp]) = obj.participantLevel(p).table.('R');
			end

			% T is a vector containing number of trials for each participant
			obj.observedData.T = [obj.participantLevel.trialsForThisParticant];
		end

	end


	methods(Static)

		function pTable = appendParticipantIDcolumn(pTable, n)
			ID = ones( height(pTable), 1) * n;
			pTable = [pTable table(ID)];
		end

	end

end
