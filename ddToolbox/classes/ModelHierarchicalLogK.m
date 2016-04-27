classdef ModelHierarchicalLogK < Model
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)
		% =================================================================
		function obj = ModelHierarchicalLogK(toolboxPath, samplerType, data, saveFolder, varargin)
			obj = obj@Model(data, saveFolder, varargin{:});

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
			obj.varList.participantLevel = {'logk','alpha','epsilon'};
			obj.varList.groupLevel ={'logk_group','alpha_group','epsilon_group'};
			obj.varList.monitored = {'logk','alpha','epsilon',...
				'logk_group','alpha_group','epsilon_group',...
				'logk_group_prior','epsilon_group_prior','alpha_group_prior',...
				'groupLogKmu', 'groupLogKsigma','groupW','groupK','groupALPHAmu','groupALPHAsigma',...
				'groupLogKmu_prior', 'groupLogKsigma_prior','groupW_prior','groupK_prior','groupALPHAmu_prior','groupALPHAsigma_prior',...
				'Rpostpred'};

			%% Deal with generating initial values of root nodes
			obj.variables.logk_group	= Variable('logk_group',...
				'seed', @() normrnd(-0.243,2),...
				'str_latex', '\log(k)_{group}',...
				'analysisFlag', 2,...
				'single',true);

			obj.variables.epsilon_group	= Variable('epsilon_group',...
				'seed', @() 0.1 + rand/10,...
				'str_latex', '\epsilon_{group}',...%'analysisFlag', 2,...
				'single',true);

			obj.variables.alpha_group	= Variable('m_group',...
				'seed', @() @() abs(normrnd(0.01,10)),...
				'str_latex', '\alpha_{group}',... %'analysisFlag', 2,...
				'single',true);

			obj.variables.groupLogKmu = Variable('groupLogKmu');
			obj.variables.groupLogKsigma = Variable('groupLogKsigma');

			obj.variables.groupW = Variable('groupW');
			obj.variables.groupK = Variable('groupK');

			obj.variables.groupALPHAmu = Variable('groupALPHAmu');
			obj.variables.groupALPHAsigma = Variable('groupALPHAsigma');

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
