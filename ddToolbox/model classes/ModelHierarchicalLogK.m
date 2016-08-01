classdef ModelHierarchicalLogK < Model
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)

		function obj = ModelHierarchicalLogK(data, varargin)
			obj = obj@Model(data, varargin{:});

			obj.modelType		= 'hierarchicalLogK';
			obj.discountFuncType = 'logk';

			% Create variables
			obj.varList.participantLevel = {'logk','alpha','epsilon'};
			obj.varList.monitored = {'logk','alpha','epsilon', 'Rpostpred', 'P'};

			obj = obj.addUnobservedParticipant('GROUP');

			%% Plotting
			obj.participantFigPlotFuncs		= make_participantFigPlotFuncs_LogK();
			obj.plotFuncs.clusterPlotFunc	= @plotLOGKclusters;

		end


		function initialParams = setInitialParamValues(obj)
			% Generate initial values of the leaf nodes
			for chain = 1:obj.sampler.mcmcparams.nchains
				initialParams(chain).groupLogKmu		= normrnd(log(1/50),1);
				initialParams(chain).groupLogKsigma		= rand*5;
				initialParams(chain).groupW				= rand;
				initialParams(chain).groupALPHAmu		= rand*10;
				initialParams(chain).groupALPHAsigma	= rand*5;
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
