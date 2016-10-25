classdef Data
	%Data A class to load and handle data

	properties (GetAccess = private, SetAccess = private)
		dataFolder	% path to folder containing data files
		filenames	% filename, including extension
		IDnames		% filename, but no extension
		experiment  % structure containing a table for each experiment
		%groupTable        % table of A, DA, B, DB, R, ID, PA, PB
        totalTrials
        unobservedPartipantPresent
        nExperimentFiles		% includes optional unobserved participant
		nRealExperimentFiles	% only includes number of real experiment files
	end

	% NOTE TO SELF: These public methods need to be seen as interfaces to
	% the outside world that are implementation-independent. So thought
	% needs to be given to public methods.
	%
	% These public methods need to be covered by tests.

	methods

		function obj = Data(dataFolder, varargin)
			p = inputParser;
			p.addRequired('dataFolder',@isstr);
			p.FunctionName = mfilename;
			p.addParameter('files',[],@(x) iscellstr(x)|ischar(x));
			p.parse(dataFolder, varargin{:});

			try
				table();
			catch
				error('This version of Matlab does not support the Table data type.')
			end
			obj.dataFolder = dataFolder;
			display('You have created a Data object')

			if ~isempty(p.Results.files)
				obj = obj.importAllFiles(p.Results.files);
			end

			obj.unobservedPartipantPresent = false;
		end


		% PUBLIC METHODS ==============================================

		function obj = importAllFiles(obj, fnames)
			assert( iscellstr(fnames), 'fnames should be a cell array of filenames')

			obj.nExperimentFiles		 = numel(fnames);
			obj.nRealExperimentFiles	 = numel(fnames);
			obj.filenames			     = fnames;
			obj.IDnames				     = path2filename(fnames);
			obj.experiment	             = obj.buildExperimentTables(fnames);
			obj.experiment               = obj.removeMissingResponseTrials();
			obj.validateData();
			obj.exportGroupDataFile();
			obj.totalTrials			     = height( obj.buildGroupDataTable() );

			display('The following data files were imported:')
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

			obj.IDnames{obj.nRealExperimentFiles+1} = str;

			obj.nExperimentFiles = obj.nExperimentFiles + 1;
			index = obj.nExperimentFiles;

			% set all fields to empty
			fields = fieldnames(obj.experiment);
			for n=1:numel(fields)
				% TODO: this currently needs to be empty ([]) but would be
				% better if it was also able to cope being set as NaN.
				obj.experiment(index).(fields{n}) = [];
			end

			obj.unobservedPartipantPresent = true;
		end


		% PUBLIC GET METHODS ==============================================

		function dataStruct = getExperimentData(obj,experiment)
			% grabs data just from one experiment.
			% OUTPUTS:
			% a structure with fields
			%  - A, B, DA, DB, R, ID (all column vectors)
			%  - trialsForThisParticant (a single value)

			dataStruct = table2struct(obj.experiment(experiment).table,...
				'ToScalar',true);

			dataStruct.trialsForThisParticant =...
				obj.experiment(experiment).trialsForThisParticant;
		end

		function R = getParticipantResponses(obj, p)
			R = obj.experiment(p).table.R;
		end

		function nTrials = getTrialsForThisParticant(obj, p)
			nTrials = obj.experiment(p).trialsForThisParticant;
		end

		function pTable = getRawDataTableForParticipant(obj, p)
			% return a Table of raw data
			pTable = obj.experiment(p).table;
		end

		function all_data = get_all_data_table(obj)
			% Create long data table of all participants
			all_data = obj.experiment(:).table;
			if obj.nExperimentFiles > 1
				for p = 2:obj.nExperimentFiles
					all_data = [all_data; obj.experiment(p).table];
				end
			end
		end

		function names = getIDnames(obj, whatIwant)
			% returns a cell array of strings
			if ischar(whatIwant)
				switch whatIwant
					case{'all'}
						names = obj.IDnames;
					case{'experiments'}
						names = obj.IDnames([1:obj.nRealExperimentFiles]);
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
		
		function isPresent = isUnobservedPartipantPresent(obj)
			isPresent = obj.unobservedPartipantPresent;
		end
		
		function index = getIndexOfUnobservedParticipant(obj)
			if obj.unobservedPartipantPresent
				index = numel(obj.IDnames);
			else
				% no group-level 'unobserved participant'
				index = [];
			end
		end
        
        function output = getEverythingAboutAnExperiment(obj, ind)
            % return a structure of everything about the data file 'ind'
            
        end
		
		function participantIndexList = getParticipantIndexList(obj)
			% A vector of [1,...P] where P is the number of
			% participants. BUT hierarchical models will have an extra
			% (unobserved) participant, so we need to be sensitive to
			% whether this exists of not
			all_data = obj.get_all_data_table();
			if obj.unobservedPartipantPresent
				participantIndexList = [unique(all_data.ID) ; max(unique(all_data.ID))+1];
			else
				participantIndexList = unique(all_data.ID);
			end
		end
        
        function totalTrials = getTotalTrials(obj)
            totalTrials = obj.totalTrials;
		end
        
        function int = getNExperimentFiles(obj)
            % includes optional unobserved participant
            int = obj.nExperimentFiles;
        end
        
        function int = getNRealExperimentFiles(obj)
            % only includes number of real experiment files
            int = obj.nRealExperimentFiles;
        end
        
	end

	% PRIVATE =============================================================
	% Not to be covered by tests, unless it is useful during development.
	% But we do not need tests to constrain the way how these
	% implementation details work.

	methods (Access = private)

		function obj = validateData(obj)
			% return a structure of tables

			for pIndex = 1:obj.nExperimentFiles
				validate(obj.experiment(pIndex).table)
			end
			
			function validate(aTable)
				assert(any(aTable.DA >= 0), 'Entries of DA must be greater than or equal to zero')
				assert(any(aTable.DB >= 0), 'Entries of DA must be greater than or equal to zero')
				assert(any(aTable.DA <= aTable.DB), 'For any given trial (row) DA must be less than or equal to DB')
				assert(any(aTable.PA > 0 | aTable.PA < 1), 'PA must be between 0 and 1')
				assert(any(aTable.PB > 0 | aTable.PB < 1), 'PA must be between 0 and 1')
				assert(all(aTable.R <=1 ), 'Data:AssertionFailed', 'Values of R must be either 0 or 1')
				assert(all(aTable.R >=0 ), 'Data:AssertionFailed', 'Values of R must be either 0 or 1')
				assert(all(rem(aTable.R,1)==0), 'Data:AssertionFailed', 'Values of R must be either 0 or 1')
				assert(all(isnumeric(aTable.R)), 'Data:AssertionFailed', 'Values of R must be either 0 or 1')
			end
		end
		
		function experiment = removeMissingResponseTrials(obj)
			for pIndex = 1:obj.nExperimentFiles
				current_table = obj.experiment(pIndex).table;
				experiment(pIndex).table = current_table(~isnan(current_table.R),:);
				experiment(pIndex).trialsForThisParticant = height(experiment(pIndex).table);
			end
		end
		
		function experiment = buildExperimentTables(obj, fnames)
			% return a structure of tables

			for pIndex = 1:obj.nExperimentFiles
				% read from disk
				experimentTable = readtable(...
					fullfile(obj.dataFolder, fnames{pIndex}),...
					'delimiter', 'tab');
				% Add ID column
				experimentTable = appendTableColOfVals(experimentTable, pIndex);
				% Ensure PA, PB, DA, DB cols present
				experimentTable = obj.ensureAllColsPresent(experimentTable);

				% Add to struct
				experiment(pIndex).table = experimentTable;
				experiment(pIndex).trialsForThisParticant = height(experimentTable);
			end
		end

		function groupTable = buildGroupDataTable(obj)
			groupTable = vertcat(obj.experiment(:).table);
		end

	end

	methods(Static, Access = private)

		function experimentTable = ensureAllColsPresent(experimentTable)

			% Ensure columns PA and PB exist, assuming P=1 if they do not. This
			% could be the case if we've done a pure delay discounting
			% experiment and not bothered to store the fact that rewards have
			% 100% of delivery. If they did not, then we would have stored the
			% vales of PA and PB.
			experimentTable = ensureColumnsPresentInTable(experimentTable,...
				{'PA',1, 'PB',1});

			% Ensure columns DA and DB exist, assuming D=0 if they do not. This
			% could be the case if we ran a pure probability discounting
			% experiment, and didn't bother storing the fact that DA and DB
			% were immediate rewards.
			experimentTable = ensureColumnsPresentInTable(experimentTable,...
				{'DA',0, 'DB',0});
		end


	end

end
