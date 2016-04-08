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


			obj.plotPsychometricParams()
			myExport(obj.saveFolder, obj.modelType, '-PsychometricParams')

			%% GROUP LEVEL

			group_level_prior_variables = cellfun(...
				@getPriorOfVariable,...
				obj.varList.group_level_variables,...
				'UniformOutput',false );

			% Tri plot
			posteriorSamples = obj.mcmc.getSamplesAsMatrix(obj.varList.group_level_variables);
			priorSamples = obj.mcmc.getSamplesAsMatrix(group_level_prior_variables);

			obj.figTriPlot(obj.varList.group_level_variables,...
			 	priorSamples,...
			  posteriorSamples)
			myExport(obj.saveFolder, obj.modelType, ['-GROUP-triplot'])

			obj.figGroupLevel(obj.varList.group_level_variables)

			%% PARTICIPANT LEVEL

			participant_level_prior_variables = cellfun(...
				@getPriorOfVariable,...
				obj.varList.group_level_variables,...
				'UniformOutput',false );

			obj.figParticipantLevelWrapper(...
				obj.varList.participant_level_variables,...
				participant_level_prior_variables)
		end

	end



	methods (Access = protected)

		% function figUnivariateSummary(obj, participantIDlist, variables)
		% 	% loop over variables provided, plotting univariate summary
		% 	% statistics.
		%
		% 	% We are going to add on group level inferences to the end of the
		% 	% participant list. This is because the group-level inferences an be
		% 	% seen as inferences we can make about an as yet unobserved
		% 	% participant, in the light of the participant data available thus
		% 	% far.
		% 	participantIDlist{end+1}='GROUP';
		%
		% 	figure
		% 	for v = 1:numel(variables)
		% 		subplot(numel(variables),1,v)
		% 		hdi = [obj.sampler.getStats('hdi_low',variables{v})' obj.sampler.getStats('hdi_low',[variables{v} '_group']) ;...
		% 			obj.sampler.getStats('hdi_high',variables{v})' obj.sampler.getStats('hdi_high',[variables{v} '_group'])];
		% 		plotErrorBars({participantIDlist{:}},...
		% 			[obj.sampler.getStats('mean',variables{v})' obj.sampler.getStats('mean',[variables{v} '_group'])],...
		% 			hdi,...
		% 			variables{v});
		% 		a=axis; axis([0.5 a(2)+0.5 a(3) a(4)]);
		% 	end
		% end

		% *********************************************************************
		% *********************************************************************
		% *********************************************************************
		% *********************************************************************
		% THIS IS WHAT CHANGES WITH LOGK
		% *********************************************************************
		% *********************************************************************
		function figGroupLevel(obj, variables)
			% get group level parameters in a form ready to pass off to
			% figParticipant()

			% Get group-level data
			[pSamples] = obj.mcmc.getSamples(variables);
			% rename fields
			[pSamples.('logk')] = pSamples.('logk_group'); pSamples = rmfield(pSamples,'logk_group');
			[pSamples.('epsilon')] = pSamples.('epsilon_group'); pSamples = rmfield(pSamples,'epsilon_group');
			[pSamples.('alpha')] = pSamples.('alpha_group'); pSamples = rmfield(pSamples,'alpha_group');

			pData = []; % no data for group level

			figure(99), clf
			set(gcf,'Name','GROUP LEVEL')

			logkMEAN = obj.mcmc.getStats('mean', 'logk_group');
			epsilonMEAN = obj.mcmc.getStats('mean', 'epsilon_group');
			alphaMEAN = obj.mcmc.getStats('mean', 'alpha_group');

			figParticipantLOGK(pSamples, pData, logkMEAN, epsilonMEAN, alphaMEAN)

			% EXPORTING ---------------------
			latex_fig(16, 18, 4)
			myExport(obj.saveFolder, obj.modelType, '-GROUP')
			% -------------------------------
		end
		% *********************************************************************
		% *********************************************************************





		% OVERRIDDEN FROM BASE CLASS ******************************************
		% *********************************************************************

		function figParticipantLevelWrapper(obj, variables, participant_prior_variables)
			% For each participant, call some plotting functions on the variables provided.

			logkMEAN = obj.mcmc.getStats('mean', 'logk');
			epsilonMEAN = obj.mcmc.getStats('mean', 'epsilon');
			alphaMEAN = obj.mcmc.getStats('mean', 'alpha');

			for n = 1:obj.data.nParticipants
				fh = figure;
				fh.Name=['participant: ' obj.data.IDname{n}];

				% 1) figParticipant plot
				[pSamples] = obj.mcmc.getSamplesAtIndex(n, variables);
				[pData] = obj.data.getParticipantData(n);
				figParticipantLOGK(pSamples, pData, logkMEAN(n), epsilonMEAN(n), alphaMEAN(n))
				latex_fig(16, 18, 4)
				myExport(obj.saveFolder, obj.modelType, ['-' obj.data.IDname{n}])
				close(fh)

				% 2) Triplot
				posteriorSamples = obj.mcmc.getSamplesFromParticipantAsMatrix(n, variables);
				priorSamples = obj.mcmc.getSamplesAsMatrix(participant_prior_variables);

				obj.figTriPlot(variables, priorSamples, posteriorSamples)
% 				% 2) Triplot
% 				obj.figTriPlot(n, variables, participant_prior_variables)
% 				myExport(obj.saveFolder, obj.modelType, ['-' obj.data.IDname{n} '-triplot'])
			end
		end
		% *********************************************************************
		% *********************************************************************

	end

end
