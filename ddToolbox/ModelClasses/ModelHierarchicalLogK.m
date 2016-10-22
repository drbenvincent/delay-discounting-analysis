classdef ModelHierarchicalLogK < Hierarchical1
	%ModelHierarchical A model to estimate the log discount rate, according to the 1-parameter hyperbolic discount function.
    %  All parameters are estimated hierarchically.

	methods (Access = public)

		function obj = ModelHierarchicalLogK(data, varargin)
			obj = obj@Hierarchical1(data, varargin{:});
            obj.modelFilename = 'hierarchicalLogK';
            obj = obj.addUnobservedParticipant('GROUP');
            
            % MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
            obj = obj.conductInference();
        end

	end

	
	methods 
		
		function initialParams = setInitialParamValues(obj, nchains)
			% Generate initial values of the root nodes
			for chain = 1:nchains
				initialParams(chain).groupLogKmu		= normrnd(log(1/50),1);
				initialParams(chain).groupLogKsigma		= rand*5;
				initialParams(chain).groupW				= rand;
				initialParams(chain).groupALPHAmu		= rand*10;
				initialParams(chain).groupALPHAsigma	= rand*5;
			end
		end
        
	end

end
