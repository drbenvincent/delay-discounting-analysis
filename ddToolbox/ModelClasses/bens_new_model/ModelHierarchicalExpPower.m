classdef ModelHierarchicalExpPower < ExponentialPower
	%ModelHierarchical A model to estimate the log discount rate, according to the 1-parameter hyperbolic discount function.
    %  All parameters are estimated hierarchically.

	methods (Access = public)

		function obj = ModelHierarchicalExpPower(data, varargin)
			obj = obj@ExponentialPower(data, varargin{:});
            obj.modelFilename = 'hierarchicalExpPower';
            obj = obj.addUnobservedParticipant('GROUP');
            
            % MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
            obj = obj.conductInference();
        end

	end

	
	methods 
		
		function initialParams = initialiseChainValues(obj, nchains)
			% Generate initial values of the root nodes
			for chain = 1:nchains
				initialParams(chain).groupKmu		    = normrnd(0.001,0.1);
				initialParams(chain).groupKsigma		= rand*5;
				initialParams(chain).groupTAUmu		    = normrnd(00,0.1); % <---- check
				initialParams(chain).groupTAUsigma		= rand*5;% <---- check
				initialParams(chain).groupW				= rand;
				initialParams(chain).groupALPHAmu		= rand*10;
				initialParams(chain).groupALPHAsigma	= rand*5;
                
                % TODO: prior over group-level tau parameters
			end
		end
        
	end

end
