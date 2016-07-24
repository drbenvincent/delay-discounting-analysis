classdef ModelMixedLogK < Model
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here
	
	properties
	end
	
	
	methods (Access = public)
		
		function obj = ModelMixedLogK(data, varargin)
			
			obj = obj@Model(data, varargin{:});
			
			obj.modelType = 'mixedLogK';
			obj.discountFuncType = 'logk';
			
			% Decorate the object with appropriate plot functions
			obj.plotFuncs.participantFigFunc = @figParticipantLOGK;
			obj.plotFuncs.clusterPlotFunc = @plotLOGKclusters;
			
			% Create variables
			obj.varList.participantLevel = {'logk','alpha','epsilon'};
			obj.varList.monitored = {'logk','alpha','epsilon',...
				'Rpostpred', 'P'};
		end
		
		
		function obj = setInitialParamValues(obj)
			% Generate initial values of the leaf nodes
			nParticipants = obj.data.nParticipants;
			for chain = 1:obj.sampler.mcmcparams.nchains
				obj.initialParams(chain).groupW             = rand;
				obj.initialParams(chain).groupALPHAmu		= rand*100;
				obj.initialParams(chain).groupALPHAsigma	= rand*100;
			end
		end
		
		function conditionalDiscountRates(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end
		
		function conditionalDiscountRates_GroupLevel(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end
		
		
	end
	
	methods (Access = protected)
		
		function obj = calcDerivedMeasures(obj)
		end
		
	end
	
end
