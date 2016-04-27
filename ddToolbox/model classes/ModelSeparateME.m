classdef ModelSeparateME < Model
	%ModelSeperate A model to estimate the magnitide effect.
	%	Models a number of participants, but they are all treated as independent.
	%	There is no group-level estimation.

	properties (Access = protected)
	end


	methods (Access = public)

		% CONSTRUCTOR =====================================================
		function obj = ModelSeparateME(toolboxPath, sampler, data, saveFolder, varargin)
			% Because this class is a subclass of "Model" then we use
			% this next line to create an instance
			obj = obj@Model(data, saveFolder, varargin{:});

			switch sampler
				case{'JAGS'}
					modelPath = '/models/separateME.txt';
					obj.sampler = MatjagsWrapper([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
					obj.discountFuncType = 'me';
				case{'STAN'}
					error('NOT IMPLEMENTED YET')
			end

			obj.plotFuncs.participantFigFunc = @figParticipantME;
			obj.plotFuncs.figParticipantWrapperFunc = @figParticipantLevelWrapperME;

			%% Create variables
			obj.varList.participantLevel = {'m', 'c','alpha','epsilon'};
			obj.varList.groupLevel = {};
			obj.varList.monitored = {'m', 'c','alpha','epsilon',...
				'm_prior', 'c_prior','alpha_prior','epsilon_prior',...
				'Rpostpred'};

			%% Deal with generating initial values of leaf nodes
			obj.variables.m = Variable('m',...
				'seed', @() normrnd(-0.243,2));

			obj.variables.c = Variable('c',...
				'seed', @() @() normrnd(0,10));

			obj.variables.epsilon = Variable('epsilon',...
				'seed', @() 0.1 + rand/10);

			obj.variables.alpha = Variable('alpha',...
				'seed', @() abs(normrnd(0.01,10)));

		end
		% ================================================================

	end

end
