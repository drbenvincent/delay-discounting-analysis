classdef ModelHierarchicalME < Model
	%ModelHierarchicalME A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)

		function obj = ModelHierarchicalME(samplerType, data, saveFolder, varargin)

			samplerType     = lower(samplerType);
			modelType		= 'hierarchicalME';
			
			modelPath = makeProbModelsPath(modelType, samplerType);

			obj = obj@Model(data, saveFolder, samplerType, modelPath, varargin{:});

			obj.discountFuncType = 'me';
            
			obj.plotFuncs.participantFigFunc = @figParticipantME;
			obj.plotFuncs.plotGroupLevel = @plotGroupLevelStuff;

			%% Create variables
			% TODO: These lists could be removed with some work
			obj.varList.participantLevel = {'m', 'c','alpha','epsilon'};
            obj.varList.participantLevelPriors = {'m_group_prior', 'c_group_prior','alpha_group_prior','epsilon_group_prior'};
			obj.varList.groupLevel = {'m_group', 'c_group','alpha_group','epsilon_group'};

			% These need to be kept for JAGS
			obj.varList.monitored = {'m', 'c','alpha','epsilon',...
				'm_group', 'c_group','alpha_group','epsilon_group',...
				'm_group_prior', 'c_group_prior','epsilon_group_prior','alpha_group_prior',...
				'groupMmu', 'groupMsigma', 'groupCmu','groupCsigma','groupW','groupK','groupALPHAmu','groupALPHAsigma',...
				'groupMmu_prior', 'groupMsigma_prior', 'groupCmu_prior','groupCsigma_prior','groupW_prior','groupK_prior','groupALPHAmu_prior','groupALPHAsigma_prior',...
				'Rpostpred', 'P'};

		end


		% Generate initial values of the leaf nodes
		function setInitialParamValues(obj)

% 			nTrials = size(obj.data.observedData.A,2);
% 			nParticipants = obj.data.nParticipants;
% 			nUniqueDelays = numel(obj.data.observedData.uniqueDelays);

			for chain = 1:obj.sampler.mcmcparams.nchains
				obj.initialParams(chain).groupMmu = normrnd(-0.243,10);
				obj.initialParams(chain).groupMsigma = rand*10;
				obj.initialParams(chain).groupCmu = normrnd(0,30);
				obj.initialParams(chain).groupCsigma = rand*10;
				obj.initialParams(chain).groupW = rand;
				obj.initialParams(chain).groupALPHAmu		= rand*100;
				obj.initialParams(chain).groupALPHAsigma	= rand*100;
			end
		end



		%% ******** SORT OUT WHERE THESE AND OTHER FUNCTIONS SHOULD BE *************
		function conditionalDiscountRates(obj, reward, plotFlag)
			% For group level and all participants, extract and plot P( log(k) | reward)
			warning('THIS METHOD IS A TOTAL MESS - PLAN THIS AGAIN FROM SCRATCH')
			obj.conditionalDiscountRates_ParticipantLevel(reward, plotFlag)
			obj.conditionalDiscountRates_GroupLevel(reward, plotFlag)
			if plotFlag % FORMATTING OF FIGURE
				mcmc.removeYaxis()
				title(sprintf('$P(\\log(k)|$reward=$\\pounds$%d$)$', reward),'Interpreter','latex')
				xlabel('$\log(k)$','Interpreter','latex')
				axis square
				%legend(lh.DisplayName)
			end
		end

		function conditionalDiscountRates_GroupLevel(obj, reward, plotFlag)
			GROUP = obj.data.nParticipants; % last participant is our unobserved
			params = obj.mcmc.getSamplesFromParticipantAsMatrix(GROUP, {'m','c'});
			[posteriorMean, lh] = calculateLogK_ConditionOnReward(reward, params, plotFlag);
			lh.LineWidth = 3;
			lh.Color= 'k';
		end

	end

end
