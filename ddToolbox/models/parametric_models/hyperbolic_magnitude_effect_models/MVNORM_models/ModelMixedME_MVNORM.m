classdef ModelMixedME_MVNORM < Hyperbolic1MagEffectMV
	%ModelHierarchicalME A model to estimate the magnitide effect
	%   Detailed explanation goes here

	methods (Access = public, Hidden = true)

		function obj = ModelMixedME_MVNORM(data, varargin)
			obj = obj@Hyperbolic1MagEffectMV(data, varargin{:});
			obj.modelFilename = 'mixedMEmvnorm';
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
