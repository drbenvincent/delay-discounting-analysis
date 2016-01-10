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
					obj.sampler = JAGSSampler([toolboxPath '/jagsModels/hierarchicalME.txt'])
					[~,obj.modelType,~] = fileparts(obj.sampler.fileName);
				case{'STAN'}
					error('NOT IMPLEMENTED YET')
			end

			% give sampler a handle back to the model
			obj.sampler.modelHandle = obj;

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
			glM						= Variable('glM','glM', [], true);
			glMprior			= Variable('glMprior','glMprior', [], true);

			glC						= Variable('glC','glC', [], true);
			glCprior			= Variable('glCprior','glCprior', [], true);

			glEpsilon			= Variable('glEpsilon','glEpsilon', [0 0.5], true);
			glEpsilonprior= Variable('glEpsilonprior','glEpsilonprior', [0 0.5], true);

			glALPHA				= Variable('glALPHA','glALPHA', 'positive', true);
			glALPHAprior	= Variable('glALPHAprior','glALPHAprior', 'positive', true);
			%glMprior = Variable('glMprior','glMprior', [], true);
			%glCprior = Variable('glCprior','glCprior', [], true);
			%glEpsilonprior = Variable('glEpsilonprior','glEpsilonprior', [0 0.5], true);
			%glALPHAprior = Variable('glALPHAprior','glALPHAprior', 'positive', true);

			% -------------------------------------------------------------------
			% group level priors ------------------------------------------------
			groupMmu = Variable('groupMmu','groupMmu', [], true);
			groupMsigma = Variable('groupMsigma','groupMsigma', [], true);

			groupCmu = Variable('groupCmu','groupCmu', [], true);
			groupCsigma = Variable('groupCsigma','groupCsigma', [], true);

			groupW = Variable('groupW','groupW', [0 1], true);
			groupWprior = Variable('groupWprior','groupWprior', [0 1], true);

			groupK = Variable('groupK','groupK', 'positive', true);
			%groupK.seed.func = @() abs(normrnd(0,10));
			%groupK.seed.single = true;
			groupKprior = Variable('groupKprior','groupKprior', 'positive', true);
			%groupKprior.seed.func = @() abs(normrnd(0,10));
			%groupKprior.seed.single = true;

			groupALPHAmu = Variable('groupALPHAmu','groupALPHAmu', 'positive', true);
			groupALPHAsigma = Variable('groupALPHAsigma','groupALPHAsigma', 'positive', true);
			groupALPHAmuprior = Variable('groupALPHAmuprior','groupALPHAmuprior', 'positive', true);
			groupALPHAsigmaprior = Variable('groupALPHAsigmaprior','groupALPHAsigmaprior', 'positive', true);

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
			glM.analysisFlag = 2;
			glC.analysisFlag = 2;
			glEpsilon.analysisFlag = 2;
			glALPHA.analysisFlag = 2;
			
% 			glMprior.analysisFlag = 2; % don't want to analyse these
% 			glCprior.analysisFlag = 2;
% 			glEpsilonprior.analysisFlag = 2;
% 			glALPHAprior.analysisFlag = 2;

			% Create a Variable array -------------------------------------------
			obj.variables = [m, c, epsilon, alpha,... % mprior, cprior, epsilonprior, alphaprior,...
				groupMmu, groupMsigma,...
				groupCmu, groupCsigma,...
				groupW, groupWprior,...
				groupK, groupKprior,...
				glM, glC, glALPHA, glEpsilon,...
				glMprior, glCprior, glALPHAprior, glEpsilonprior,...
				groupALPHAmu, groupALPHAmuprior,...
				groupALPHAsigma, groupALPHAsigmaprior,...
				Rpostpred];

		end
		% =================================================================


		function plot(obj)
			close all
			variables = {'m', 'c','alpha','epsilon'};
			
			% plot univariate summary statistics --------------------------------
			obj.figUnivariateSummary(obj.analyses.univariate, obj.data.IDname, variables)
			latex_fig(16, 5, 5)
			myExport(obj.saveFolder, obj.modelType, '-UnivariateSummary')
			% -------------------------------------------------------------------

			obj.plotPsychometricParams()
			myExport(obj.saveFolder, obj.modelType, '-PsychometricParams')

			% obj.figGroupLevelTriPlot()
			% myExport(obj.saveFolder, obj.modelType, ['-GROUP-triplot'])

			% TODO : REMOVE figGroupLevel *********************
			obj.figGroupLevel(variables)
			% *************************************************
			obj.figParticipantLevelWrapper(variables)

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
			% samples = obj.sampler.getSamplesFromParticipant({'m','c'}, GROUP);
			% params(:,1) = samples.m(:);
			% params(:,2) = samples.c(:);
			% ==============================================
			[posteriorMode, lh] = calculateLogK_ConditionOnReward(reward, params, plotFlag);
			lh.LineWidth = 3;
			lh.Color= 'k';
			%lh(count).DisplayName = 'Group level';
			%row(count) = {sprintf('Group level')};
			% ==============================================
		end


		function plotPsychometricParams(obj)
			% Plot priors/posteriors for parameters related to the psychometric
			% function, ie how response 'errors' are characterised
			%
			% plotPsychometricParams(hModel.sampler.samples)


% 			% HOW TO GET "UNKOWN" PARTICIPANT SAMPLES *****************
% 			%obj.sampler.getSamplesFromParticipant({'alpha'}, 16)
% 			% TEMP
 			samples = obj.sampler.getAllSamples();
% 			
% 			GROUP = obj.data.nParticipants;
% 			%groupSamples = obj.sampler.getSamplesFromParticipant({'alpha','epsilon'}, GROUP);
% 			groupSamples = obj.sampler.getSamplesAtIndex(GROUP, {'alpha','epsilon'});
% 			% *********************************************************

			figure(7), clf
			P=size(samples.m,3); % number of participants
			%====================================
			subplot(3,2,1)
			plotPriorPostHist(samples.glALPHAprior(:), samples.glALPHA(:));
			title('Group \alpha')

			subplot(3,4,5)
			plotPriorPostHist(samples.groupALPHAmuprior(:), samples.groupALPHAmu(:));
			xlabel('\mu_\alpha')

			subplot(3,4,6)
			plotPriorPostHist(samples.groupALPHAsigmaprior(:), samples.groupALPHAsigma(:));
			xlabel('\sigma_\alpha')

			subplot(3,2,5),
			for p=1:P-1 % plot participant level alpha (alpha(:,:,p))
				%histogram(vec(samples.alpha(:,:,p)));
				[F,XI]=ksdensity(vec(samples.alpha(:,:,p)),...
					'support','positive',...
					'function','pdf');
				plot(XI, F)
				hold on
			end
			xlabel('\alpha_p')
			box off

			%====================================
			subplot(3,2,2)
			plotPriorPostHist(samples.glEpsilonprior(:), samples.glEpsilon(:));
			title('Group \epsilon')

			subplot(3,4,7),
			plotPriorPostHist(samples.groupWprior(:), samples.groupW(:));
			xlabel('\omega (mode)')

			subplot(3,4,8),
			plotPriorPostHist(samples.groupKprior(:), samples.groupK(:));
			xlabel('\kappa (concentration)')

			subplot(3,2,6),
			for p=1:P-1 % plot participant level alpha (alpha(:,:,p))
				%histogram(vec(samples.epsilon(:,:,p)));
					[F,XI]=ksdensity(vec(samples.epsilon(:,:,p)),...
					'support','positive',...
					'function','pdf');
				plot(XI, F)
				hold on
			end
			xlabel('\epsilon_p')
			box off
		end


	end


	methods(Static)

		
% 		% TODO: THIS OVERRIDES METHOD FROM MODEL BASE CLASS. WORK OUT A WAY TO
% 		% KILL THIS METHOD
% 		function figUnivariateSummary(uni, participantIDlist, variables)
% 			% loop over variables provided, plotting univariate summary
% 			% statistics.
% 			warning('Add group-level inferences to this plot (glM, glC, glALPHA,glEpsilon)')
% 			figure
% 			for v = 1:numel(variables)
% 				subplot(numel(variables),1,v)
% 				plotErrorBars({participantIDlist{:}},...
% 					[uni.(variables{v}).mode], [uni.(variables{v}).CI95],...
% 					variables{v});
% 				a=axis; axis([0.5 a(2)+0.5 a(3) a(4)]);
% 			end
% 		end
		
	end

	methods (Access = protected)

		function figGroupLevel(obj, variables)
			warning('figGroupLevel(): PLOT GROUP-LEVEL INFERENCES')
			figure(99)
			set(gcf,'Name','GROUP LEVEL')
			clf
% 
% 			%TODO: IMPLEMENT THIS GET METHOD ****************
% 			%pSamples = obj.sampler.getGroupLevelSamples()
% 			pSamples = [];
% 			% ***********************************************
% 			
% 			obj.figParticipant(obj, pSamples, []);
% 
% 			% EXPORTING ---------------------
% 			latex_fig(16, 18, 4)
% 			myExport(obj.saveFolder, obj.modelType, '-GROUP')
% 			% -------------------------------
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
			priorSamples = obj.sampler.samples.glMprior(:);
			posteriorSamples = obj.sampler.samples.glM(:);
			subplot(1,2,2)
			plotPosteriorHDI(priorSamples, posteriorSamples)

			%%
			myExport(obj.saveFolder, [], '-BayesFactorMLT1')
		end
	end



end
