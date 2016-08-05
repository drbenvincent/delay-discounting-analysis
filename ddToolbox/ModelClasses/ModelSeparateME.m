classdef ModelSeparateME < Model
	%ModelSeperate A model to estimate the magnitide effect.
	%	Models a number of participants, but they are all treated as independent.
	%	There is no group-level estimation.
	
	properties (Access = protected)
	end
	
	
	methods (Access = public)
		
		function obj = ModelSeparateME(data, varargin)
			obj = obj@Model(data, varargin{:});
			
			obj.modelType = 'separateME';
			obj.discountFuncType = 'me';
			obj.getDiscountRate = @getDiscountRate; % <-------------------------------------- FINISH
			
			% Create variables
			obj.varList.participantLevel = {'m', 'c','alpha','epsilon'};
			obj.varList.monitored = {'m', 'c','alpha','epsilon', 'Rpostpred', 'P'};
			
			%% Plotting stuff
			obj.participantFigPlotFuncs		= make_participantFigPlotFuncs_ME();
			obj.plotFuncs.clusterPlotFunc	= @plotMCclusters;
			
			% MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
			obj = obj.conductInference();
		end
		
		function initialParams = setInitialParamValues(obj, nchains)
			% Generate initial values of the leaf nodes
			nParticipants = obj.data.nParticipants;
			for chain = 1:nchains
				initialParams(chain).m			= normrnd(-0.243,2, [nParticipants,1]);
				initialParams(chain).c			= normrnd(0,10, [nParticipants,1]);
				initialParams(chain).alpha		= abs(normrnd(0.01,10, [nParticipants,1]));
				initialParams(chain).epsilon	= 0.1 + rand([nParticipants,1])/10;
			end
		end
		
	end
	
	methods (Access = protected)
		
		function obj = calcDerivedMeasures(obj)
		end
		
	end
	
end
