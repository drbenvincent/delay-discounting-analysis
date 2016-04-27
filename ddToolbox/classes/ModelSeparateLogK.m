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

			obj.varList.participantLevel = {'logk','alpha','epsilon'};
			obj.varList.groupLevel = {};
			obj.varList.monitored = {'logk','alpha','epsilon',...
				'logk_prior','alpha_prior','epsilon_prior',...
				'Rpostpred'};
			
			%% Deal with generating initial values of leaf nodes
			obj.variables.logk = Variable('logk',...
				'str_latex', '\log (k)',...
				'seed', @() normrnd(log(1/365),10));
			
			obj.variables.epsilon = Variable('epsilon',...
				'str_latex', '\epsilon',...
				'seed', @() 0.1 + rand/10);
			
			obj.variables.alpha = Variable('alpha',...
				'str_latex', '\alpha',...
				'seed', @() abs(normrnd(0.01,10)));

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
