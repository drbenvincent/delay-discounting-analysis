classdef DataImporter
	%DataImporter Imports and validates raw behavioural data.
	
	properties (SetAccess = private, GetAccess = protected)
		dataArray
		
		path
		fnames
		nFiles
	end
	
	
	% PUBLIC METHODS ======================================================
	methods
		
		function obj = DataImporter(path, fnames)
			assert( iscellstr(fnames), 'fnames should be a cell array of filenames')			
			obj.path = path;
			obj.fnames = fnames;
			obj.nFiles = numel(fnames);
            % do importing
			obj.dataArray = obj.import();
			disp('The following data files were imported:')
			disp(fnames')
		end
		
		function dataArray = import(obj)
			for n=1:obj.nFiles
				
				% are we importing a:
				% - tab delimited .txt
				% - comma separated .csv
				
				[pathstr, name, ext] = fileparts(obj.fnames{n});
				
				switch ext
					case{'.txt'}
						% import comma separated .csv
						experimentTable = readtable(...
							fullfile(obj.path, obj.fnames{n}),...
							'delimiter', 'tab');
					case{'.csv'}
						% import tab delimited .txt
						experimentTable = readtable(...
							fullfile(obj.path, obj.fnames{n}),...
							'delimiter', ',');
					otherwise
						error('attempting to import a file which is not .csv or .txt')
				end
				
				%% Conversion of column header names
				if exist('columnHeaderConversion','file')
					% manually specified
					experimentTable = columnHeaderConversion(experimentTable);
					
				else
					% attempt to automatically convert some column name 
					% variants to what the toolbox wants. This is here for
					% legacy reasons because I (frustratingly) changed the
					% precise labelling of the variables over time.
					variableNames = experimentTable.Properties.VariableNames;
					for col = 1:numel(variableNames)
						switch experimentTable.Properties.VariableNames{col}
							case{'R_s', 'Rs', 'R_A'}
								experimentTable.Properties.VariableNames{col} = 'A';
							case{'R_L', 'R_B'}
								experimentTable.Properties.VariableNames{col} = 'B';
							case{'D_s', 'D_A'}
								experimentTable.Properties.VariableNames{col} = 'DA';
							case{'D_L', 'D_B'}
								experimentTable.Properties.VariableNames{col} = 'DB';
							case{'P_s', 'P_A'}
								experimentTable.Properties.VariableNames{col} = 'PA';
							case{'P_L', 'P_B'}
								experimentTable.Properties.VariableNames{col} = 'PB';
						end
					end
				end
				
				%% Do any necessary decoding of response variable `R`
				% R=0 means chose prospect A, conventionally the immediate,
				% or sooner reward.
				% R=1 means chose prospect B, conventionally the delayed,
				% or more delayed reward
				if iscellstr(experimentTable.R)
					% convert categorically coded (ie A,B) into (0,1)
					for t=1:numel(experimentTable.R)
						switch experimentTable.R{t}
							case{'A'}
								newR(t,1) = 0;
							case{'B'}
								newR(t,1) = 1;
						end
					end
				end
				experimentTable.R = newR;
				
				%% Add ID column
				experimentTable = appendTableColOfVals(experimentTable, n);
				
				%% Validation
				experimentTable = obj.ensureAllColsPresent(experimentTable);
				experimentTable = obj.columnHeaderValidation(experimentTable);
				experimentTable = obj.removeMissingResponseTrials(experimentTable);
				obj.validateData(experimentTable);
				
				dataArray(n) = DataFile(experimentTable);
			end
		end
		
		function dataArray = getData(obj)
			dataArray = obj.dataArray;
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
				
		function aTable = columnHeaderValidation(aTable)
			% Ensure we have the desired information
			
			% TODO: Implement validation here
		end
		
		function experimentTable = removeMissingResponseTrials(experimentTable)
			RESPONSE_VARIABLENAME = 'R';
			rows_to_keep = ~isnan(experimentTable.(RESPONSE_VARIABLENAME));
			experimentTable = experimentTable(rows_to_keep,:);
		end
		
		function validateData(experimentTable)
			% either throws an error, or doesn't
			assert(any(experimentTable.DA >= 0), 'Entries of DA must be greater than or equal to zero')
			assert(any(experimentTable.DB >= 0), 'Entries of DA must be greater than or equal to zero')
			assert(any(experimentTable.DA <= experimentTable.DB), 'For any given trial (row) DA must be less than or equal to DB')
			assert(any(experimentTable.PA > 0 | experimentTable.PA < 1), 'PA must be between 0 and 1')
			assert(any(experimentTable.PB > 0 | experimentTable.PB < 1), 'PA must be between 0 and 1')
			assert(all(experimentTable.R <=1 ), 'Data:AssertionFailed', 'Values of R must be either 0 or 1')
			assert(all(experimentTable.R >=0 ), 'Data:AssertionFailed', 'Values of R must be either 0 or 1')
			assert(all(rem(experimentTable.R,1)==0), 'Data:AssertionFailed', 'Values of R must be either 0 or 1')
			assert(all(isnumeric(experimentTable.R)), 'Data:AssertionFailed', 'Values of R must be either 0 or 1')
		end


	end
	
end
