%KIRBY DATA IS NOT APPROPRIATE FOR THIS MODEL
% We need experimental paradigms that try to pinpoint the indifference
% point for a set number of delays.

classdef ModelSeparateNonParametric < NonParametric
	%ModelSeparateNonParametric

	methods (Access = public)

		function obj = ModelSeparateNonParametric(data, varargin)
			obj = obj@NonParametric(data, varargin{:});
			obj.modelFilename = 'separateNonParametric';

			% MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
			obj = obj.conductInference();
		end

		function initialParams = setInitialParamValues(obj, nchains)
			% Generate initial values of the root nodes
			%nTrials = size(obj.data.observedData.A,2);
			nExperimentFiles = obj.data.nExperimentFiles;
			nUniqueDelays = numel(obj.observedData.uniqueDelays);

			for chain = 1:nchains
				initialParams(chain).discountFraction = normrnd(1, 0.1, [nExperimentFiles, nUniqueDelays]);
			end
			% TODO: have a function called discountFraction and pass it
			% into this initialParam maker loop
		end
        
	end
    
end
