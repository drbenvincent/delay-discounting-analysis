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

			%obj.JAGSmodel = [toolboxPath '/jagsModels/seperateME.txt'];

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

			obj.figParticipantLevelWrapper()

			MCMCdiagnoticsPlot(obj.sampler.samples, obj.sampler.stats,...
				[],...
				{'epsilon', 'alpha', 'm', 'c'},...
				{[0 0.5], 'positive', [], []},...
				{'\epsilon', '\alpha', 'm', 'c'}, obj.data,...
				obj.modelType);
		end


		function setInitialParamValues(obj)
			for n=1:obj.sampler.mcmcparams.nchains
				for p=1:obj.data.nParticipants
					obj.sampler.initial_param(n).alpha(p)	= abs(normrnd(0.01,0.01));
					obj.sampler.initial_param(n).lr(p)		= rand/10;

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

	end


	methods(Static)
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
