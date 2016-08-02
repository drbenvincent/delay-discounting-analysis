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

			% Create variables
			obj.varList.participantLevel = {'logk','alpha','epsilon'};
			obj.varList.monitored = {'logk','alpha','epsilon',...
				'Rpostpred', 'P'};

			obj = obj.addUnobservedParticipant('GROUP');
			
			%% Plotting
			obj.participantFigPlotFuncs		= make_participantFigPlotFuncs_LogK();
			obj.plotFuncs.clusterPlotFunc	= @plotLOGKclusters;

			% MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
			obj = obj.conductInference();
		end


		function initialParams = setInitialParamValues(obj)
			% Generate initial values of the leaf nodes
			nParticipants = obj.data.nParticipants;
			for chain = 1:obj.sampler.mcmcparams.nchains
				initialParams(chain).groupW             = rand;
				initialParams(chain).groupALPHAmu		= rand*100;
				initialParams(chain).groupALPHAsigma	= rand*100;
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
