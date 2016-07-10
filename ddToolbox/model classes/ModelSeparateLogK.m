classdef ModelSeparateLogK < Model
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)
		function obj = ModelSeparateLogK(samplerType, data, saveFolder, varargin)

			samplerType = lower(samplerType);
			modelType		= 'separateLogK';
			modelPath = makeProbModelsPath(modelType, samplerType);

			obj = obj@Model(data, saveFolder, samplerType, modelPath, varargin{:});

			obj.discountFuncType = 'logk';

			% 'Decorate' the object with appropriate plot functions
			obj.plotFuncs.participantFigFunc = @figParticipantLOGK;
			obj.plotFuncs.plotGroupLevel = @(x) []; % null function

			%% Create variables
			obj.varList.participantLevel = {'logk','alpha','epsilon'};
			obj.varList.participantLevelPriors = {'logk_prior','alpha_prior','epsilon_prior'};
			obj.varList.groupLevel = {};
			obj.varList.monitored = {'logk','alpha','epsilon',...
				'logk_prior','alpha_prior','epsilon_prior',...
				'Rpostpred', 'P'};
		end

		% Generate initial values of the leaf nodes
		function setInitialParamValues(obj)

			%nTrials = size(obj.data.observedData.A,2);
			nParticipants = obj.data.nParticipants;
			%nUniqueDelays = numel(obj.data.observedData.uniqueDelays);

			for chain = 1:obj.sampler.mcmcparams.nchains
				obj.initialParams(chain).logk = normrnd(log(1/365),10, [nParticipants,1]);
				obj.initialParams(chain).epsilon = 0.1 + rand([nParticipants,1])/10;
				obj.initialParams(chain).alpha = abs(normrnd(0.01,10,[nParticipants,1]));
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
