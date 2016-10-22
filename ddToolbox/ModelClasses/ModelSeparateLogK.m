classdef ModelSeparateLogK < Hierarchical1
	%ModelHierarchical A model to estimate the magnitide effect
	%  NO parameters are estimated hierarchically.

	methods (Access = public)
		function obj = ModelSeparateLogK(data, varargin)
			obj = obj@Hierarchical1(data, varargin{:});
			obj.modelFilename = 'separateLogK';
            
            % MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
            obj = obj.conductInference();
		end
    end
    
    methods
    
		function initialParams = setInitialParamValues(obj, nchains)
            % Generate initial values of the root nodes
			nExperimentFiles = obj.data.nExperimentFiles;
			for chain = 1:nchains
				initialParams(chain).logk = normrnd(log(1/365),10, [nExperimentFiles,1]);
				initialParams(chain).epsilon = 0.1 + rand([nExperimentFiles,1])/10;
				initialParams(chain).alpha = abs(normrnd(0.01,10,[nExperimentFiles,1]));
			end
		end

	end
	
end
