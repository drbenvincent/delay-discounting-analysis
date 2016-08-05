classdef ModelHierarchicalLogK < Model
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties (Access = private)
		getDiscountRate
	end

	methods (Access = public)

		function obj = ModelHierarchicalLogK(data, varargin)
			obj = obj@Model(data, varargin{:});

			obj.modelType		= 'hierarchicalLogK';
			obj.discountFuncType = 'logk';
			obj.getDiscountRate = @getLogDiscountRate; % <-------------------------------------- FINISH

			% Create variables
			obj.varList.participantLevel = {'logk','alpha','epsilon'};
			obj.varList.monitored = {'logk','alpha','epsilon', 'Rpostpred', 'P'};

			obj = obj.addUnobservedParticipant('GROUP');

			%% Plotting
			obj.participantFigPlotFuncs		= make_participantFigPlotFuncs_LogK();
			obj.plotFuncs.clusterPlotFunc	= @plotLOGKclusters;

			% MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
			obj = obj.conductInference();
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
	
	methods (Static)
		
		function initialParams = setInitialParamValues(nchains)
			% Generate initial values of the leaf nodes
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
