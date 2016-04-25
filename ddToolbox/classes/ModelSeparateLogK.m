classdef ModelSeparateLogK < Model
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)
		% =================================================================
		function obj = ModelSeparateLogK(toolboxPath, samplerType, data, saveFolder, varargin)
			obj = obj@Model(samplerType, data, saveFolder, varargin);

			switch samplerType
				case{'JAGS'}
					modelPath = '/models/separateLogK.txt';
					obj.sampler = JAGSSampler([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
				case{'STAN'}
					modelPath = '/models/separateLogK.stan';
					obj.sampler = STANSampler([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
			end
			obj.discountFuncType = 'logk';
			obj.plotFuncs.participantFigFunc = @figParticipantLOGK;
			obj.plotFuncs.figParticipantWrapperFunc = @figParticipantLevelWrapperLOGK;

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


			% Participant-level -------------------------------------------------
			obj.variables.logk = Variable('logk',...
				'str_latex', '\log (k)',...
				'bounds', [-inf inf],...
				'seed', @() normrnd(log(1/365),10),...
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

			obj.variables.logk_prior	= Variable('log_k_prior');
			obj.variables.epsilon_prior	= Variable('epsilon_prior');
			obj.variables.alpha_prior	= Variable('alpha_prior');

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
