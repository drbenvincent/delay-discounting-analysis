classdef Data
	%Data This class holds data and provides many get methods
    
	properties (GetAccess = private, SetAccess = private)
		dataFolder	% path to folder containing data files
		filenames_full	% filename, including extension
		filenames		% filename, but no extension
        participantIDs  
		experiment  % array of objects: TODO: RENAME      
        unobservedPartipantPresent
        nExperimentFiles		% includes optional unobserved participant
		nRealExperimentFiles	% only includes number of real experiment files
	end
    
    properties (Dependent)
        totalTrials
        groupTable % table of A§, DA, B, DB, R, ID, PA, PB
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
			obj.unobservedPartipantPresent = false;
			disp('Data object created');
			if ~isempty(p.Results.files)
				obj = obj.importAllFiles(p.Results.files);
			end
		end


        % ======================================================================
		% PUBLIC METHODS =======================================================
        % ======================================================================
        
        
		function obj = importAllFiles(obj, fnames)
			assert( iscellstr(fnames), 'fnames should be a cell array of filenames')
			% import ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			data = DataImporter(obj.dataFolder, fnames);
			obj.experiment = data.getData();
            % store meta information about the dataset ~~~~~~~~~~~~~~~~~~~~
			obj.nExperimentFiles		 = numel(fnames);
			obj.nRealExperimentFiles	 = numel(fnames);
			obj.filenames_full			 = fnames;
			obj.filenames				 = path2filename(fnames);
            obj.participantIDs		     = path2participantID(fnames);
            % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			obj.exportGroupDataFileToDisk();
		end


		function exportGroupDataFileToDisk(obj)
			saveLocation = fullfile(obj.dataFolder,'groupLevelData');
			ensureFolderExists(saveLocation)
			writetable(...
				obj.groupTable,...
				fullfile(saveLocation,'COMBINED_DATA.txt'),...
				'delimiter','tab')
			fprintf('A copy of the group-level dataset just constructed has been saved as a text file:\n%s\n',...
				fullfile(saveLocation,'COMBINED_DATA.txt'));
		end


		function obj = add_unobserved_participant(obj, str)
			if obj.unobservedPartipantPresent
				error('Have already added unobserved participant')
			end

			obj.filenames{obj.nRealExperimentFiles+1} = str;

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

        
        
        % ======================================================================
		% PUBLIC GET METHODS ===================================================
        % ======================================================================
        
		function out = getExperimentObject(obj, n)
			if n > numel(obj.experiment)
				out = [];
			else
				out = obj.experiment(n);
			end
		end
		
		function dataStruct = getExperimentData(obj,experiment)
			% grabs data just from one experiment.
			% OUTPUTS:
			% a structure with fields
			%  - A, B, DA, DB, R, ID (all column vectors)
			%  - trialsForThisParticant (a single value)
			
			if experiment > numel(obj.experiment)
				% this case may happen if we are asking for data for a
				% group-level participant. In this case, return an empty
				% var.
				dataStruct = [];
				return
			end
			
			% TODO: this mess is a manifestation of no decent way to deal
			% with the group-level (who has no data).
			try
				dataStruct = table2struct(obj.experiment(experiment).getDataAsTable,...
					'ToScalar',true);
				
				dataStruct.trialsForThisParticant =...
					obj.experiment(experiment).trialsForThisParticant;
			catch
				dataStruct = [];
			end
		end

		function R = getParticipantResponses(obj, p)
			temp = obj.experiment(p).getDataAsTable();
			R = temp.R;
		end

		function nTrials = getTrialsForThisParticant(obj, p)
			% TODO: really need to get a better solution that this special
			% case nonsense for the unobserved group participant with no
			% data
			if p > numel(obj.experiment)
				% asking for an experiment which doesnt exist. Probably
				% happening because of the group-level estimate
				nTrials = [];
			else
				nTrials = obj.experiment(p).getTrialsForThisParticant;
			end
		end

		function pTable = getRawDataTableForParticipant(obj, p)
			% return a Table of raw data
			
			% TODO: really need to get a better solution that this special
			% case nonsense for the unobserved group participant with no
			% data
			if p > numel(obj.experiment)
				pTable = [];
			else
				pTable = obj.experiment(p).getDataAsTable();
			end
		end

		function names = getIDnames(obj, whatIwant)
			% returns a cell array of strings
			if ischar(whatIwant)
				switch whatIwant
					case{'all'}
						names = obj.filenames;
					case{'experiments'}
						names = obj.filenames([1:obj.nRealExperimentFiles]);
					case{'group'}
						if ~obj.unobservedPartipantPresent
							error('Asking for group-level (unobserved) participant, but they do not exist')
						end
						names = obj.filenames(end);
				end
			elseif isnumeric(whatIwant)
				% assume we want to index into IDnames
				names = obj.filenames(whatIwant);
			end
		end
		
		function isPresent = isUnobservedPartipantPresent(obj)
			isPresent = obj.unobservedPartipantPresent;
		end
		
		function index = getIndexOfUnobservedParticipant(obj)
			if obj.unobservedPartipantPresent
				index = numel(obj.filenames);
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
			all_data = obj.groupTable;
			if obj.unobservedPartipantPresent
				participantIndexList = [unique(all_data.ID) ; max(unique(all_data.ID))+1];
			else
				participantIndexList = unique(all_data.ID);
			end
		end
        
        function totalTrials = get.totalTrials(obj)
            totalTrials	= height( obj.groupTable );
		end
        
        function int = getNExperimentFiles(obj)
            % includes optional unobserved participant
            int = obj.nExperimentFiles;
        end
        
        function int = getNRealExperimentFiles(obj)
            % only includes number of real experiment files
            int = obj.nRealExperimentFiles;
		end
        
		function names = getParticipantNames(obj)
			names = obj.participantIDs;
		end
		
        function uniqueNames = getUniqueParticipantNames(obj)
            uniqueNames = unique(obj.participantIDs);
        end
        
        function groupTable = get.groupTable(obj)
			% Dynamically constructs group table from experiment-level tables
			N = numel(obj.experiment);
			groupTable = table();
			for n=1:N
				groupTable = vertcat(groupTable, obj.experiment(n).getDataAsTable);
			end
		end
        
	end

end
