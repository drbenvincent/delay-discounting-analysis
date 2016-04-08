classdef ModelHierarchical < ModelBaseClass
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)
		% =================================================================
		function obj = ModelHierarchical(toolboxPath, samplerType, data, saveFolder)
			obj = obj@ModelBaseClass(toolboxPath, samplerType, data, saveFolder);

			switch samplerType
				case{'JAGS'}
					modelPath = '/models/hierarchicalME.txt';
					obj.sampler = JAGSSampler([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
				case{'STAN'}
					modelPath = '/models/hierarchicalME.stan';
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
			m = Variable('m','m', [], true);
			m.seed.func = @() normrnd(-0.243,2);
			m.seed.single = false;

			c = Variable('c','c', [], true);
			c.seed.func = @() normrnd(0,4);
			c.seed.single = false;

			epsilon = Variable('epsilon','\epsilon', [0 0.5], true);
			epsilon.seed.func = @() 0.1 + rand/10;
			epsilon.seed.single = false;

			alpha = Variable('alpha','\alpha', 'positive', true);
			alpha.seed.func = @() abs(normrnd(0.01,10));
			alpha.seed.single = false;

			% -------------------------------------------------------------------
			% group level (ie what we expect from an as yet unobserved person ---
			m_group				= Variable('m_group','m group', [], true);
			m_group.seed.func = @() normrnd(-0.243,2);
			m_group.seed.single = true;

			m_group_prior		= Variable('m_group_prior','m group prior', [], true);

			c_group				= Variable('c_group','c group', [], true);
			c_group.seed.func = @() normrnd(0,4);
			c_group.seed.single = true;

			c_group_prior		= Variable('c_group_prior','c group prior', [], true);

			epsilon_group		= Variable('epsilon_group','\epsilon group', [0 0.5], true);
			epsilon_group.seed.func = @() 0.1 + rand/10;
			epsilon_group.seed.single = true;

			epsilon_group_prior = Variable('epsilon_group_prior','\epsilon group prior', [0 0.5], true);

			alpha_group			= Variable('alpha_group','\alpha group', 'positive', true);
			alpha_group.seed.func = @() abs(normrnd(0.01,10));
			alpha_group.seed.single = true;
			alpha_group_prior	= Variable('alpha_group_prior','\alpha group prior', 'positive', true);

			% -------------------------------------------------------------------
			% group level priors ------------------------------------------------
			groupMmu	= Variable('groupMmu','\mu^m', [], true);
			groupMsigma = Variable('groupMsigma','\sigma^m', [], true);

			groupCmu	= Variable('groupCmu','\mu^c', [], true);
			groupCsigma = Variable('groupCsigma','\sigma^c', [], true);

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
			m.analysisFlag = 1;
			c.analysisFlag = 1;
			epsilon.analysisFlag = 1;
			alpha.analysisFlag = 1;

			% 2 = group level
			m_group.analysisFlag = 2;
			c_group.analysisFlag = 2;
			epsilon_group.analysisFlag = 2;
			alpha_group.analysisFlag = 2;

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
			% Add group variables
			obj.varList.group_level_variables =...
				cellfun( @(var) [var '_group'],...
				obj.varList.participant_level_variables,...
				'UniformOutput',false );

		end
		% =================================================================



		%% ******** SORT OUT WHERE THESE AND OTHER FUNCTIONS SHOULD BE *************
		function conditionalDiscountRates(obj, reward, plotFlag)
			% For group level and all participants, extract and plot P( log(k) | reward)
			warning('THIS METHOD IS A TOTAL MESS - PLAN THIS AGAIN FROM SCRATCH')
			obj.conditionalDiscountRates_ParticipantLevel(reward, plotFlag)
			obj.conditionalDiscountRates_GroupLevel(reward, plotFlag)
			if plotFlag % FORMATTING OF FIGURE
				removeYaxis
				title(sprintf('$P(\\log(k)|$reward=$\\pounds$%d$)$', reward),'Interpreter','latex')
				xlabel('$\log(k)$','Interpreter','latex')
				axis square
				%legend(lh.DisplayName)
			end
		end

		function conditionalDiscountRates_GroupLevel(obj, reward, plotFlag)
			GROUP = obj.data.nParticipants; % last participant is our unobserved
			params = obj.mcmc.getSamplesFromParticipantAsMatrix(GROUP, {'m','c'});
			[posteriorMean, lh] = calculateLogK_ConditionOnReward(reward, params, plotFlag);
			lh.LineWidth = 3;
			lh.Color= 'k';
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

			obj.figParticipantLevelWrapper(obj.varList.participant_level_variables,...
				participant_level_prior_variables)

			%% mc contour plot of all participants
			probMass = 0.5; % <---- 50% prob mass chosen to avoid too much clutter on graph
			obj.plotMCclusters([1 0 0], probMass)
		end


		function plotMCclusters(obj, col, probMass)
			display('** WARNING ** Making this plot takes time...')
			% plot posteriors over (m,c) for all participants, as contour
			% plots
			figure(12)
			% participants
			for p = 1:obj.data.nParticipants
				[samples] = obj.mcmc.getSamplesAtIndex(p, {'m','c'});
				[bi] = plot2DmcContour(...
					samples.m,...
					samples.c,...
					probMass,...
					definePlotOptions4Participant(col));
				% plot numbers
				text(bi.modex,bi.modey,...
					sprintf('%d',p),...
					'HorizontalAlignment','center',...
					'VerticalAlignment','middle',...
					'FontSize',9,...
					'Color',col)
				drawnow
			end
			% group
			plot2DmcContour(...
				obj.mcmc.getSamplesAsMatrix({'m_group'}),...
				obj.mcmc.getSamplesAsMatrix({'c_group'}),...
				probMass,...
				definePlotOptions4Group(col));

			axis tight
			set(gca,'XAxisLocation','origin')
			set(gca,'YAxisLocation','origin')
			drawnow

			function plotOpts = definePlotOptions4Participant(col)
				plotOpts.FaceAlpha = '0.1';
				plotOpts.FaceColor = col;
				plotOpts.LineStyle = 'none';
			end

			function plotOpts = definePlotOptions4Group(col)
				plotOpts.FaceColor = 'none';
				plotOpts.EdgeColor = col;
				plotOpts.LineWidth = 2;
			end
		end


		function figGroupLevel(obj, variables)
			% get group level parameters in a form ready to pass off to
			% figParticipant()

			% Get group-level data
			[pSamples] = obj.mcmc.getSamples(variables);
			% rename fields
			[pSamples.('m')] = pSamples.('m_group'); pSamples = rmfield(pSamples,'m_group');
			[pSamples.('c')] = pSamples.('c_group'); pSamples = rmfield(pSamples,'c_group');
			[pSamples.('epsilon')] = pSamples.('epsilon_group'); pSamples = rmfield(pSamples,'epsilon_group');
			[pSamples.('alpha')] = pSamples.('alpha_group'); pSamples = rmfield(pSamples,'alpha_group');

			pData = []; % no data for group level

			figure(99), clf
			set(gcf,'Name','GROUP LEVEL')

			mMEAN = obj.mcmc.getStats('mean', 'm_group');
			cMEAN = obj.mcmc.getStats('mean', 'c_group');
			epsilonMEAN = obj.mcmc.getStats('mean', 'epsilon_group');
			alphaMEAN = obj.mcmc.getStats('mean', 'alpha_group');

			opts.maxlogB	= max(abs(obj.data.observedData.B(:)));
			opts.maxD		= max(obj.data.observedData.DB(:));
		
			figParticipantME(pSamples, pData, mMEAN, cMEAN, epsilonMEAN, alphaMEAN, opts)

			% EXPORTING ---------------------
			latex_fig(16, 18, 4)
			myExport(obj.saveFolder, obj.modelType, '-GROUP')
			% -------------------------------
		end

	end

end
