classdef ModelHierarchicalNOMAG < ModelHierarchical
	%modelME A model to estimate the magnitide effect
	%   Detailed explanation goes here
	
	properties
		
	end
	
	
	
	methods (Access = public)
		% =================================================================
		function obj = ModelHierarchicalNOMAG(toolboxPath)
			% Because this class is a subclass of "ModelSeperate" then we use
			% this next line to create an instance
			obj = obj@ModelHierarchical(toolboxPath);
			
			% Overwrite
			obj.JAGSmodel = [toolboxPath '/jagsModels/hierarchicalNOMAG.txt'];
			obj.modelType = 'mHierarchicalNOMAG';
			
			obj = obj.setMCMCparams();
		end
		% =================================================================
		
		
		% 		% OVERLOAD
		% 		function obj = setInitialParamValues(obj)
		% 			for n=1:obj.mcmcparams.nchains
		% 				for p=1:obj.participant.data.nParticipants
		% 					obj.initial_param(n).sigma(p)	= abs(normrnd(0.01,0.001));
		% 				end
		% 			end
		% 		end
		
		
		

		
		% OVERLOAD
		function plot(obj, data)
			close all
			
			% Define limits for each of the variables here for plotting
			% purposes
			obj.range.lr=[0 min([prctile(obj.samples.lr(:),[99]) , 1])];
			%obj.range.sigma=[0 max(obj.samples.sigma(:))];
			obj.range.sigma=[0 prctile(obj.samples.sigma(:),[99])];
			% ranges for m and c to contain ALL samples.
			%obj.range.logK=[min(obj.samples.participantLogK(:)) max(obj.samples.participantLogK(:))];
			% zoom to contain virtually all samples.
			obj.range.logK=prctile(obj.samples.participantLogK(:),[0.1 100-0.1]);
			
			
			% plot univariate summary statistics for the parameters we have
			% made inferences about
			obj.stackedForestPlot(obj.analyses.univariate)
			
			obj.figGroupLevel(data)
			obj.figParticipantLevelWRAPPER(data)
			
			% plot MCMC diagnostics
			obj.MCMCdiagnostics(data)
		end
		
		
		function MCMCdiagnostics(obj, data)
			% Choose what to plot ---------------
			
			variablesToPlot = {'groupLogKmu', 'participantLogK', 'lr', 'sigma'};
			supp			= {[], [], [0 1], 'positive'};
			paramString		= {'groupLogKmu','pLogK','\mu_m', '\mu_c', '\eta', '\sigma'};
			true=[];
			
			% PLOT -------------------
			MCMCdiagnoticsPlot(obj.samples, obj.stats,...
				true,...
				variablesToPlot, supp, paramString, data,...
				obj.modelType);
		end
		
		
		
	end
	
	methods (Access = protected)		
		
		
		% OVERLOAD
		function [obj] = setObservedMonitoredValues(obj, data)
			obj.observed = data.observedData;
			obj.observed.logBInterp = log( logspace(0,5,99) );
			% group-level stuff
			obj.observed.nParticipants	= data.nParticipants;
			obj.observed.totalTrials	= data.totalTrials;
			
			% 			% Do account for the magnitude effect, and estimate slope
			% 			obj.plotOpts.EstimateMagnitiudeEffect = false;
			
			obj.monitorparams = {'lr','lrprior',...
				'sigma','sigmaprior',...
				'participantLogK', 'groupLogKmu',...
				'groupW'};
			
		end
		
		function figGroupLevel(obj, data)
			
			figure(99)
			set(gcf,'Name','GROUP LEVEL')
			clf
			
			cols = 4;
			
			
			figure(99), subplot(1,cols,1), axis square
			%addTextToFigure('TL','delete this panel', 10)
			histogram(obj.samples.groupW(:)), axis square
			xlabel('lapse rate $\epsilon$','Interpreter','latex')
			ylabel('comparison accuity $\sigma$','Interpreter','latex')
			
			
			% 			figure(99), subplot(1,5,3)
			% 			% M/C bivariate plot
			% 			tempsamples.m = obj.samples.groupMmu;
			% 			tempsamples.c = obj.samples.groupCmu;
			% 			xlim = obj.range.m;
			% 			ylim = obj.range.c;
			% 			[structName] = plot2Dmc(tempsamples.m, tempsamples.c, xlim, ylim);
			% 			GROUPmodeM = structName.modex;
			% 			GROUPmodeC = structName.modey;
			% 			xlabel('$\mu_m$', 'interpreter', 'latex')
			% 			ylabel('$\mu_c$', 'interpreter', 'latex')
			
			figure(99), subplot(1,cols,3)
			% -------
			plotDiscountRateDistribution(obj.samples.groupLogKmu(:))
			% -------
			
			% 			figure(99), subplot(1,5,4)
			% 			tempsamples.m = obj.samples.groupMmu;
			% 			tempsamples.c = obj.samples.groupCmu;
			% 			plotMagnitudeEffect(tempsamples, [GROUPmodeM, GROUPmodeC])
			
			
			figure(99), subplot(1, cols, 4)
			%opts.maxlogB	= max(data.observedData.B);
			%opts.maxD		= max(data.observedData.D);
			
			% plot data + inferred discount curve
			subplot(1, cols, 4)
			% plot inferred discount function
			plotDiscountFunctionNOMAG(obj.samples.groupLogKmu(:), data.observedData)
			
			
			
			% EXPORTING ---------------------
			latex_fig(16, 18, 4)
			myExport(data.saveName, obj.modelType, '-GROUP')
			% -------------------------------
			
			
			% 			figure
			% 			rows=2; cols=3;
			% 			subplot(rows,cols,1), plotMCMCdist(obj.samples.groupMmu,[]); title('groupMmu')
			% 			subplot(rows,cols,4), plotMCMCdist(obj.samples.groupCmu,[]); title('groupCmu')
			
		end
		
		function obj = doAnalysis(obj)
			% univariate summary stats
			fields ={'lr', 'sigma','groupW', 'groupLogKmu', 'participantLogK'};
			support={'positive', 'positive', [0 1], [], []};
			uni = univariateAnalysis(obj.samples, fields, support );
			obj.analyses.univariate = uni;
			
			% bivariate summary stats
			
		end
		
		
		
		
		function stackedForestPlot(obj, uni)
			
			% how many participants do we have
			N = numel(uni.lr.mode);
			
			% create x labels
			xlabels=cell(N+1,1);
			xlabels{1} = 'group';
			for n=1:N
				xlabels{n+1} = n;
			end
			
			subplot(4,1,1)
			forestPlot(xlabels, [uni.groupLogKmu.mode uni.participantLogK.mode],...
				[uni.groupLogKmu.CI95 uni.participantLogK.CI95],...
				'logK')
			
			subplot(4,1,3)
			forestPlot(xlabels, [uni.groupW.mode uni.lr.mode],...
				[uni.groupW.CI95 uni.lr.CI95], '\lambda')
			%xlim([-1 N+1])
			
			subplot(4,1,4)
			forestPlot(1:N, uni.sigma.mode, uni.sigma.CI95, '\sigma')
			xlim([-1 N+1])
			
		end
		
		
		
		
		
		
		function figParticipant(obj, samples, data)
			% samples and data should contain information for the current
			% participant of interest
			
			rows=1; cols=4;
			
			% BIVARIATE PLOT: lapse rate & comparison accuity
			subplot(rows, cols, 1)
			[structName] = plot2DErrorAccuity(samples.lr(:),...
				samples.sigma(:),...
				obj.range.lr,...
				obj.range.sigma);
			lrMODE = structName.modex;
			sigmaMODE= structName.modey;
			
			% PSYCHOMETRIC FUNCTION (using my posterior-prediction-plot-matlab GitHub repository)
			subplot(rows, cols, 2)
			plotPsychometricFunc(samples, [lrMODE, sigmaMODE])
			
			% 			% M/C bivariate plot
			% 			subplot(rows, cols, 3)
			% 			[structName] = plot2Dmc(samples.m(:), samples.c(:),...
			% 				obj.range.m, obj.range.c);
			% 			modeM = structName.modex;
			% 			modeC = structName.modey;
			
			% PLOT LOG(K)
			subplot(rows, cols, 3)
			% -------
			plotDiscountRateDistribution(samples.participantLogK(:))
			% -------
			
			
			
			
			
			
			
			
			% plot data + inferred discount curve
			subplot(rows, cols, 4)
			% plot inferred discount function
			plotDiscountFunctionNOMAG(samples.participantLogK(:), data)
			% plot data
			plotRawDataNOMAG(data)
			
			
			
			
			
			axis square
			
		end
		
		
		
		
		
		% 		function stackedGroupedForestPlot2(uni)
		% 			% stackedGroupedForestPlot
		% 			% is basically a wrapper to plot multiple subplots of
		% 			% groupedForestPlot
		% 			%
		% 			% takes in a structure called uni
		% 			% uni holds stats for multiple model fits
		%
		%
		%
		% 			figure
		%
		% 			GROUPS = numel(uni);
		%
		% 			clear CI95
		%
		% 			% -----------------------------------------------------------
		% 			subplot(4,1,1)
		% 			for g=1:GROUPS
		% 				modeVals(:,g) = [uni(g).groupMmu.mode  uni(g).m.mode];
		% 				CI95(:,:,g) = [uni(g).groupMmu.CI95 uni(g).m.CI95];
		% 			end
		%
		% 			[N, nGroups] = size(modeVals);
		%
		% 			% create labels ---
		% 			xlabels=cell(N+1,1);
		% 			xlabels{1} = 'group';
		% 			for n=1:N, xlabels{n+1} = n; end
		% 			% -------
		%
		% 			groupedForestPlot(xlabels, modeVals, CI95, '$m$')
		% 			xlim([0.5 N+0.5])
		% 			hline(0,...
		% 				'Color','k',...
		% 				'LineStyle','--')
		%
		% 			clear CI95 modeValsCI95
		%
		% 			% -----------------------------------------------------------
		% 			subplot(4,1,2)
		% 			for g=1:GROUPS
		% 				modeVals(:,g) = [uni(g).groupCmu.mode  uni(g).c.mode];
		% 				CI95(:,:,g) = [uni(g).groupCmu.CI95 uni(g).c.CI95];
		% 			end
		% 			groupedForestPlot(xlabels, modeVals, CI95, '$c$')
		% 			xlim([0.5 N+0.5])
		%
		% 			clear CI95 modeValsCI95
		%
		% 			% -----------------------------------------------------------
		% 			subplot(4,1,3)
		% 			for g=1:GROUPS
		% 				modeVals(:,g) = [uni(g).groupW.mode uni(g).lr.mode];
		% 				CI95(:,:,g) = [uni(g).groupW.CI95 uni(g).lr.CI95];
		% 			end
		% 			% modeVals = [uniH.lr.mode ; uniS.lr.mode];
		% 			% CI95(:,:,1) = uniH.lr.CI95;
		% 			% CI95(:,:,2) = uniS.lr.CI95;
		% 			groupedForestPlot(xlabels, modeVals, CI95, '$\lambda$')
		% 			xlim([0.5 N+0.5])
		% 			a=axis; ylim([0 a(4)])
		% 			clear CI95 modeVals CI95
		%
		% 			% -----------------------------------------------------------
		% 			subplot(4,1,4)
		% 			for g=1:GROUPS
		% 				modeVals(:,g) = uni(g).sigma.mode;
		% 				CI95(:,:,g) = uni(g).sigma.CI95;
		% 			end
		% 			% modeVals = [uniH.sigma.mode ; uniS.sigma.mode];
		% 			% CI95(:,:,1) = uniH.sigma.CI95;
		% 			% CI95(:,:,2) = uniS.sigma.CI95;
		% 			groupedForestPlot([1:N], modeVals, CI95, '$\sigma$')
		% 			xlim([0.5-1 N-1+0.5])
		% 			a=axis; ylim([0 a(4)])
		%
		% 		end
		%
		
		
		% OVERLOAD
		function obj = setInitialParamValues(obj, data)
			% It is important to start with reasonable initial parameters,
			% otherwise the chains can not converge, or take a long time to
			% converge.
			
			for n=1:obj.mcmcparams.nchains
				% Values for which there are just one of
				obj.initial_param(n).groupW = rand/10; % group mean lapse rate
				
				obj.initial_param(n).groupLogKmu =  normrnd( log(0.01), 1);
				
				% One value for each participant
				for p=1:data.nParticipants
					obj.initial_param(n).sigma(p)	= abs(normrnd(0.01,0.001));
					obj.initial_param(n).lr(p)		= rand/10;
					
					% -----------------------------------------------------
					% Calcualte a quick and dirty estimate of the logk for
					% this participant
					[pData] = data.getParticipantData(p);
					logk(p) = quickAndDirtyEstimateOfLogK(pData);
					% -----------------------------------------------------
					obj.initial_param(n).participantLogK(p) =  normrnd( logk(p), 0.01);
					% -----------------------------------------------------
					
					% 					obj.initial_param(n).m(p) = normrnd(-1,2);
					% 					obj.initial_param(n).c(p) = normrnd(0,2);
				end
			end
		end
		
		
	end
	
end

