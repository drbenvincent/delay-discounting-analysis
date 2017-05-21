classdef ModelSeparateEbertPrelec < EbertPrelec


	methods (Access = public)

		function obj = ModelSeparateEbertPrelec(data, varargin)
			obj = obj@EbertPrelec(data, varargin{:});
            obj.modelFilename = 'separateEbertPrelec';
            
            % MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
            obj = obj.conductInference();
        end

    end
    
    methods (Access = protected)
		
		function initialParams = initialiseChainValues(obj, nchains)
			% Generate initial values of the root nodes
			nExperimentFiles = obj.data.getNExperimentFiles();
			for chain = 1:nchains
				initialParams(chain).epsilon = 0.01 + rand([nExperimentFiles,1])./10;
				initialParams(chain).alpha = abs(normrnd(0.01,5,[nExperimentFiles,1]));
			end
		end
        
	end

end
