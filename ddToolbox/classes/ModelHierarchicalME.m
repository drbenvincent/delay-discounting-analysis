classdef ModelHierarchicalME < Model
	%ModelHierarchicalME A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)
		% =================================================================
		function obj = ModelHierarchicalME(toolboxPath, samplerType, data, saveFolder)
			obj = obj@Model(toolboxPath, samplerType, data, saveFolder);

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


			obj.plotFuncs.unseenParticipantPlot = @figGroupLevelWrapperME;
			obj.plotFuncs.figParticipantWrapperFunc = @figParticipantLevelWrapperME;

			%% Create variables
			% The intent of this code below is to set up the key variables of the
			% model. This is so that we can:
			%  1. Tell JAGS what variables to monitor.
			%  2. Generate initial parameters for the MCMC chains.
			%  3. Have meaningful variable names (and latex strings), which helps
			%  for plotting.
			%  4. Have labels for participant-level and group-level parameters,
			%  also helps plotting.

			% Variable lists, used for plotting
			obj.varList.participantLevel = {'m', 'c','alpha','epsilon'};
			obj.varList.groupLevel = {'m_group', 'c_group','alpha_group','epsilon_group'};

			% Participant-level -------------------------------------------------
			obj.variables.m = Variable('m',...
				'bounds', [-inf inf],...
				'seed', @() normrnd(-0.243,2),...
				'analysisFlag',1);

			obj.variables.c = Variable('c',...
				'bounds', [-inf inf],...
				'seed', @() @() normrnd(0,10),...
				'analysisFlag',1);

			obj.variables.epsilon = Variable('epsilon',...
				'str_latex', '\epsilon',...
				'bounds', [0 0.5],...
				'seed', @() 0.1 + rand/10,...
				'analysisFlag',1);

			obj.variables.alpha = Variable('alpha',...
				'str_latex', '\alpha',...
				'bounds', [0 inf],...
				'seed', @() abs(normrnd(0.01,10)),...
				'analysisFlag',1 );


			obj.variables.m_group	= Variable('m_group',...
				'seed', @() normrnd(-0.243,2),...
				'str_latex', 'm_{group}',...
				'analysisFlag', 2,...
				'single',true);

			obj.variables.c_group	= Variable('c_group',...
				'seed', @() normrnd(0,10),...
				'str_latex', 'm_{group}',...
				'analysisFlag', 2,...
				'single',true);

			obj.variables.epsilon_group	= Variable('epsilon_group',...
				'seed', @() 0.1 + rand/10,...
				'str_latex', '\epsilon_{group}',...
				'analysisFlag', 2,...
				'single',true);

			obj.variables.alpha_group	= Variable('m_group',...
				'seed', @() @() abs(normrnd(0.01,10)),...
				'str_latex', '\alpha_{group}',...
				'analysisFlag', 2,...
				'single',true);

			obj.variables.m_group_prior	= Variable('m_group_prior');
			obj.variables.c_group_prior	= Variable('c_group_prior');
			obj.variables.epsilon_group_prior	= Variable('epsilon_group_prior');
			obj.variables.alpha_group_prior	= Variable('alpha_group_prior');

			% group level priors ------------------------------------------------
			% TODO: ADD SEED FUNCTIONS TO THESE
			obj.variables.groupMmu = Variable('groupMmu',...
				'str_latex','\mu^m group');
			obj.variables.groupMsigma = Variable('groupMsigma',...
				'str_latex', '\sigma^m group');


			obj.variables.groupCmu = Variable('groupCmu',...
				'str_latex','\mu^c group');
			obj.variables.groupCsigma = Variable('groupCsigma',...
				'str_latex', '\sigma^c group');

			obj.variables.groupW = Variable('groupW',...
				'bounds', [0 1]);
			obj.variables.groupK = Variable('groupK',...
				'bounds', [0 inf]);

			obj.variables.groupW_prior = Variable('groupW_prior',...
				'bounds', [0 1]);
			obj.variables.groupK_prior = Variable('groupK_prior',...
				'bounds', [0 inf]);


			obj.variables.groupALPHAmu = Variable('groupALPHAmu');
			obj.variables.groupALPHAsigma = Variable('groupALPHAsigma');

			obj.variables.groupALPHAmu_prior = Variable('groupALPHAmu_prior');
			obj.variables.groupALPHAsigma_prior = Variable('groupALPHAsigma_prior');

			% observed response
			obj.variables.Rpostpred = Variable('R', 'bounds', [0 1]);

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
