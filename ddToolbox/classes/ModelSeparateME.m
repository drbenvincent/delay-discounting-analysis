classdef ModelSeparateME < Model
	%ModelSeperate A model to estimate the magnitide effect.
	%	Models a number of participants, but they are all treated as independent.
	%	There is no group-level estimation.

	properties (Access = protected)
	end


	methods (Access = public)

		% CONSTRUCTOR =====================================================
		function obj = ModelSeparateME(toolboxPath, sampler, data, saveFolder)
			% Because this class is a subclass of "Model" then we use
			% this next line to create an instance
			obj = obj@Model(toolboxPath, sampler, data, saveFolder);

			switch sampler
				case{'JAGS'}
					modelPath = '/models/separateME.txt';
					obj.sampler = JAGSSampler([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
					obj.discountFuncType = 'me';
				case{'STAN'}
					error('NOT IMPLEMENTED YET')
			end

			% % give sampler a handle back to the model (ie this hierarchicalME model)
			% obj.sampler.modelHandle = obj;
			obj.plotFuncs.participantFigFunc = @figParticipantME;
			obj.plotFuncs.figParticipantWrapperFunc = @figParticipantLevelWrapperME;

			%% Create variables

			% Variable list, used for plotting
			obj.varList.participantLevel = {'m', 'c','alpha','epsilon'};

			% -------------------------------------------------------------------
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

			obj.variables.m_prior	= Variable('m_prior');
			obj.variables.c_prior	= Variable('c_prior');
			obj.variables.epsilon_prior	= Variable('epsilon_prior');
			obj.variables.alpha_prior	= Variable('alpha_prior');

			% observed response
			obj.variables.Rpostpred = Variable('R', 'bounds', [0 1]);

		end
		% ================================================================

	end

end
