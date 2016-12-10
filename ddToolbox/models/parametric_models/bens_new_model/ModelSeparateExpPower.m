classdef ModelSeparateExpPower < ExponentialPower


	methods (Access = public)

		function obj = ModelSeparateExpPower(data, varargin)
			obj = obj@ExponentialPower(data, varargin{:});
            obj.modelFilename = 'separateExpPower';
            
            % MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
            obj = obj.conductInference();
        end

	end

	
	methods 
		
		function initialParams = initialiseChainValues(obj, nchains)
			% Generate initial values of the root nodes
			nExperimentFiles = obj.data.getNExperimentFiles();
			for chain = 1:nchains
				initialParams(chain).k = unifrnd(0, 0.5, [nExperimentFiles,1]);
                initialParams(chain).tau = unifrnd(0.01, 2, [nExperimentFiles,1]);
				initialParams(chain).epsilon = 0.1 + rand([nExperimentFiles,1])/10;
				initialParams(chain).alpha = abs(normrnd(0.01,10,[nExperimentFiles,1]));
			end
		end
        
	end

end
