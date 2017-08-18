%KIRBY DATA IS NOT APPROPRIATE FOR THIS MODEL
% We need experimental paradigms that try to pinpoint the indifference
% point for a set number of delays.

classdef ModelSeparateNonParametric < NonParametric
	%ModelSeparateNonParametric

	methods (Access = public, Hidden = true)

		function obj = ModelSeparateNonParametric(data, varargin)
			obj = obj@NonParametric(data, varargin{:});
			obj.modelFilename = 'separateNonParametric';

			% MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
			obj = obj.conductInference();
		end

    end
    
    methods (Access = protected)
    
		function initialParams = initialiseChainValues(obj, nchains)
			% Generate initial values of the root nodes
			%nTrials = size(obj.data.observedData.A,2);
			nExperimentFiles = obj.data.getNExperimentFiles();
			nUniqueDelays = numel(obj.observedData.uniqueDelays);

			for chain = 1:nchains
				initialParams(chain).Rstar = unifrnd(0, 2, [nExperimentFiles, nUniqueDelays]);
                initialParams(chain).epsilon = 0.1 + rand([nExperimentFiles,1])/10;
                initialParams(chain).alpha = abs(normrnd(0.01,10,[nExperimentFiles,1]));
			end
			% TODO: have a function called discountFraction and pass it
			% into this initialParam maker loop
		end
        
	end
    
end
