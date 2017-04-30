classdef ModelMixedEbertPrelec < EbertPrelec

	methods (Access = public)
		function obj = ModelMixedEbertPrelec(data, varargin)
			obj = obj@EbertPrelec(data, varargin{:});
			obj.modelFilename = 'mixedExpPower';
            obj = obj.addUnobservedParticipant('GROUP');
            
            % MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
            obj = obj.conductInference();
		end

    end
    
    methods (Access = protected)
    
		function initialParams = initialiseChainValues(obj, nchains)
			% Generate initial values of the root nodes
			nExperimentFiles = obj.data.getNExperimentFiles();
			for chain = 1:nchains
% 				initialParams(chain).k = unifrnd(0.01, 0.5, [nExperimentFiles,1]);
%                 initialParams(chain).tau = unifrnd(0.01, 2, [nExperimentFiles,1]);
				
				initialParams(chain).groupW             = rand;
				initialParams(chain).groupALPHAmu		= rand*100;
				initialParams(chain).groupALPHAsigma	= rand*100;
			end
		end
        
	end

end
