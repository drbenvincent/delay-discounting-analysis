classdef ModelSeparateME < Hyperbolic1MagEffect
	%ModelSeperate A model to estimate the magnitide effect.
	%	Models a number of participants, but they are all treated as independent.
	%	There is no group-level estimation.
	
	methods (Access = public)
		
		function obj = ModelSeparateME(data, varargin)
			obj = obj@Hyperbolic1MagEffect(data, varargin{:});
			obj.modelFilename = 'separateME';
			% MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
			obj = obj.conductInference();
		end
    end
    
    methods
		
		function initialParams = initialiseChainValues(obj, nchains)
			% Generate initial values of the root nodes
			nExperimentFiles = obj.data.getNExperimentFiles();
			for chain = 1:nchains
				initialParams(chain).m			= normrnd(-0.243,2, [nExperimentFiles,1]);
				initialParams(chain).c			= normrnd(0,10, [nExperimentFiles,1]);
				initialParams(chain).alpha		= abs(normrnd(0.01,10, [nExperimentFiles,1]));
				initialParams(chain).epsilon	= 0.1 + rand([nExperimentFiles,1])/10;
			end
		end
		
	end
	
end
