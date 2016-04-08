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

			%% Create variables
			% -------------------------------------------------------------------
			% Participant-level -------------------------------------------------
			m = Variable('m','m', [], true);
			m.seed.func = @() normrnd(-0.243,10);
			m.seed.single = false;

			m_prior = Variable('m_prior','m prior', [], true);
			m_prior.seed.func = @() normrnd(-0.243,10);
			m_prior.seed.single = true;

			c = Variable('c','c', [], true);
			c.seed.func = @() normrnd(0,10);
			c.seed.single = false;

			c_prior = Variable('c_prior','c prior', [], true);
			c_prior.seed.func = @() normrnd(0,10);
			c_prior.seed.single = true;

			epsilon = Variable('epsilon','\epsilon', [0 0.5], true);
			epsilon.seed.func = @() rand/2;
			epsilon.seed.single = false;

			epsilon_prior = Variable('epsilon_prior','\epsilon prior', [0 0.5], true);
			epsilon_prior.seed.func = @() rand/2;
			epsilon_prior.seed.single = true;

			alpha = Variable('alpha','\alpha', 'positive', true);
			alpha.seed.func = @() abs(normrnd(0,10));
			alpha.seed.single = false;

			alpha_prior = Variable('alpha_prior','\alpha prior', 'positive', true);
			alpha_prior.seed.func = @() abs(normrnd(0,10));
			alpha_prior.seed.single = true;

			% posterior predictive ----------------------------------------------
			Rpostpred = Variable('Rpostpred','Rpostpred', [0 1], true);
			Rpostpred.plotMCMCchainFlag = false;

			% define which to analyse (univariate analysis)
			m.analysisFlag = 1;
			c.analysisFlag = 1;
			epsilon.analysisFlag = 1;
			alpha.analysisFlag = 1;

			% Create a Variable array -------------------------------------------
			obj.variables = gatherClassesIntoArray('Variable');

			function [array] = gatherClassesIntoArray(classType)
				% Gather all objects of a given class type and puts them into an array
				% NOTE: This function must be here (a local function) because of
				% variable scoping issues
				%
				% inspired by % http://uk.mathworks.com/matlabcentral/newsreader/view_thread/256782
				w=whos;
				wn={w.name}.';
				wc={w.class}.';
				ix=strcmp(wc,classType);
				r=wn(ix);
				% build array
				array=[];
				for n=1:numel(r)
					array = [array eval(r{n})];
				end
			end

			% Variable list, used for plotting
			obj.varList.participant_level_variables = {'m', 'c','alpha','epsilon'};

		end
		% ================================================================












		% **************************************************************************
		% PLOTTING METHODS
		% **************************************************************************




		function plot(obj)
			close all

			% TODO &&&&& ENABLE THIS METHOD TO WORK WHEN NO GROUP-LEVEL VARIABLES &&&&
			% plot univariate summary statistics
% 			obj.mcmc.figUnivariateSummary(obj.data.IDname, obj.varList.participant_level_variables)
% 			latex_fig(16, 5, 5)
% 			myExport(obj.saveFolder, obj.modelType, '-UnivariateSummary')
			% -------------------------------

			% TODO: FIX THIS !!!
%			figPsychometricParamsSeparate(mcmc, data)
% 			myExport(obj.saveFolder, obj.modelType, '-PsychometricParams')

			participant_level_prior_variables = cellfun(...
				@getPriorOfVariable,...
				obj.varList.participant_level_variables,...
				'UniformOutput',false );

			figParticipantLevelWrapperME(obj.mcmc,...
				obj.data,...
				obj.varList.participant_level_variables,...
				participant_level_prior_variables,...
				obj.saveFolder,...
				obj.modelType)
		end

	end

end
