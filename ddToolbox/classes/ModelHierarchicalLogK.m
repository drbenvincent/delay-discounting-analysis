classdef ModelHierarchicalLogK < Model
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)
		% =================================================================
		function obj = ModelHierarchicalLogK(toolboxPath, samplerType, data, saveFolder)
			obj = obj@Model(toolboxPath, samplerType, data, saveFolder);

			switch samplerType
				case{'JAGS'}
					modelPath = '/models/hierarchicalLogK.txt';
					obj.sampler = JAGSSampler([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
				case{'STAN'}
					modelPath = '/models/hierarchicalLogK.stan';
					obj.sampler = STANSampler([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
			end
			obj.discountFuncType = 'logk';
			obj.plotFuncs.participantFigFunc = @figParticipantLOGK;

			%% Create variables
			% The intent of this code below is to set up the key variables of the
			% model. This is so that we can:
			%  1. Tell JAGS what variables to monitor.
			%  2. Generate initial parameters for the MCMC chains.
			%  3. Have meaningful variable names (and latex strings), which helps
			%  for plotting.
			%  4. Have labels for participant-level and group-level parameters,
			%  also helps plotting.

			% Variable list, used for plotting
			obj.varList.participantLevel = {'logk','alpha','epsilon'};
			obj.varList.groupLevel ={'logk_group','alpha_group','epsilon_group'};


			% Participant-level -------------------------------------------------
			obj.variables.logk = Variable('logk',...
				'str_latex', '\log (k)',...
				'bounds', [-inf inf],...
				'seed', @() normrnd(-0.243,10),...
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

			% -------------------------------------------------------------------
			% group level (ie what we expect from an as yet unobserved person ---
			obj.variables.logk_group	= Variable('logk_group',...
				'seed', @() normrnd(-0.243,2),...
				'str_latex', '\log(k)_{group}',...
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

			obj.variables.logk_group_prior	= Variable('logk_group_prior');
			obj.variables.epsilon_group_prior	= Variable('epsilon_group_prior');
			obj.variables.alpha_group_prior	= Variable('alpha_group_prior');

			% group level priors ------------------------------------------------
			obj.variables.groupLogKmu = Variable('groupLogKmu', 'bounds', [-inf inf]);
			obj.variables.groupLogKmu_prior = Variable('groupLogKmu_prior', 'bounds', [-inf inf]);
			obj.variables.groupLogKsigma = Variable('groupLogKsigma', 'bounds', [-inf inf]);
			obj.variables.groupLogKsigma_prior = Variable('groupLogKsigma_prior', 'bounds', [-inf inf]);

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

		function conditionalDiscountRates(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end

		function conditionalDiscountRates_GroupLevel(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end

	end

end
