classdef ModelHierarchicalBetaDelta < BetaDelta
	%ModelHierarchicalBetaDelta Model class for fully hierarchical estimation of the beta-delta discount function.
    %  All parameters are estimated hierarchically.

	methods (Access = public, Hidden = true)

		function [obj] = ModelHierarchicalBetaDelta(data, varargin)
			obj = obj@BetaDelta(data, varargin{:});
            obj.modelFilename = 'hierarchicalBetaDelta';
            obj = obj.addUnobservedParticipant('GROUP');

            % MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
            obj = obj.conductInference();
        end

    end

    methods (Access = protected)

		function initialParams = initialiseChainValues(obj, nchains)
			% Generate initial values of the root nodes
			for chain = 1:nchains
				initialParams(chain).groupW				= rand;
				initialParams(chain).groupALPHAmu		= rand*10;
				initialParams(chain).groupALPHAsigma	= rand*5;
			end
		end

	end

end
