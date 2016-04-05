classdef ModelHierarchical < ModelBaseClass
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)
		% =================================================================
		function obj = ModelHierarchical(toolboxPath, sampler, data, saveFolder)
			% Because this class is a subclass of "modelME" then we use
			% this next line to create an instance
			obj = obj@ModelBaseClass(toolboxPath, sampler, data, saveFolder);

			switch sampler
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
			% -------------------------------------------------------------------
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
			alpha.seed.func = @() abs(normrnd(0.01,0.001));
			alpha.seed.single = false;

			% -------------------------------------------------------------------
			% group level (ie what we expect from an as yet unobserved person ---
			% TODO: This could be implemented just by having another participant
			% with no observed data? This would remove the need for all these gl*
			% variables here and in the JAGS model and make things much simpler.
			m_group				= Variable('m_group','m group', [], true);
			m_group_prior		= Variable('m_group_prior','m group prior', [], true);

			c_group				= Variable('c_group','c group', [], true);
			c_group_prior		= Variable('c_group_prior','c group prior', [], true);

			epsilon_group		= Variable('epsilon_group','\epsilon group', [0 0.5], true);
			epsilon_group_prior = Variable('epsilon_group_prior','\epsilon group prior', [0 0.5], true);

			alpha_group			= Variable('alpha_group','\alpha group', 'positive', true);
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

% 			m_group_prior.analysisFlag = 2; % don't want to analyse these
% 			c_group_prior.analysisFlag = 2;
% 			epsilon_group_prior.analysisFlag = 2;
% 			alpha_group_prior.analysisFlag = 2;

			% Create a Variable array -------------------------------------------
			obj.variables = [m, c, epsilon, alpha,... % mprior, cprior, epsilonprior, alphaprior,...
				groupMmu, groupMsigma,...
				groupCmu, groupCsigma,...
				groupW, groupWprior,...
				groupK, groupKprior,...
				m_group, c_group, alpha_group, epsilon_group,...
				m_group_prior, c_group_prior, alpha_group_prior, epsilon_group_prior,...
				groupALPHAmu, groupALPHAmuprior,...
				groupALPHAsigma, groupALPHAsigmaprior,...
				Rpostpred];

			% Variable list, used for plotting
			obj.varList.participant_level_variables = {'m', 'c','alpha','epsilon'};

			obj.varList.participant_level_prior_variables = {'m_group_prior',...
				'c_group_prior',...
				'alpha_group_prior',...
				'epsilon_group_prior'};

			obj.varList.group_level_variables = {'m_group', 'c_group','alpha_group','epsilon_group'};

			obj.varList.group_level_prior_variables = {'m_group_prior',...
				'c_group_prior',...
				'alpha_group_prior',...
				'epsilon_group_prior'};

		end
		% =================================================================


		function plot(obj)
			close all

			obj.plotPsychometricParams()
			myExport(obj.saveFolder, obj.modelType, '-PsychometricParams')

			%% GROUP LEVEL
			% Tri plot
			obj.figGroupTriPlot(obj.varList.group_level_variables, obj.varList.group_level_prior_variables)
			myExport(obj.saveFolder, obj.modelType, ['-GROUP-triplot'])

			obj.figGroupLevel(obj.varList.group_level_variables)

			%% PARTICIPANT LEVEL

			% plot univariate summary statistics --------------------------------
			obj.figUnivariateSummary(obj.data.IDname, obj.varList.participant_level_variables)
			latex_fig(16, 5, 5)
			myExport(obj.saveFolder, obj.modelType, '-UnivariateSummary')
			% -------------------------------------------------------------------

			obj.figParticipantLevelWrapper(obj.varList.participant_level_variables,...
				obj.varList.participant_level_prior_variables)

			%% mc contour plot of all participants
			probMass = 0.5; % <---- 50% prob mass chosen to avoid too much clutter on graph
			obj.plotMCclusters([1 0 0], probMass)
		end


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
			params = obj.sampler.getSamplesFromParticipantAsMatrix(GROUP, {'m','c'});
			[posteriorMean, lh] = calculateLogK_ConditionOnReward(reward, params, plotFlag);
			lh.LineWidth = 3;
			lh.Color= 'k';
		end


		function plotMCclusters(obj, col, probMass)
			display('** WARNING ** Making this plot takes time...')
			% plot posteriors over (m,c) for all participants, as contour
			% plots
			figure(12)
			% participants
			for p = 1:obj.data.nParticipants
				[samples] = obj.sampler.getSamplesAtIndex(p, {'m','c'});
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
				obj.sampler.getSamplesAsMatrix({'m_group'}),...
				obj.sampler.getSamplesAsMatrix({'c_group'}),...
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


% 		function plotPsychometricParams(obj)
% 			% Plot priors/posteriors for parameters related to the psychometric
% 			% function, ie how response 'errors' are characterised
% 			%
% 			% plotPsychometricParams(hModel.sampler.samples)
%
%  			%samples = obj.sampler.getAllSamples();
%
% 			figure(7), clf
% 			P=obj.data.nParticipants; % number of participants
% 			%====================================
% 			subplot(3,2,1)
% 			plotPriorPostHist(...
% 				obj.sampler.getSamplesAsMatrix({'alpha_group_prior'}),...
% 				obj.sampler.getSamplesAsMatrix({'alpha_group'}));
% 			title('Group \alpha')
%
% 			subplot(3,4,5)
% 			plotPriorPostHist(samples.groupALPHAmuprior(:), samples.groupALPHAmu(:));
% 			xlabel('\mu_\alpha')
%
% 			subplot(3,4,6)
% 			plotPriorPostHist(samples.groupALPHAsigmaprior(:), samples.groupALPHAsigma(:));
% 			xlabel('\sigma_\alpha')
%
% 			subplot(3,2,5),
% 			for p=1:P-1 % plot participant level alpha (alpha(:,:,p))
% 				%histogram(vec(samples.alpha(:,:,p)));
% 				[F,XI]=ksdensity(vec(samples.alpha(:,:,p)),...
% 					'support','positive',...
% 					'function','pdf');
% 				plot(XI, F)
% 				hold on
% 			end
% 			xlabel('\alpha_p')
% 			box off
%
% 			%====================================
% 			subplot(3,2,2)
% 			plotPriorPostHist(samples.epsilon_group_prior(:), samples.epsilon_group(:));
% 			title('Group \epsilon')
%
% 			subplot(3,4,7),
% 			plotPriorPostHist(samples.groupWprior(:), samples.groupW(:));
% 			xlabel('\omega (mode)')
%
% 			subplot(3,4,8),
% 			plotPriorPostHist(samples.groupKprior(:), samples.groupK(:));
% 			xlabel('\kappa (concentration)')
%
% 			subplot(3,2,6),
% 			for p=1:P-1 % plot participant level alpha (alpha(:,:,p))
% 				%histogram(vec(samples.epsilon(:,:,p)));
% 					[F,XI]=ksdensity(vec(samples.epsilon(:,:,p)),...
% 					'support','positive',...
% 					'function','pdf');
% 				plot(XI, F)
% 				hold on
% 			end
% 			xlabel('\epsilon_p')
% 			box off
% 		end

	end







	methods (Access = protected)

		function figUnivariateSummary(obj, participantIDlist, variables)
			% loop over variables provided, plotting univariate summary
			% statistics.

			% We are going to add on group level inferences to the end of the
			% participant list. This is because the group-level inferences an be
			% seen as inferences we can make about an as yet unobserved
			% participant, in the light of the participant data available thus
			% far.
			participantIDlist{end+1}='GROUP';

			figure
			for v = 1:numel(variables)
				subplot(numel(variables),1,v)
				hdi = [obj.sampler.getStats('hdi_low',variables{v})' obj.sampler.getStats('hdi_low',[variables{v} '_group']) ;...
					obj.sampler.getStats('hdi_high',variables{v})' obj.sampler.getStats('hdi_high',[variables{v} '_group'])];
				plotErrorBars({participantIDlist{:}},...
					[obj.sampler.getStats('mean',variables{v})' obj.sampler.getStats('mean',[variables{v} '_group'])],...
					hdi,...
					variables{v});
				a=axis; axis([0.5 a(2)+0.5 a(3) a(4)]);
			end
		end


		function figGroupLevel(obj, variables)
			% get group level parameters in a form ready to pass off to
			% figParticipant()

			% Get group-level data
			[pSamples] = obj.sampler.getSamples(variables);
			% rename fields
			[pSamples.('m')] = pSamples.('m_group'); pSamples = rmfield(pSamples,'m_group');
			[pSamples.('c')] = pSamples.('c_group'); pSamples = rmfield(pSamples,'c_group');
			[pSamples.('epsilon')] = pSamples.('epsilon_group'); pSamples = rmfield(pSamples,'epsilon_group');
			[pSamples.('alpha')] = pSamples.('alpha_group'); pSamples = rmfield(pSamples,'alpha_group');

			pData = []; % no data for group level

			figure(99), clf
			set(gcf,'Name','GROUP LEVEL')

			mMEAN = obj.sampler.getStats('mean', 'm_group');
			cMEAN = obj.sampler.getStats('mean', 'c_group');
			epsilonMEAN = obj.sampler.getStats('mean', 'epsilon_group');
			alphaMEAN = obj.sampler.getStats('mean', 'alpha_group');

			obj.figParticipant(pSamples, pData, mMEAN, cMEAN, epsilonMEAN, alphaMEAN)

			% EXPORTING ---------------------
			latex_fig(16, 18, 4)
			myExport(obj.saveFolder, obj.modelType, '-GROUP')
			% -------------------------------
		end

		function figGroupTriPlot(obj, variables, group_level_prior_variables)
			warning('Heavy but not exact duplication of figParticiantTriPlot() in ModelBaseClass')
			% samples from posterior
			[posteriorSamples] = obj.sampler.getSamplesAsMatrix(variables);

			[priorSamples] = obj.sampler.getSamplesAsMatrix(group_level_prior_variables);

			figure(87)
			variable_label_names={'m','c','alpha','epsilon'};
			triPlotSamples(posteriorSamples, priorSamples, variable_label_names, [])
		end

	end








	% HYPOTHESIS TEST FUNCTIONS
	methods (Access = public)
		function HTgroupSlopeLessThanZero(obj)
			% Test the hypothesis that the group level slope (G^m) is less
			% than one

			% METHOD 1
			HT_BayesFactor(obj)

			% METHOD 2
			priorSamples = obj.sampler.getSamplesAsMatrix({'m_group_prior'});
			posteriorSamples = obj.sampler.getSamplesAsMatrix({'m_group'});
			subplot(1,2,2)
			plotPosteriorHDI(priorSamples, posteriorSamples)

			%%
			myExport(obj.saveFolder, [], '-BayesFactorMLT1')
		end
	end



end
