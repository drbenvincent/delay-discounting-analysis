classdef ModelHierarchicalLogK < ModelBaseClass
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)
		% =================================================================
		function obj = ModelHierarchicalLogK(toolboxPath, samplerType, data, saveFolder)
			obj = obj@ModelBaseClass(toolboxPath, samplerType, data, saveFolder);

			switch samplerType
				case{'JAGS'}
					modelPath = '/models/hierarchicalNOMAG.txt';
					obj.sampler = JAGSSampler([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
				case{'STAN'}
					modelPath = '/models/hierarchicalNOMAG.stan';
					obj.sampler = STANSampler([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
			end

			%% Create variables
			% The intent of this code below is to set up the key variables of the
			% model. This is so that we can:
			%  1. Generate good initial parameters for the MCMC chains
			%  2. Have meaningful variable names (and latex strings), which helps
			%  for plotting.
			%  3. Have labels for Participant-level and group-level parameters,
			%  also helps plotting.
			% Participant-level -------------------------------------------------
			logk = Variable('logk','\log(k)', [], true);
			logk.seed.func = @() normrnd(-0.243,10);
			logk.seed.single = false;

			epsilon = Variable('epsilon','\epsilon', [0 0.5], true);
			epsilon.seed.func = @() 0.1 + rand/10;
			epsilon.seed.single = false;

			alpha = Variable('alpha','\alpha', 'positive', true);
			alpha.seed.func = @() abs(normrnd(0.01,1));
			alpha.seed.single = false;

			% -------------------------------------------------------------------
			% group level (ie what we expect from an as yet unobserved person ---
			logk_group				= Variable('logk_group','logk group', [], true);
			logk_group.seed.func = @() normrnd(-0.243,10);
			logk_group.seed.single = true;

			logk_group_prior	= Variable('logk_group_prior','logk group prior', [], true);

			epsilon_group		= Variable('epsilon_group','\epsilon group', [0 0.5], true);
			epsilon_group.seed.func = @() 0.1 + rand/10;
			epsilon_group.seed.single = true;

			epsilon_group_prior = Variable('epsilon_group_prior','\epsilon group prior', [0 0.5], true);

			alpha_group			= Variable('alpha_group','\alpha group', 'positive', true);
			alpha_group.seed.func = @() abs(normrnd(0.01,1));
			alpha_group.seed.single = true;
			alpha_group_prior	= Variable('alpha_group_prior','\alpha group prior', 'positive', true);

			% -------------------------------------------------------------------
			% group level priors ------------------------------------------------
			groupLogKmu	= Variable('groupLogKmu','groupLogKmu', [], true);
			groupLogKmuprior = Variable('groupLogKmuprior','groupLogKmuprior', [], true);

			groupLogKsigma	= Variable('groupLogKsigma','groupLogKsigma', [], true);
			groupLogKsigmaprior = Variable('groupLogKsigmaprior','groupLogKsigmaprior', [], true);

			groupW		= Variable('groupW','\omega', [0 1], true);
			groupWprior = Variable('groupWprior','\omega prior', [0 1], true);

			groupK		= Variable('groupK','\kappa', 'positive', true);
			groupKprior = Variable('groupKprior','\kappa prior', 'positive', true);

			groupALPHAmu = Variable('groupALPHAmu','\mu^\alpha', 'positive', true);
			groupALPHAsigma = Variable('groupALPHAsigma','\sigma^\alpha', 'positive', true);
			groupALPHAmuprior = Variable('groupALPHAmuprior','\mu^\alpha prior', 'positive', true);
			groupALPHAsigmaprior = Variable('groupALPHAsigmaprior','\sigma^\alpha prior', 'positive', true);

			% posterior predictive ----------------------------------------------
			Rpostpred = Variable('Rpostpred','Rpostpred', [0 1], true);
			Rpostpred.plotMCMCchainFlag = false;

			% define which to analyse (univariate analysis) ---------------------
			% 1 = participant level
			logk.analysisFlag = 1;
			epsilon.analysisFlag = 1;
			alpha.analysisFlag = 1;

			% 2 = group level
			logk_group.analysisFlag = 2;
			epsilon_group.analysisFlag = 2;
			alpha_group.analysisFlag = 2;


			% Create a Variable array -------------------------------------------
			% Used to tell JAGS what variables to monitor
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
			obj.varList.participant_level_variables = ...
				{'logk','alpha','epsilon'};
			% Add group variables
			obj.varList.group_level_variables =...
				cellfun( @(var) [var '_group'],...
				obj.varList.participant_level_variables,...
				'UniformOutput',false );

		end
		% =================================================================

		function conditionalDiscountRates(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end

		function conditionalDiscountRates_GroupLevel(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end

















		% **************************************************************************
		% PLOTTING METHODS
		% **************************************************************************



		function plot(obj)
			close all

			% plot univariate summary statistics --------------------------------
			obj.mcmc.figUnivariateSummary(obj.data.IDname, obj.varList.participant_level_variables)
			latex_fig(16, 5, 5)
			myExport(obj.saveFolder, obj.modelType, '-UnivariateSummary')
			% -------------------------------------------------------------------


			figPsychometricParamsHierarchical(obj.mcmc, obj.data)
			myExport(obj.saveFolder, obj.modelType, '-PsychometricParams')

			%% GROUP LEVEL

			group_level_prior_variables = cellfun(...
				@getPriorOfVariable,...
				obj.varList.group_level_variables,...
				'UniformOutput',false );

			% Tri plot
			posteriorSamples = obj.mcmc.getSamplesAsMatrix(obj.varList.group_level_variables);
			priorSamples = obj.mcmc.getSamplesAsMatrix(group_level_prior_variables);

			figure(87)
			triPlotSamples(priorSamples, posteriorSamples, obj.varList.group_level_variables, [])

% 			figTriPlot(obj.varList.group_level_variables,...
% 			 	priorSamples,...
% 			  posteriorSamples)
			myExport(obj.saveFolder, obj.modelType, ['-GROUP-triplot'])

			figGroupLevelWrapperLOGK(obj.mcmc, obj.data, obj.varList.group_level_variables, obj.saveFolder, obj.modelType)

			%% PARTICIPANT LEVEL

			participant_level_prior_variables = cellfun(...
				@getPriorOfVariable,...
				obj.varList.group_level_variables,...
				'UniformOutput',false );

			figParticipantLevelWrapperLOGK(...
				obj.mcmc,...
				obj.data,...
				obj.varList.participant_level_variables,...
				participant_level_prior_variables,...
				obj.saveFolder,...
				obj.modelType)
		end

	end

end
