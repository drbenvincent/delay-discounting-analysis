classdef ModelMixedLogK < Hyperbolic1
	%ModelMixedLogK A model to estimate the log discount rate, according to the 1-parameter hyperbolic discount function.
	%  SOME parameters are estimated hierarchically.

	methods (Access = public)
		function obj = ModelMixedLogK(data, varargin)
			obj = obj@Hyperbolic1(data, varargin{:});
			obj.modelFilename = 'mixedLogK';
            obj = obj.addUnobservedParticipant('GROUP');
            
            % MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
            obj = obj.conductInference();
		end
    end
    
    methods 
    
		function initialParams = initialiseChainValues(obj, nchains)
			% Generate initial values of the root nodes
			nExperimentFiles = obj.data.nExperimentFiles;
			for chain = 1:nchains
				initialParams(chain).groupW             = rand;
				initialParams(chain).groupALPHAmu		= rand*100;
				initialParams(chain).groupALPHAsigma	= rand*100;
			end
		end
        
	end

end
