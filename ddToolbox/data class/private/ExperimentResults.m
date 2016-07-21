classdef ExperimentResults
	%ExperimentResults Class to represent data associated with a particular experiment.
	
	properties (GetAccess = public, SetAccess = private)
		filePath
		nTrials
		data		% data stored as a table here
		dataStruct	% get method calculates 'data' as a struct, on the fly
	end
	
	methods (Access = public)
		
		function obj = ExperimentResults(filePath)
			obj.filePath = filePath;
			obj.data = readtable(filePath, 'delimiter','tab');
			obj.nTrials = height(obj.data);
			
			% Ensure columns PA and PB exist, assuming P=1 if they do not. This
			% could be the case if we've done a pure delay discounting
			% experiment and not bothered to store the fact that rewards have
			% 100% of delivery. If they did not, then we would have stored the
			% vales of PA and PB.
			obj = obj.ensureColumnsPresent({'PA',1, 'PB',1});
			
			% Ensure columns DA and DB exist, assuming D=0 if they do not. This
			% could be the case if we ran a pure probability discounting
			% experiment, and didn't bother storing the fact that DA and DB
			% were immediate rewards.
			obj = obj.ensureColumnsPresent({'DA',0, 'DB',0});
		end
		
		function obj = ensureColumnsPresent(obj, nameValuePairs)
			for n = 1:2:numel(nameValuePairs)-1
				colName = nameValuePairs{n};
				val = nameValuePairs{n+1};
				if ~obj.isColumnPresent(obj.data, colName)
					newColumn = table(val.*ones( height(obj.data), 1),...
						'VariableNames',{colName});
					obj.data = [obj.data newColumn];
				end
			end
		end
		
	end
	
	methods
		function data = get.dataStruct(obj)
			data = table2struct(obj.data, 'ToScalar',true);
			data.nTrials = obj.nTrials;
		end
	end
	
	methods(Static)
		function isPresent = isColumnPresent(table, columnName)
			isPresent = sum(strcmp(table.Properties.VariableNames,columnName))~=0;
		end
	end
	
end