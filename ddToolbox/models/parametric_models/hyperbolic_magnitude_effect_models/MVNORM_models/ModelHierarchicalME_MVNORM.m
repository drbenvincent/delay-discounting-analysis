classdef ModelHierarchicalME_MVNORM < Hyperbolic1MagEffectMV
	%ModelHierarchicalME_MVNORM A model to estimate the magnitide effect. It models (m,c) as drawn from a bivariate Normal distribution.

	methods (Access = public, Hidden = true)

		function obj = ModelHierarchicalME_MVNORM(data, varargin)
			obj = obj@Hyperbolic1MagEffectMV(data, varargin{:});
			obj.modelFilename = 'hierarchicalMEmvnorm';
            obj = obj.addUnobservedParticipant('GROUP');
            
            % MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
            obj = obj.conductInference();
		end

    end
    
    methods (Access = protected)
    
		function initialParams = initialiseChainValues(obj, nchains)
			% Generate initial values of the root nodes
			for chain = 1:nchains
				initialParams(chain).groupW			= rand;
				initialParams(chain).groupALPHAmu	= rand*10;
				initialParams(chain).groupALPHAsigma= rand*10;
			end
		end
	end

end
