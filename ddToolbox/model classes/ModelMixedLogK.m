classdef ModelMixedLogK < Model
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)
    		function obj = ModelMixedLogK(toolboxPath, samplerType, data, saveFolder, varargin)

            samplerType     = lower(samplerType);
            modelType		= 'mixedLogK';
            modelPath		= [toolboxPath '/models/' modelType '.' samplerType];

            obj = obj@Model(data, saveFolder, samplerType, modelPath, varargin{:});

			obj.discountFuncType = 'logk';
            
			% 'Decorate' the object with appropriate plot functions
			obj.plotFuncs.participantFigFunc = @figParticipantLOGK;
			obj.plotFuncs.plotGroupLevel = @plotGroupLevelStuff;

			%% Create variables
			obj.varList.participantLevel = {'logk','alpha','epsilon'};
            obj.varList.participantLevelPriors = {'logk_group_prior','alpha_group_prior','epsilon_group_prior'};
			obj.varList.groupLevel = {'logk_group','alpha_group','epsilon_group'};
			obj.varList.monitored = {'logk','alpha','epsilon',...
				'logk_group','alpha_group','epsilon_group',...
				'logk_group_prior','epsilon_group_prior','alpha_group_prior',...
				'groupW','groupK','groupALPHAmu','groupALPHAsigma',...
				'groupLogKmu_prior', 'groupLogKsigma_prior','groupW_prior','groupK_prior','groupALPHAmu_prior','groupALPHAsigma_prior',...
				'Rpostpred', 'P'};
		end

		% Generate initial values of the leaf nodes
		function setInitialParamValues(obj)

			nTrials = size(obj.data.observedData.A,2);
			nParticipants = obj.data.nParticipants;
			nUniqueDelays = numel(obj.data.observedData.uniqueDelays);

			for chain = 1:obj.sampler.mcmcparams.nchains
				obj.initialParams(chain).groupW = rand;
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

end
