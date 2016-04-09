classdef ModelSeparate < ModelBaseClass
	%ModelSeperate A model to estimate the magnitide effect.
	%	Models a number of participants, but they are all treated as independent.
	%	There is no group-level estimation.

	properties (Access = protected)
	end


	methods (Access = public)

		% CONSTRUCTOR =====================================================
		function obj = ModelSeparate(toolboxPath, sampler, data, saveFolder)
			% Because this class is a subclass of "ModelBaseClass" then we use
			% this next line to create an instance
			obj = obj@ModelBaseClass(toolboxPath, sampler, data, saveFolder);

			switch sampler
				case{'JAGS'}
					modelPath = '/models/separateME.txt';
					obj.sampler = JAGSSampler([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
				case{'STAN'}
					error('NOT IMPLEMENTED YET')
			end

			% % give sampler a handle back to the model (ie this hierarchicalME model)
			% obj.sampler.modelHandle = obj;

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












		% **************************************************************************
		% PLOTTING METHODS
		% **************************************************************************




		function plot(obj)
			close all

			% TODO &&&&& ENABLE THIS METHOD TO WORK WHEN NO GROUP-LEVEL VARIABLES &&&&
			% plot univariate summary statistics
			% 			obj.mcmc.figUnivariateSummary(obj.data.IDname, obj.varList.participantLevel)
			% 			latex_fig(16, 5, 5)
			% 			myExport(obj.saveFolder, obj.modelType, '-UnivariateSummary')
			% -------------------------------

			% TODO: FIX THIS !!!
			%			figPsychometricParamsSeparate(mcmc, data)
			% 			myExport(obj.saveFolder, obj.modelType, '-PsychometricParams')

			participant_level_prior_variables = cellfun(...
				@getPriorOfVariable,...
				obj.varList.participantLevel,...
				'UniformOutput',false );

			obj.plotFuncs.figParticipantWrapperFunc(...
				obj.mcmc,...
				obj.data,...
				obj.varList.participantLevel,...
				participant_level_prior_variables,...
				obj.saveFolder,...
				obj.modelType)
		end

	end

end
