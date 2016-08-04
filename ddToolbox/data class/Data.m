classdef Data
	%Data A class to load and handle data
	
	properties (GetAccess = public, SetAccess = private)
		% Ensure all properties here are NOT going to change, even if the
		% inner workings of this class change.
		nParticipants		% includes optional unobserved participant
		nRealParticipants	% only includes number of real experiment files
		totalTrials
		unobservedPartipantPresent %<--- not sure if we want this exposed or not
	end
	
	properties (GetAccess = private, SetAccess = private)
		dataFolder	% path to folder containing data files
		filenames	% filename, including extension
		IDnames		% filename, but no extension
		participantLevel  % structure containing a table for each participant
		%groupTable        % table of A, DA, B, DB, R, ID, PA, PB
	end
	
	% NOTE TO SELF: These public methods need to be seen as interfaces to
	% the outside world that are implementation-independent. So thought
	% needs to be given to public methods.
	%
	% These public methods need to be covered by tests.
	
	methods (Access = public)
		
		function obj = Data(dataFolder, varargin)
			p = inputParser;
			p.addRequired('dataFolder',@isstr);
			p.FunctionName = mfilename;
			p.addParameter('files',[],@iscellstr);
			p.parse(dataFolder, varargin{:});
			
			try
				table();
			catch
				error( strcat('ERROR: This version of Matlab does not support the Table data type. ',...
					'You will need to call DataLegacy() instead of Data().'))
			end
			obj.dataFolder = dataFolder;
			display('You have created a Data object')
			
			if ~isempty(p.Results.files)
				obj = obj.importAllFiles(p.Results.files);
			end
			
			obj.unobservedPartipantPresent = false;
		end
		
		
		% PUBLIC SET METHODS ==============================================
		
		function obj = importAllFiles(obj, fnames)
			assert( iscellstr(fnames), 'fnames should be a cell array of filenames')
			
			obj.nParticipants		= numel(fnames);
			obj.nRealParticipants	= numel(fnames);
			obj.filenames			= fnames;
			obj.IDnames				= obj.extractFilenames(fnames);
			obj.participantLevel	= obj.buildParticipantTables(fnames);
			obj.exportGroupDataFile();
			obj.totalTrials			= height( obj.buildGroupDataTable() );
			
			display('The following participant-level data files were imported:')
			display(fnames')
		end
		
		
		function exportGroupDataFile(obj)
			saveLocation = fullfile(obj.dataFolder,'groupLevelData');
			ensureFolderExists(saveLocation)
			writetable(...
				obj.buildGroupDataTable(),...
				fullfile(saveLocation,'COMBINED_DATA.txt'),...
				'delimiter','tab')
			fprintf('A copy of the group-level dataset just constructed has been saved as a text file:\n%s\n',...
				fullfile(saveLocation,'COMBINED_DATA.txt'));
		end
		
		
		function obj = add_unobserved_participant(obj, str)
			if obj.unobservedPartipantPresent
				error('Have already added unobserved participant')
			end
			
			obj.IDnames{obj.nRealParticipants+1} = str;
			
			obj.nParticipants = obj.nParticipants + 1;
			index = obj.nParticipants;
			
			% set all fields to empty
			fields = fieldnames(obj.participantLevel);
			for n=1:numel(fields)
				% TODO: this currently needs to be empty ([]) but would be
				% better if it was also able to coe being set as NaN.
				obj.participantLevel(index).(fields{n}) = [];
			end
			
			obj.unobservedPartipantPresent = true;
		end
		
		
		% PUBLIC GET METHODS ==============================================
		
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
		
		function R = getParticipantResponses(obj, p)
			R = obj.participantLevel(p).table.R;
		end
		
		function nTrials = getTrialsForThisParticant(obj, p)
			nTrials = obj.participantLevel(p).trialsForThisParticant;
		end
		
		function pTable = getRawDataTableForParticipant(obj, p)
			% return a Table of raw data
			pTable = obj.participantLevel(p).table;
		end
		
		function all_data = get_all_data_table(obj)
			% Create long data table of all participants
			all_data = obj.participantLevel(:).table;
			if obj.nParticipants > 1
				for p = 2:obj.nParticipants
					all_data = [all_data; obj.participantLevel(p).table];
				end
			end
		end
		
		function names = getIDnames(obj, whatIwant)
			% returns a cell array of strings
			if ischar(whatIwant)
				switch whatIwant
					case{'all'}
						names = obj.IDnames;
					case{'participants'}
						names = obj.IDnames([1:obj.nRealParticipants]);
					case{'group'}
						if ~obj.unobservedPartipantPresent
							error('Asking for group-level (unobserved) participant, but they do not exist')
						end
						names = obj.IDnames(end);
				end
			elseif isnumeric(whatIwant)
				% assume we want to index into IDnames
				names = obj.IDnames(whatIwant);
			end
		end
		
	end
	
	% PRIVATE =============================================================
	% Not to be covered by tests, unless it is useful during development.
	% But we do not need tests to constrain the way how these
	% implementation details work.
	
	methods (Access = private)
		
		function IDnames = extractFilenames(obj, fnames)
			for n=1:obj.nParticipants
				[~,IDnames{n},~] = fileparts(fnames{n}); % just get filename
			end
		end
		
		function participantLevel = buildParticipantTables(obj, fnames)
			% return a structure of tables
						
			for n=1:obj.nParticipants
				% read from disk
				participantTable = readtable(...
					fullfile(obj.dataFolder, fnames{n}),...
					'delimiter', 'tab');
				% Add participant ID column
				participantTable = obj.appendParticipantIDcolumn(participantTable, n);
				% Ensure PA, PB, DA, DB cols present
				participantTable = obj.ensureAllColsPresent(participantTable);
				
				% Add to struct
				participantLevel(n).table = participantTable;
				participantLevel(n).trialsForThisParticant = height(participantTable);
			end
		end
		
		function participantTable = ensureAllColsPresent(obj, participantTable)
			
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
		end
		
		function groupTable = buildGroupDataTable(obj)
			groupTable = vertcat(obj.participantLevel(:).table);
		end
		
	end
	
	methods(Static, Access = private)
		
		function pTable = appendParticipantIDcolumn(pTable, n)
			ID = ones( height(pTable), 1) * n;
			pTable = [pTable table(ID)];
		end
		
		function isPresent = isColumnPresent(table, columnName)
			isPresent = sum(strcmp(table.Properties.VariableNames,columnName))~=0;
		end
		
	end
	
end
