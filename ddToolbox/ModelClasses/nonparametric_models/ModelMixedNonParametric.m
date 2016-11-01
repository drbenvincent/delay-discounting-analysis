%KIRBY DATA IS NOT APPROPRIATE FOR THIS MODEL
% We need experimental paradigms that try to pinpoint the indifference
% point for a set number of delays.

classdef ModelMixedNonParametric < NonParametric

	methods (Access = public)

		function obj = ModelMixedNonParametric(data, varargin)
			obj = obj@NonParametric(data, varargin{:});
			obj.modelFilename = 'mixedNonParametric';

			% MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
			obj = obj.conductInference();
		end

		function initialParams = initialiseChainValues(obj, nchains)
			% Generate initial values of the root nodes
			%nTrials = size(obj.data.observedData.A,2);
			nExperimentFiles = obj.data.getNExperimentFiles();
			nUniqueDelays = numel(obj.observedData.uniqueDelays);

			for chain = 1:nchains
				initialParams(chain).discountFraction = unifrnd(0, 2, [nExperimentFiles, nUniqueDelays]);
                %initialParams(chain).epsilon = 0.1 + rand([nExperimentFiles,1])/10;
                %initialParams(chain).alpha = abs(normrnd(0.01,10,[nExperimentFiles,1]));
				initialParams(chain).groupW             = rand;
				initialParams(chain).groupALPHAmu		= rand*100;
				initialParams(chain).groupALPHAsigma	= rand*100;
			end
		end
        
	end
    
end
