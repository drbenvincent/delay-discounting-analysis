classdef ModelSeperate < ModelBaseClass
	%ModelSeperate A model to estimate the magnitide effect. 
	%	Models a number of participants, but they are all treated as independent. 
	%	There is no group-level estimation.
	
	properties (Access = protected)
	end
	
	
	methods (Access = public)
		
		% CONSTRUCTOR =====================================================
		function obj = ModelSeperate(toolboxPath)
			% Because this class is a subclass of "ModelBaseClass" then we use
			% this next line to create an instance
			obj = obj@ModelBaseClass(toolboxPath);

			obj.JAGSmodel = [toolboxPath '/jagsModels/seperateME.txt'];
			[~,obj.modelType,~] = fileparts(obj.JAGSmodel);
		end
		% =================================================================
		

		function plot(obj, data)
			close all
			% plot univariate summary statistics for the parameters we have
			% made inferences about
			obj.figUnivariateSummary(obj.analyses.univariate, data.IDname)
			% EXPORTING ---------------------
			latex_fig(16, 5, 5)
			myExport(data.saveName, obj.modelType, '-UnivariateSummary')
			% -------------------------------
			
			obj.figParticipantLevelWrapper(data)

			MCMCdiagnoticsPlot(obj.samples, obj.stats,...
				[],...
				{'epsilon', 'alpha', 'm', 'c'},...
				{[0 0.5], 'positive', [], []},...
				{'\epsilon', '\alpha', 'm', 'c'}, data,...
				obj.modelType);
		end

	end
	
	
	methods (Access = protected)
		
		function setInitialParamValues(obj, data)
			for n=1:obj.mcmcparams.nchains
				for p=1:data.nParticipants
					obj.initial_param(n).alpha(p)	= abs(normrnd(0.01,0.01));
					obj.initial_param(n).lr(p)		= rand/10;
					
					obj.initial_param(n).m(p) = normrnd(-0.243,1);
					obj.initial_param(n).c(p) = normrnd(0,4);
				end
			end
		end
		

		function setMonitoredValues(obj, data)
			obj.monitorparams = {'epsilon','epsilonprior',...
				'alpha','alphaprior',...
				'm','mprior',...
				'c','cprior'};
		end
				

		function setObservedValues(obj, data)
			obj.observed = data.observedData;
			obj.observed.nParticipants = data.nParticipants;
			obj.observed.totalTrials = data.totalTrials;
		end


		function doAnalysis(obj) % <--- TODO: REMOVE THIS WRAPPER FUNCTION
			obj.analyses.univariate  = univariateAnalysis(obj.samples,...
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