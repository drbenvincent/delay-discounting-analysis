classdef ModelHierarchicalEbertPrelec < EbertPrelec


	methods (Access = public, Hidden = true)

		function obj = ModelHierarchicalEbertPrelec(data, varargin)
			obj = obj@EbertPrelec(data, varargin{:});
            obj.modelFilename = 'hierarchicalEbertPrelec';
            obj = obj.addUnobservedParticipant('GROUP');
            
            % MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
            obj = obj.conductInference();
        end

    end
    
    methods (Access = protected)
		
		function initialParams = initialiseChainValues(obj, nchains)
			% Generate initial values of the root nodes
			for chain = 1:nchains
				initialParams(chain).groupKmu		= normrnd(1,1);
				initialParams(chain).groupKsigma		= rand*5;
				initialParams(chain).groupW				= rand;
				initialParams(chain).groupALPHAmu		= rand*10;
				initialParams(chain).groupALPHAsigma	= rand*5;
			end
		end
        
	end

end
