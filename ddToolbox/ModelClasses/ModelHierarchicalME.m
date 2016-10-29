classdef ModelHierarchicalME < Hyperbolic1MagEffect
	%ModelHierarchicalME A model to estimate the magnitide effect
	%   Detailed explanation goes here
	
	methods (Access = public)
		
		function obj = ModelHierarchicalME(data, varargin)
			obj = obj@Hyperbolic1MagEffect(data, varargin{:});
			obj.modelFilename = 'hierarchicalME';
			obj = obj.addUnobservedParticipant('GROUP');
            
            % additional variable for this model 
            obj.varList.monitored{end+1} = 'm_prior';
            			
			% MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
			obj = obj.conductInference();
		end
		
    end
        
    methods
        
		function initialParams = initialiseChainValues(obj, nchains)
			% Generate initial values of the root nodes
			for chain = 1:nchains
				initialParams(chain).groupMmu		= normrnd(-0.243,10);
				initialParams(chain).groupMsigma	= rand*10;
				initialParams(chain).groupCmu		= normrnd(0,30);
				initialParams(chain).groupCsigma	= rand*10;
				initialParams(chain).groupW			= rand;
				initialParams(chain).groupALPHAmu	= rand*10;
				initialParams(chain).groupALPHAsigma= rand*10;
			end
		end
		
	end
	
end
