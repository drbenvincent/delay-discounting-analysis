classdef ModelMixedME < Hyperbolic1MagEffect
	%ModelHierarchicalME A model to estimate the magnitide effect
	%   Detailed explanation goes here

	methods (Access = public)

		function obj = ModelMixedME(data, varargin)
			obj = obj@Hyperbolic1MagEffect(data, varargin{:});
			obj.modelFilename = 'mixedME';
			obj = obj.addUnobservedParticipant('GROUP');

			% MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
			obj = obj.conductInference();
		end

    end
    
    methods
		
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
