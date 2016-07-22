classdef ExperimentResults
	%ExperimentResults Class to represent data associated with a particular experiment.

	properties (GetAccess = public, SetAccess = private)
		filePath
		nTrials
		data		% data stored as a table here
		dataStruct	% get method calculates 'data' as a struct, on the fly
	end

	methods

		function obj = ExperimentResults(filePath)
			obj.filePath = filePath;
			obj.data = readtable(filePath, 'delimiter','tab');
			obj.nTrials = height(obj.data);
		end

		function data = get.dataStruct(obj)
			data = table2struct(obj.data, 'ToScalar',true);
			data.nTrials = obj.nTrials;
		end
	end

end
