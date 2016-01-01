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



			glMprior = Variable('glMprior','glMprior', [], true);
			glCprior = Variable('glCprior','glCprior', [], true);
			glEpsilonprior = Variable('glEpsilonprior','glEpsilonprior', [0 0.5], true);
			glALPHAprior = Variable('glALPHAprior','glALPHAprior', 'positive', true);
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

% 			% 2 = group level
% 			glM.analysisFlag = 2;
% 			glC.analysisFlag = 2;
% 			glEpsilon.analysisFlag = 2;
% 			glALPHA.analysisFlag = 2;

			% Create a Variable array -------------------------------------------
			obj.variables = [m, c, epsilon, alpha,... % mprior, cprior, epsilonprior, alphaprior,...
				groupMmu, groupMsigma,...
				groupCmu, groupCsigma,...
				groupW, groupWprior,...
				groupK, groupKprior,...
				glMprior, glCprior, glALPHAprior, glEpsilonprior,...
				groupALPHAmu, groupALPHAmuprior,...
				groupALPHAsigma, groupALPHAsigmaprior,...
				Rpostpred];

		end
		% =================================================================


		function plot(obj)
			close all
			variables = {'m', 'c','alpha','epsilon'};
			% plot univariate summary statistics for the parameters we have
			% made inferences about
			obj.figUnivariateSummary(obj.analyses.univariate, obj.data.IDname, variables)
			% EXPORTING ---------------------
			latex_fig(16, 5, 5)
			myExport(obj.saveFolder, obj.modelType, '-UnivariateSummary')
			% -------------------------------

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


			% HOW TO GET "UNKOWN" PARTICIPANT SAMPLES *****************
			%obj.sampler.getSamplesFromParticipant({'alpha'}, 16)
			% TEMP
			samples = obj.sampler.samples;
			% *********************************************************
			GROUP = obj.data.nParticipants;
			%groupSamples = obj.sampler.getSamplesFromParticipant({'alpha','epsilon'}, GROUP);
			groupSamples = obj.sampler.getSamplesAtIndex(GROUP, {'alpha','epsilon'});

			figure(7), clf
			P=size(samples.m,3); % number of participants
			%====================================
			subplot(3,2,1)
			plotPriorPostHist([], groupSamples.alpha);
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
			plotPriorPostHist([], groupSamples.epsilon);
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

	end

	methods (Access = protected)

		% TODO: TO BE REMOVED ***********************************
		function figGroupLevel(obj, variables)
			warning('figGroupLevel() to be removed')
			figure(99)
			set(gcf,'Name','GROUP LEVEL')
			clf

			GROUP = obj.data.nParticipants;
			%pSamples = obj.sampler.getSamplesFromParticipant(variables, GROUP);
			pSamples = obj.sampler.getSamplesAtIndex(GROUP, variables);

			figParticipant(obj, pSamples, [])

			% EXPORTING ---------------------
			latex_fig(16, 18, 4)
			myExport(obj.saveFolder, obj.modelType, '-GROUP')
			% -------------------------------
		end
		% ********************************************************

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
