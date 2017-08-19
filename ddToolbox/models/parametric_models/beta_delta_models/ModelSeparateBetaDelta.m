classdef ModelSeparateBetaDelta < BetaDelta
	%ModelHierarchical A model to estimate the magnitide effect
	%  NO parameters are estimated hierarchically.

	methods (Access = public, Hidden = true)
		function obj = ModelSeparateBetaDelta(data, varargin)
			obj = obj@BetaDelta(data, varargin{:});
			obj.modelFilename = 'separateBetaDelta';

            % MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
            obj = obj.conductInference();
		end
    end

    methods (Access = protected)

		function initialParams = initialiseChainValues(obj, nchains)
            % Generate initial values of the root nodes
			nExperimentFiles = obj.data.getNExperimentFiles();
			for chain = 1:nchains
                initialParams(chain).beta = abs(normrnd(0.84, 2, [nExperimentFiles,1]));
				initialParams(chain).delta = normrnd(1, 0.5, [nExperimentFiles,1]);
				initialParams(chain).epsilon = 0.1 + rand([nExperimentFiles,1])/10;
				initialParams(chain).alpha = abs(normrnd(0.01,10,[nExperimentFiles,1]));
			end
		end

	end

end
