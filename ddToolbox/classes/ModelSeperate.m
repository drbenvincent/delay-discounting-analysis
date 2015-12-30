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

			%% Create variables
			% -------------------------------------------------------------------
			% Participant-level -------------------------------------------------
			m = Variable('m','m', [], true)
			m.seed.func = @() normrnd(-0.243,2);
			m.seed.single = false;

			mprior = Variable('mprior','mprior', [], true)
			mprior.seed.func = @() normrnd(-0.243,2);
			mprior.seed.single = true;

			c = Variable('c','c', [], true)
			c.seed.func = @() normrnd(0,4);
			c.seed.single = false;

			cprior = Variable('cprior','cprior', [], true)
			cprior.seed.func = @() normrnd(0,4);
			cprior.seed.single = true;

			epsilon = Variable('epsilon','\epsilon', [0 0.5], true)
			epsilon.seed.func = @() 0.1 + rand/10;
			epsilon.seed.single = false;

			epsilonprior = Variable('epsilonprior','\epsilon prior', [0 0.5], true)
			epsilonprior.seed.func = @() 0.1 + rand/10;
			epsilonprior.seed.single = true;

			alpha = Variable('alpha','\alpha', 'positive', true)
			alpha.seed.func = @() abs(normrnd(0.01,0.001));
			alpha.seed.single = false;

			alphaprior = Variable('alphaprior','\alpha prior', 'positive', true)
			alphaprior.seed.func = @() abs(normrnd(0.01,0.001));
			alphaprior.seed.single = true;

			% posterior predictive ----------------------------------------------
			Rpostpred = Variable('Rpostpred','Rpostpred', [0 1], true)
			Rpostpred.plotMCMCchainFlag = false;

			% define which to analyse (univariate analysis)
			m.analysisFlag = 1;
			c.analysisFlag = 1;
			epsilon.analysisFlag = 1;
			alpha.analysisFlag = 1;

			% Create a Variable array -------------------------------------------
			obj.variables = [m, c, epsilon, alpha,...
				mprior, cprior, epsilonprior, alphaprior,...
				Rpostpred];

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


% 		function figParticiantTriPlot(obj,n)
% 			% samples from posterior
% 			temp = obj.sampler.getSamplesAtIndex(n, {'m', 'c','alpha','epsilon'});
% 			samples= [temp.m, temp.c, temp.alpha, temp.epsilon];
% 			% samples from prior
% 			%temp = obj.sampler.getSamplesAtIndex(n, {'mprior', 'cprior','alphaprior','epsilonprior'});
% % 			priorSamples= [obj.sampler.samples.mprior(:),...
% % 				obj.sampler.samples.cprior(:),...
% % 				obj.sampler.samples.alphaprior(:),...
% % 				obj.sampler.samples.epsilonprior(:)];
% 			figure(87)
% 			%triPlotSamples(samples, priorSamples, {'m', 'c','alpha','epsilon'}, [])
% 			triPlotSamples(samples, [], {'m', 'c','alpha','epsilon'}, [])
% 		end

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

	end


end
