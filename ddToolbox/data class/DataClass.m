classdef DataClass < handle
	%data A class to load and handle data

	properties (GetAccess = public, SetAccess = private)
		participantFilenames
		dataFolder
		nParticipants
		totalTrials
		IDname
		participantLevel
		groupTable % table of A, DA, B, DB, R, ID, PA, PB
		observedData % TODO make this  in model?
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
				% Add participant ID column
				participantTable = obj.appendParticipantIDcolumn(participantTable, n);
				% Ensure columns PA and PB exist, assuming P=1 if they do not. This
				% could be the case if we've done a pure delay discounting
				% experiment and not bothered to sotre the fact that rewards have
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

			fields = {'A', 'B', 'DA', 'DB', 'PA', 'PB', 'R'};
			for p=1:obj.nParticipants
				Tp = obj.participantLevel(p).trialsForThisParticant;
				for n = 1:numel(fields)
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
			
			
			
			% **** Observed variables below are for the Gaussian Random
			% Walk model ****
			%
			% Create a lookup table, for a given [participant,trial], this 
			% is the index of DB.
			
			% If we insert additional delays into this vector 
			% (uniqueDelays), then the model will interpolate between the 
			% delays that we have data for.
			% If you do not want to interpolate any delays, then set :
			%  interpolation_delays = [] 
			
			unique_delays_from_data = sort(unique(obj.observedData.DB))';
			% optionally add interpolated delays ~~~~~~~~~~~~~~~~~~~~~~~~~~~
			add_interpolated_delays = true;
			if add_interpolated_delays
				interpolation_delays =  [ [7:7:365-7] ...
					[7*52:7:7*80]]; % <--- future
				combined = [unique_delays_from_data interpolation_delays];
				obj.observedData.uniqueDelays = sort(unique(combined));
			else
				obj.observedData.uniqueDelays = [0.01 unique_delays_from_data];
			end
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			
			% Now we create a lookup table [participants,tials] full of
			% integers which point to the index of the delay value in 
			% uniqueDelays
			temp = obj.observedData.DB;
			for n=1: numel(obj.observedData.uniqueDelays)
				delay = obj.observedData.uniqueDelays(n);
				temp(obj.observedData.DB==delay) = n;
			end
			obj.observedData.delayLookUp = temp;
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
