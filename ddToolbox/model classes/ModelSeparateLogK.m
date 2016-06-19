classdef ModelSeparateLogK < Model
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)
		% =================================================================
		function obj = ModelSeparateLogK(toolboxPath, samplerType, data, saveFolder, varargin)
			obj = obj@Model(data, saveFolder, varargin{:});

			switch samplerType
				case{'JAGS'}
					modelPath = '/models/separateLogK.txt';
					obj.sampler = MatjagsWrapper([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
				case{'STAN'}
					modelPath = '/models/separateLogK.stan';
					obj.sampler = MatlabStanWrapper([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
			end
			obj.discountFuncType = 'logk';
			% 'Decorate' the object with appropriate plot functions
			obj.plotFuncs.participantFigFunc = @figParticipantLOGK;
			%obj.plotFuncs.figParticipantWrapperFunc = @figParticipantLevelWrapperLOGK;
			obj.plotFuncs.plotGroupLevel = @(x) []; % null function

			%% Create variables
			obj.varList.participantLevel = {'logk','alpha','epsilon'};
            obj.varList.participantLevelPriors = {'logk_prior','alpha_prior','epsilon_prior'};
			obj.varList.groupLevel = {};
			obj.varList.monitored = {'logk','alpha','epsilon',...
				'logk_prior','alpha_prior','epsilon_prior',...
				'Rpostpred', 'P'};
		end
		% =================================================================

		% Generate initial values of the leaf nodes
		function setInitialParamValues(obj)

			nTrials = size(obj.data.observedData.A,2);
			nParticipants = obj.data.nParticipants;
			nUniqueDelays = numel(obj.data.observedData.uniqueDelays);

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
