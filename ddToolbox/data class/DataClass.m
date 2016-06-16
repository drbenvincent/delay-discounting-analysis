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
			assert( iscellstr(fnames), 'fnames should be a cell array of filenames')

			obj.nParticipants = numel(fnames);
			obj.participantFilenames = fnames;

			for n=1:obj.nParticipants
                % determined participant ID string
                [~,obj.IDname{n},~] = fileparts(fnames{n}); % just get filename
                %obj.IDname{n} = getPrefixOfString(fnames{n},'-');

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

			fields = {'A', 'B', 'DA', 'DB', 'R'};
			for p=1:obj.nParticipants
				Tp = obj.participantLevel(p).trialsForThisParticant;
				for n = 1: numel(fields)
					% makes vector of NaN's
					obj.observedData.(fields{n})(p,:) = NaN(1, maxTrials);
					% fills up with data
					obj.observedData.(fields{n})(p,[1:Tp]) =...
						obj.participantLevel(p).table.(fields{n});
				end
			end

			obj.observedData.T = [obj.participantLevel.trialsForThisParticant];
			%obj.observedData.nParticipants = obj.nParticipants;
			obj.observedData.participantIndexList = [1:obj.nParticipants];
			
			obj.observedData.uniqueDelays = sort(unique(obj.observedData.DB))';
			
			% This is for the gaussian random walk model... create a lookup
			% table, for a given [participant,trial], this is the index of
			% DB.
			temp = obj.observedData.DB;
			for n=1: numel(obj.observedData.uniqueDelays)
				delay = obj.observedData.uniqueDelays(n);
				temp(obj.observedData.DB==delay) = n;
			end
			obj.observedData.delayLookUp = temp;
			
			% just for gaussian random walk model
			obj.observedData.dInterp = [7, 21, 35, 49, 63, 77, 91, 105, 119, 133, 147, 161, 175, 189, 203, 217, 231, 245, 259, 273, 287, 301, 315, 329, 343, 357];
		end

	end


	methods(Static)

		function pTable = appendParticipantIDcolumn(pTable, n)
			ID = ones( height(pTable), 1) * n;
			pTable = [pTable table(ID)];
		end

	end

end
