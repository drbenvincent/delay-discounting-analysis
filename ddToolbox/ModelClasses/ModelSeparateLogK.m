classdef ModelSeparateLogK < Model
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties (Access = private)
		getDiscountRate
	end

	methods (Access = public)

		function obj = ModelSeparateLogK(data, varargin)
			obj = obj@Model(data, varargin{:});

			obj.modelType = 'separateLogK';
			obj.discountFuncType = 'logk';
			obj.getDiscountRate = @getLogDiscountRate; % <-------------------------------------- FINISH

			% Create variables
			obj.varList.participantLevel = {'logk','alpha','epsilon'};
			obj.varList.monitored = {'logk','alpha','epsilon', 'Rpostpred', 'P'};

			%% Plotting
			obj.experimentFigPlotFuncs		= make_experimentFigPlotFuncs_LogK();
			obj.plotFuncs.clusterPlotFunc	= @plotLOGKclusters; 

			% MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
			obj = obj.conductInference();
		end

		function initialParams = setInitialParamValues(obj, nchains)
            % Generate initial values of the leaf nodes
			nExperimentFiles = obj.data.nExperimentFiles;
			for chain = 1:nchains
				initialParams(chain).logk = normrnd(log(1/365),10, [nExperimentFiles,1]);
				initialParams(chain).epsilon = 0.1 + rand([nExperimentFiles,1])/10;
				initialParams(chain).alpha = abs(normrnd(0.01,10,[nExperimentFiles,1]));
			end
		end

		function conditionalDiscountRates(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end

		function conditionalDiscountRates_GroupLevel(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end

	end
	
end
