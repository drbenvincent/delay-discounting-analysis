classdef Dataset
	%Dataset A class to load and handle a dataset

	properties (GetAccess = public, SetAccess = private)
		participantFilenames
		dataFolder
		nExperiments
		totalTrials
		IDname
		participantLevel  % structure containing a table for each participant
		groupTable        % table of A, DA, B, DB, R, ID, PA, PB
		observedData % TODO make this  in model?
	end


	methods (Access = public)

		function obj = Dataset(dataFolder, varargin)
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

		function obj = loadDataFiles(obj,fnames)
			assert( iscellstr(fnames), 'fnames should be a cell array of filenames')

			obj.nExperiments = numel(fnames);
			obj.participantFilenames = fnames;

            % create array of DiscountingExperimentResults
			for n=1:numel(fnames)
                experiment(n) = DiscountingExperimentResults( fullfile(obj.dataFolder, fnames{n}));
			end

			obj = obj.constructObservedDataForMCMC();
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
			for n=1:obj.nExperiments
				obj.groupTable = [obj.groupTable; obj.participantLevel(n).table];
			end
		end

		function dataStruct = getParticipantData(obj, participant)
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

		function obj = constructObservedDataForMCMC(obj)
			% construct a structure of ObservedData which will provide input to
			% the MCMC process.

			%% Create long data table of all participants
			all_data = obj.participantLevel(:).table;
			if obj.nExperiments>1
				for p=2:obj.nExperiments
					all_data = [all_data; obj.participantLevel(p).table];
				end
			end

			%% Convert each column of table in to a field of a structure
			% As wanted by JAGS
			variables = all_data.Properties.VariableNames;
			for varname = variables
				obj.observedData.(varname{:}) = all_data.(varname{:});
			end

			obj.observedData.participantIndexList = unique(all_data.ID);

			% **** Observed variables below are for the Gaussian Random Walk model ****
			obj.observedData.uniqueDelays = sort(unique(obj.observedData.DB))';
			obj.observedData.delayLookUp = obj.calcDelayLookup();
		end

		function delayLookUp = calcDelayLookup(obj)
			delayLookUp = obj.observedData.DB;
			for n=1: numel(obj.observedData.uniqueDelays)
				delay = obj.observedData.uniqueDelays(n);
				delayLookUp(obj.observedData.DB==delay) = n;
			end
		end

 	end


	methods(Static)

		function pTable = appendParticipantIDcolumn(pTable, n)
			ID = ones( height(pTable), 1) * n;
			pTable = [pTable table(ID)];
		end

	end

end
