classdef ModelHierarchical < ModelBaseClass
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)
		% =================================================================
		function obj = ModelHierarchical(toolboxPath, sampler, data)
			% Because this class is a subclass of "modelME" then we use
			% this next line to create an instance
			obj = obj@ModelBaseClass(toolboxPath, sampler, data);

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
			m = Variable('m','m', [], true)
			m.seed.func = @() normrnd(-0.243,2);
			m.seed.single = false;

			c = Variable('c','c', [], true)
			c.seed.func = @() normrnd(0,4);
			c.seed.single = false;

			epsilon = Variable('epsilon','\epsilon', [0 0.5], true)
			epsilon.seed.func = @() 0.1 + rand/10;
			epsilon.seed.single = false;

			alpha = Variable('alpha','\alpha', 'positive', true)
			alpha.seed.func = @() abs(normrnd(0.01,0.001));
			alpha.seed.single = false;

			% -------------------------------------------------------------------
			% group level (ie what we expect from an as yet unobserved person ---
			% TODO: This could be implemented just by having another participant
			% with no observed data? This would remove the need for all these gl*
			% variables here and in the JAGS model and make things much simpler.
			glM = Variable('glM','glM', [], true)
			glMprior = Variable('glMprior','glMprior', [], true)

			glC = Variable('glC','glC', [], true)
			glCprior = Variable('glCprior','glCprior', [], true)

			glEpsilon = Variable('glEpsilon','glEpsilon', [0 0.5], true)
			glEpsilonprior = Variable('glEpsilonprior','glEpsilonprior', [0 0.5], true)

			glALPHA = Variable('glALPHA','glALPHA', 'positive', true)
			glALPHAprior = Variable('glALPHAprior','glALPHAprior', 'positive', true)

			% -------------------------------------------------------------------
			% group level priors ------------------------------------------------
			groupMmu = Variable('groupMmu','groupMmu', [], true)
			groupMsigma = Variable('groupMsigma','groupMsigma', [], true)

			groupCmu = Variable('groupCmu','groupCmu', [], true)
			groupCsigma = Variable('groupCsigma','groupCsigma', [], true)

			groupW = Variable('groupW','groupW', [0 0.5], true)
			groupWprior = Variable('groupWprior','groupWprior', [0 0.5], true)
			groupK = Variable('groupK','groupK', [0 0.5], true)
			groupKprior = Variable('groupKprior','groupKprior', [0 0.5], true)

			groupALPHAmu = Variable('groupALPHAmu','groupALPHAmu', 'positive', true)
			groupALPHAsigma = Variable('groupALPHAsigma','groupALPHAsigma', 'positive', true)
			groupALPHAmuprior = Variable('groupALPHAmuprior','groupALPHAmuprior', 'positive', true)
			groupALPHAsigmaprior = Variable('groupALPHAsigmaprior','groupALPHAsigmaprior', 'positive', true)

			% posterior predictive ----------------------------------------------
			Rpostpred = Variable('Rpostpred','Rpostpred', [0 1], true)
			Rpostpred.plotMCMCchainFlag = false;

			% define which to analyse (univariate analysis) ---------------------
			m.analysisFlag = true;
			c.analysisFlag = true;
			epsilon.analysisFlag = true;
			alpha.analysisFlag = true;

			glM.analysisFlag = true;
			glC.analysisFlag = true;
			glEpsilon.analysisFlag = true;
			glALPHA.analysisFlag = true;

			% Create a Variable array -------------------------------------------
			obj.variables = [m, c, epsilon, alpha,... % mprior, cprior, epsilonprior, alphaprior,...
				glM, glMprior,...
				glC, glCprior,...
				groupMmu, groupMsigma,...
				groupCmu, groupCsigma,...
				glEpsilon, glEpsilonprior, groupW, groupWprior, groupK, groupKprior,...
				glALPHA, glALPHAprior, groupALPHAmu, groupALPHAmuprior, groupALPHAsigma, groupALPHAsigmaprior,...
				Rpostpred];

		end
		% =================================================================


		function plot(obj)
			close all
			% plot univariate summary statistics for the parameters we have
			% made inferences about
			obj.figUnivariateSummary(obj.analyses.univariate, obj.data.IDname)
			% EXPORTING ---------------------
			latex_fig(16, 5, 5)
			myExport(obj.data.saveName, obj.modelType, '-UnivariateSummary')
			% -------------------------------

			obj.plotPsychometricParams(obj.sampler.samples)
			myExport(obj.data.saveName, obj.modelType, '-PsychometricParams')

			obj.figGroupLevelPriorPost()
			% EXPORTING ---------------------
			latex_fig(16, 5, 5)
			myExport(obj.data.saveName, obj.modelType, '-PriorPost_GroupLevel')
			% -------------------------------

			obj.figGroupLevelTriPlot()
			myExport(obj.data.saveName, obj.modelType, ['-GROUP-triplot'])

			obj.figGroupLevel()
			obj.figParticipantLevelWrapper()

		end
		

		function figGroupLevelPriorPost(obj)
			figure

			subplot(2,2,1)
			plotPriorPosterior(obj.sampler.samples.glEpsilonprior(:),...
				obj.sampler.samples.glEpsilon(:),...
				'G^\epsilon')

			subplot(2,2,2)
			plotPriorPosterior(obj.sampler.samples.glALPHAprior(:),...
				obj.sampler.samples.glALPHA(:),...
				'G^\alpha')

			subplot(2,2,3)
			plotPriorPosterior(obj.sampler.samples.glMprior(:),...
				obj.sampler.samples.glM(:),...
				'G^m')

			subplot(2,2,4)
			plotPriorPosterior(obj.sampler.samples.glCprior(:),...
				obj.sampler.samples.glC(:),...
				'G^c')
		end


		% TODO: NOW THIS OVERIDES THE BASE CLASS METHOD, BUT IDEALLY WE WANT TO MAKE THAT BASECLASS METHOD MODE GENERAL SO WE CAN REMOVE THIS FUNCTION
		function exportParameterEstimates(obj)
			participant_level = array2table(...
				[obj.analyses.univariate.m.mode'...
				obj.analyses.univariate.m.CI95'...
				obj.analyses.univariate.c.mode'...
				obj.analyses.univariate.c.CI95'...
				obj.analyses.univariate.alpha.mode'...
				obj.analyses.univariate.alpha.CI95'...
				obj.analyses.univariate.epsilon.mode'...
				obj.analyses.univariate.epsilon.CI95'],...
				'VariableNames',{'m_mode' 'm_CI5' 'm_CI95'...
				'c_mode' 'c_CI5' 'c_CI95'...
				'alpha_mode' 'alpha_CI5' 'alpha_CI95'...
				'epsilon_mode' 'epsilon_CI5' 'epsilon_CI95'},...
				'RowNames',obj.data.participantFilenames);

			group_level = array2table(...
				[obj.analyses.univariate.glM.mode'...
				obj.analyses.univariate.glM.CI95'...
				obj.analyses.univariate.glC.mode'...
				obj.analyses.univariate.glC.CI95'...
				obj.analyses.univariate.glALPHA.mode'...
				obj.analyses.univariate.glALPHA.CI95'...
				obj.analyses.univariate.glEpsilon.mode'...
				obj.analyses.univariate.glEpsilon.CI95'],...
				'VariableNames',{'m_mode' 'm_CI5' 'm_CI95'...
				'c_mode' 'c_CI5' 'c_CI95'...
				'alpha_mode' 'alpha_CI5' 'alpha_CI95'...
				'epsilon_mode' 'epsilon_CI5' 'epsilon_CI95'},...
				'RowNames',{'GroupLevelInference'});

			combinedParameterEstimates = [participant_level ; group_level]

			savename = ['parameterEstimates_' obj.data.saveName '.txt'];
			writetable(combinedParameterEstimates, savename,...
				'Delimiter','\t')
			fprintf('The above table of participant and group-level parameter estimates was exported to:\n')
			fprintf('\t%s\n\n',savename)
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

			samples.m = obj.sampler.samples.glM(:);
			samples.c = obj.sampler.samples.glC(:);
			params(:,1) = samples.m(:);
			params(:,2) = samples.c(:);
			% ==============================================
			[posteriorMode, lh] = calculateLogK_ConditionOnReward(reward, params, plotFlag);
			lh.LineWidth = 3;
			lh.Color= 'k';
			%lh(count).DisplayName = 'Group level';
			%row(count) = {sprintf('Group level')};
			% ==============================================
		end

		function figParticiantTriPlot(obj,n)
			% samples from posterior
			temp = obj.sampler.getSamplesAtIndex(n, {'m', 'c','alpha','epsilon'});
			samples= [temp.m, temp.c, temp.alpha, temp.epsilon];
			% samples from prior
			% NOTE: we do not have direct priors over group level m, c, alpha, epsilon, but we do have then as the result of the relevant hyperpriors. So the appropriate priors here are the group level priors - which are effectively our prior for an unknown participant, before we see any data of course.
			priorSamples= [obj.sampler.samples.glMprior(:),...
				obj.sampler.samples.glCprior(:),...
				obj.sampler.samples.glALPHAprior(:),...
				obj.sampler.samples.glEpsilonprior(:)];
			figure(87)
			triPlotSamples(samples, priorSamples, {'m', 'c','alpha','epsilon'}, [])
		end

		function figGroupLevelTriPlot(obj)
			% samples from posterior
			samples= [obj.sampler.samples.glM(:),...
				obj.sampler.samples.glC(:),...
				obj.sampler.samples.glALPHA(:),...
				obj.sampler.samples.glEpsilon(:)];
			% samples from prior
			% NOTE: we do not have direct priors over group level m, c, alpha, epsilon, but we do have then as the result of the relevant hyperpriors. So the appropriate priors here are the group level priors - which are effectively our prior for an unknown participant, before we see any data of course.
			priorSamples= [obj.sampler.samples.glMprior(:),...
				obj.sampler.samples.glCprior(:),...
				obj.sampler.samples.glALPHAprior(:),...
				obj.sampler.samples.glEpsilonprior(:)];
			figure(87)
			triPlotSamples(samples, priorSamples, {'m', 'c','alpha','epsilon'}, [])
		end

	end


	methods(Static)


		function plotPsychometricParams(samples)
			% Plot priors/posteriors for parameters related to the psychometric
			% function, ie how response 'errors' are characterised
			%
			% plotPsychometricParams(hModel.sampler.samples)
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
			for p=1:P % plot participant level alpha (alpha(:,:,p))
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
			for p=1:P % plot participant level alpha (alpha(:,:,p))
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


		function figUnivariateSummary(uni, participantIDlist)
			figure

			subplot(4,1,1)
			plotErrorBars({'G^m' participantIDlist{:}},...
				[uni.glM.mode  uni.m.mode],...
				[uni.glM.CI95 uni.m.CI95], '$m$')
			%xlim([0.5 N+0.5])
			hline(0,...
				'Color','k',...
				'LineStyle','--')

			subplot(4,1,2)
			plotErrorBars({'G^c' participantIDlist{:}},...
				[uni.glC.mode uni.c.mode],...
				[uni.glC.CI95 uni.c.CI95], '$c$')
			%xlim([0.5 N+0.5])

			subplot(4,1,3) % LAPSE RATE
			plotErrorBars({'G^\epsilon' participantIDlist{:}},...
				[uni.glEpsilon.mode uni.epsilon.mode]*100,...
				[uni.glEpsilon.CI95 uni.epsilon.CI95]*100, '$\epsilon (\%)$')
			a=axis; ylim([0 a(4)])
			clear CI95 modeVals CI95

			subplot(4,1,4) % COMPARISON ACUITY
			plotErrorBars({'G^\alpha' participantIDlist{:}},...
				[uni.glALPHA.mode uni.alpha.mode],...
				[uni.glALPHA.CI95 uni.alpha.CI95], '$\alpha$')
			%xlim([0.5 N+0.5])
			a=axis; ylim([0 a(4)])
		end
	end

	methods (Access = protected)

		function figGroupLevel(obj)
			figure(99)
			set(gcf,'Name','GROUP LEVEL')
			clf

			% TODO: Use a group level equivalent of the following code
			% [pSamples] = obj.sampler.getSamplesAtIndex(n, {'m','c','alpha','epsilon'});
			% [pData] = obj.data.getParticipantData(n);

			pSamples.epsilon = obj.sampler.samples.glEpsilon(:);
			pSamples.alpha = obj.sampler.samples.glALPHA(:);
			pSamples.m = obj.sampler.samples.glM(:);
			pSamples.c = obj.sampler.samples.glC(:);

			figParticipant(obj, pSamples, [])

			% EXPORTING ---------------------
			latex_fig(16, 18, 4)
			myExport(obj.data.saveName, obj.modelType, '-GROUP')
			% -------------------------------
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
			myExport(obj.data.saveName, [], '-BayesFactorMLT1')
		end
	end



end
