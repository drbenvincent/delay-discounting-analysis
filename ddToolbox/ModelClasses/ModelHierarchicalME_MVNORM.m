classdef ModelHierarchicalME_MVNORM < Hierarchical1MagEffect
	%ModelHierarchicalME_MVNORM A model to estimate the magnitide effect. It models (m,c) as drawn from a bivariate Normal distribution.

	methods (Access = public)

		function obj = ModelHierarchicalME_MVNORM(data, varargin)
			obj = obj@Hierarchical1MagEffect(data, varargin{:});
			obj.modelFilename = 'hierarchicalMEmvnorm';

			% Create variables ~~~~~~~~~
            % TODO: just append new ones to those already made by superclass
			obj.varList.participantLevel = {'m','c', 'r', 'alpha','epsilon'};
			obj.varList.monitored = {'r', 'm', 'c', 'mc_mu', 'mc_sigma','alpha','epsilon',  'Rpostpred', 'P'};
            % ~~~~~~~~~~~~~~~~~~~~~~~~~~

			warning('ModelHierarchicalME_MVNORM not working with unobserved participant')
            
            % MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
            obj = obj.conductInference();
		end

	end
	

	methods (Static)
		function initialParams = setInitialParamValues(nchains)
			% Generate initial values of the root nodes
			for chain = 1:nchains
				%obj.initialParams(chain).r				= -0.2 + randn/10;
				%obj.initialParams(chain).mc_mu			= [(rand-0.5)*2 randn*5];
				initialParams(chain).groupW			= rand;
				initialParams(chain).groupALPHAmu	= rand*10;
				initialParams(chain).groupALPHAsigma= rand*10;
			end
		end
	end

end
