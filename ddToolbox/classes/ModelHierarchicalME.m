classdef ModelHierarchicalME < Model
	%ModelHierarchicalME A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)
		% =================================================================
		function obj = ModelHierarchicalME(toolboxPath, samplerType, data, saveFolder, varargin)
			obj = obj@Model(data, saveFolder, varargin{:});

			switch samplerType
				case{'JAGS'}
					modelPath = '/models/hierarchicalME.txt';
					obj.sampler = JAGSSampler([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
				case{'STAN'}
					modelPath = '/models/hierarchicalME.stan';
					obj.sampler = STANSampler([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
			end
			obj.discountFuncType = 'me';
			obj.plotFuncs.participantFigFunc = @figParticipantME;

			%% Create variables
			obj.varList.participantLevel = {'m', 'c','alpha','epsilon'};
			obj.varList.groupLevel = {'m_group', 'c_group','alpha_group','epsilon_group'};
			obj.varList.monitored = {'m', 'c','alpha','epsilon',...
				'm_group', 'c_group','alpha_group','epsilon_group',...
				'm_group_prior', 'c_group_prior','epsilon_group_prior','alpha_group_prior',...
				'groupMmu', 'groupMsigma', 'groupCmu','groupCsigma','groupW','groupK','groupALPHAmu','groupALPHAsigma',...
				'groupMmu_prior', 'groupMsigma_prior', 'groupCmu_prior','groupCsigma_prior','groupW_prior','groupK_prior','groupALPHAmu_prior','groupALPHAsigma_prior',...
				'Rpostpred'};

			%% Deal with generating initial values of root nodes
			% TODO: ADD SEED FUNCTIONS TO THESE
			obj.variables.groupMmu = Variable('groupMmu',...
				'str_latex','\mu^m group',...
				'seed', @() normrnd(-0.243,2),...% CHECK!
				'single',true); 
			obj.variables.groupMsigma = Variable('groupMsigma',...
				'str_latex', '\sigma^m group',...
				'single',true);

			obj.variables.groupCmu = Variable('groupCmu',...
				'str_latex','\mu^c group',...
				'single',true);
			obj.variables.groupCsigma = Variable('groupCsigma',...
				'str_latex', '\sigma^c group',...
				'single',true);

 			obj.variables.groupW = Variable('groupW');
 			obj.variables.groupK = Variable('groupK');

			obj.variables.groupALPHAmu = Variable('groupALPHAmu');
			obj.variables.groupALPHAsigma = Variable('groupALPHAsigma');

		end
		% =================================================================



		%% ******** SORT OUT WHERE THESE AND OTHER FUNCTIONS SHOULD BE *************
		function conditionalDiscountRates(obj, reward, plotFlag)
			% For group level and all participants, extract and plot P( log(k) | reward)
			warning('THIS METHOD IS A TOTAL MESS - PLAN THIS AGAIN FROM SCRATCH')
			obj.conditionalDiscountRates_ParticipantLevel(reward, plotFlag)
			obj.conditionalDiscountRates_GroupLevel(reward, plotFlag)
			if plotFlag % FORMATTING OF FIGURE
				removeYaxis
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
