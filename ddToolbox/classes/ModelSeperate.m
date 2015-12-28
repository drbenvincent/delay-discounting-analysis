classdef ModelSeperate < ModelBaseClass
	%ModelSeperate A model to estimate the magnitide effect.
	%	Models a number of participants, but they are all treated as independent.
	%	There is no group-level estimation.

	properties (Access = protected)
	end


	methods (Access = public)

		% CONSTRUCTOR =====================================================
		function obj = ModelSeperate(toolboxPath, sampler, data)
			% Because this class is a subclass of "ModelBaseClass" then we use
			% this next line to create an instance
			obj = obj@ModelBaseClass(toolboxPath, sampler, data);

			switch sampler
				case{'JAGS'}
					obj.sampler = JAGSSampler([toolboxPath '/jagsModels/seperateME.txt'])
					[~,obj.modelType,~] = fileparts(obj.sampler.fileName);
				case{'STAN'}
					error('NOT IMPLEMENTED YET')
			end

			% give sampler a handle back to the model (ie this hierarchicalME model)
			obj.sampler.modelHandle = obj;
		end
		% ================================================================


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

			obj.figParticipantLevelWrapper()
		end

		function plotMCMCchains(obj)
			MCMCdiagnoticsPlot(obj.sampler.samples, obj.sampler.stats,...
				[],...
				{'epsilon', 'alpha', 'm', 'c'},...
				{[0 0.5], 'positive', [], []},...
				{'\epsilon', '\alpha', 'm', 'c'});
		end

		function setInitialParamValues(obj)
			for n=1:obj.sampler.mcmcparams.nchains
				for p=1:obj.data.nParticipants
					obj.sampler.initial_param(n).alpha(p)	= abs(normrnd(0.01,0.01));
					obj.sampler.initial_param(n).lr(p)		= 0.1 + rand/10;

					obj.sampler.initial_param(n).m(p) = normrnd(-0.243,1);
					obj.sampler.initial_param(n).c(p) = normrnd(0,4);
				end
			end
		end


		function setMonitoredValues(obj)
			obj.monitorparams = {'epsilon','epsilonprior',...
				'alpha','alphaprior',...
				'm','mprior',...
				'c','cprior'};
		end


		function setObservedValues(obj)
			obj.sampler.observed = obj.data.observedData;
			obj.sampler.observed.nParticipants = obj.data.nParticipants;
			obj.sampler.observed.totalTrials = obj.data.totalTrials;
		end


		function doAnalysis(obj) % <--- TODO: REMOVE THIS WRAPPER FUNCTION
			obj.analyses.univariate  = univariateAnalysis(obj.sampler.samples,...
			{'epsilon', 'alpha', 'm', 'c'},...
			{'positive', 'positive', [], []});
		end

		function figParticiantTriPlot(obj,n)
			% samples from posterior
			temp = obj.sampler.getSamplesAtIndex(n, {'m', 'c','alpha','epsilon'});
			samples= [temp.m, temp.c, temp.alpha, temp.epsilon];
			% samples from prior
			%temp = obj.sampler.getSamplesAtIndex(n, {'mprior', 'cprior','alphaprior','epsilonprior'});
			priorSamples= [obj.sampler.samples.mprior(:),...
				obj.sampler.samples.cprior(:),...
				obj.sampler.samples.alphaprior(:),...
				obj.sampler.samples.epsilonprior(:)];
			figure(87)
			triPlotSamples(samples, priorSamples, {'m', 'c','alpha','epsilon'}, [])
		end

	end


	methods(Static)

		function plotPsychometricParams(samples)
			% Plot priors/posteriors for parameters related to the psychometric
			% function, ie how response 'errors' are characterised
			figure(7), clf
			P=size(samples.m,3); % number of participants
			%====================================
			subplot(3,2,1)
			plotPriorPostHist(samples.alphaprior(:), []);
			title('\alpha prior')

			subplot(3,2,5)
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
			plotPriorPostHist(samples.epsilonprior(:), []);
			title('\epsilon prior')

			% subplot(3,4,7),
			% plotPriorPostHist(samples.wprior(:), samples.w(:));
			% xlabel('\omega (mode)')
			%
			% subplot(3,4,8),
			% plotPriorPostHist(samples.kprior(:), samples.k(:));
			% xlabel('\kappa (concentration)')

			subplot(3,2,6)
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
			plotErrorBars(participantIDlist, [uni.m.mode], [uni.m.CI95], '$m$')
			hline(0,...
				'Color','k',...
				'LineStyle','--')

			subplot(4,1,2)
			plotErrorBars(participantIDlist, [uni.c.mode], [uni.c.CI95], '$c$')

			subplot(4,1,3) % LAPSE RATE
			plotErrorBars(participantIDlist, [uni.epsilon.mode]*100, [uni.epsilon.CI95]*100, '$\epsilon (\%)$') % plot as %
			%xlim([0.5 N+0.5])
			a=axis; ylim([0 a(4)])

			subplot(4,1,4) % COMPARISON ACUITY
			plotErrorBars(participantIDlist, [uni.alpha.mode], [uni.alpha.CI95], '$\alpha$')
			%xlim([0.5 N+0.5])
			a=axis; ylim([0 a(4)])
		end
	end


end
