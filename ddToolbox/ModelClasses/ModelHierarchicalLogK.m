classdef ModelHierarchicalLogK < Model
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties (Access = private)
		getDiscountRate % function handle
	end

	methods (Access = public)

		function obj = ModelHierarchicalLogK(data, varargin)
			obj = obj@Model(data, varargin{:});

			obj.modelFilename		= 'hierarchicalLogK';
			obj.discountFuncType = 'hyperbolic1';
			obj.getDiscountRate = @getLogDiscountRate; % <-------------------------------------- FINISH

			% Create variables
			obj.varList.participantLevel = {'logk','alpha','epsilon'};
			obj.varList.monitored = {'logk','alpha','epsilon', 'Rpostpred', 'P'};

			obj = obj.addUnobservedParticipant('GROUP');

			%% Plotting
			obj.experimentFigPlotFuncs		= make_experimentFigPlotFuncs_LogK();
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

	
	methods (Static)
		
		function initialParams = setInitialParamValues(nchains)
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
