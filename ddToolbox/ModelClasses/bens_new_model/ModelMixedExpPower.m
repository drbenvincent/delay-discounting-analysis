classdef ModelMixedExpPower < ExponentialPower
	%ModelMixedExp1 

	methods (Access = public)
		function obj = ModelMixedExp1(data, varargin)
			obj = obj@ExponentialPower(data, varargin{:});
			obj.modelFilename = 'mixedExpPower';
            obj = obj.addUnobservedParticipant('GROUP');
            
            % MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
            obj = obj.conductInference();
		end
    end
    
    methods 
    
		function initialParams = initialiseChainValues(obj, nchains)
			% Generate initial values of the root nodes
			nExperimentFiles = obj.data.getNExperimentFiles();
			for chain = 1:nchains
				initialParams(chain).groupW             = rand;
				initialParams(chain).groupALPHAmu		= rand*100;
				initialParams(chain).groupALPHAsigma	= rand*100;
			end
		end
        
	end

end
