classdef DataClass
	%data A class to load and handle data

	properties (GetAccess = public, SetAccess = private)
		participantFilenames
		dataFolder
		nParticipants
		totalTrials
		IDname
		participantLevel  % structure containing a table for each participant
		groupTable        % table of A, DA, B, DB, R, ID, PA, PB
	end


	methods (Access = public)

		function obj = DataClass(dataFolder, varargin)
			p = inputParser;
			p.addRequired('dataFolder',@isstr);
			p.FunctionName = mfilename;
			p.addParameter('files',{''},@iscellstr);
			p.parse(dataFolder, varargin{:});

			try
				table();
			catch
				error( strcat('ERROR: This version of Matlab does not support the Table data type. ',...
					'You will need to call DataClassLegacy() instead of DataClass().'))
			end
			obj.dataFolder = dataFolder;
			display('You have created a Data object')

			if ~isempty(p.Results.files)
				obj = obj.loadDataFiles(p.Results.files);
			end
		end


		function obj = loadDataFiles(obj, fnames)
			assert( iscellstr(fnames), 'fnames should be a cell array of filenames')

			obj.nParticipants = numel(fnames);
			obj.participantFilenames = fnames;

			for n=1:obj.nParticipants
				% determined participant ID string
				[~,obj.IDname{n},~] = fileparts(fnames{n}); % just get filename
				%obj.IDname{n} = getPrefixOfString(fnames{n},'-');

				participantTable = readtable(fullfile(obj.dataFolder,fnames{n}), 'delimiter','tab');
				% Add participant ID column
				participantTable = obj.appendParticipantIDcolumn(participantTable, n);
				% Ensure columns PA and PB exist, assuming P=1 if they do not. This
				% could be the case if we've done a pure delay discounting
				% experiment and not bothered to store the fact that rewards have
				% 100% of delivery. If they did not, then we would have stored the
				% vales of PA and PB.
				if ~obj.isColumnPresent(participantTable, 'PA')
					PA = ones( height(participantTable), 1);
					participantTable = [participantTable table(PA)];
				end
				if ~obj.isColumnPresent(participantTable, 'PB')
					PB = ones( height(participantTable), 1);
					participantTable = [participantTable table(PB)];
				end
				% Ensure columns DA and DB exist, assuming D=0 if they do not. This
				% could be the case if we ran a pure probability discounting
				% experiment, and didn't bother storing the fact that DA and DB
				% were immediate rewards.
				if ~obj.isColumnPresent(participantTable, 'DA')
					DA = zeros( height(participantTable), 1);
					participantTable = [participantTable table(DA)];
				end
				if ~obj.isColumnPresent(participantTable, 'DB')
					DB = ones( zeros(participantTable), 1);
					participantTable = [participantTable table(DB)];
				end
				% Add
 				obj.participantLevel(n).table = participantTable;
 				obj.participantLevel(n).trialsForThisParticant = height(participantTable);
			end
			% Add info for extra (unobserved) participant
			n = obj.nParticipants + 1;
			obj.IDname{n} = 'GROUP';

			obj = obj.exportGroupDataFile();
			obj.totalTrials = height(obj.groupTable);

			display('The following participant-level data files were imported:')
			display(fnames')
		end

		function obj = exportGroupDataFile(obj)
			obj = obj.buildGroupDataTable();
			saveLocation = fullfile(obj.dataFolder,'groupLevelData');
			if ~exist(saveLocation, 'dir'), mkdir(saveLocation), end
			writetable(obj.groupTable,...
				fullfile(saveLocation,'COMBINED_DATA.txt'),...
				'delimiter','tab')
			fprintf('A copy of the group-level dataset just constructed has been saved as a text file:\n%s\n',...
				fullfile(saveLocation,'COMBINED_DATA.txt'));
		end

		function obj = buildGroupDataTable(obj)
			obj.groupTable = table();
			for n=1:obj.nParticipants
				obj.groupTable = [obj.groupTable; obj.participantLevel(n).table];
			end
		end

		function dataStruct = getParticipantData(obj,participant)
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
		
 	end


	methods(Static)

		function pTable = appendParticipantIDcolumn(pTable, n)
			ID = ones( height(pTable), 1) * n;
			pTable = [pTable table(ID)];
		end

		function isPresent = isColumnPresent(table, columnName)
			isPresent = sum(strcmp(table.Properties.VariableNames,columnName))~=0;
		end

	end

end
