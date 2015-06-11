classdef modelLINEAR < modelSeperate
	%modelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here
	
	properties
		
	end
	
	
	methods (Access = public)
		% =================================================================
		function obj = modelLINEAR(toolboxPath)
			% Because this class is a subclass of "modelME" then we use
			% this next line to create an instance
			obj = obj@modelSeperate(toolboxPath);
			
			% Overwrite
			obj.JAGSmodel = [toolboxPath '/jagsModels/linearModel.txt'];
			obj.modelType = 'mLinear';
			obj = obj.setMCMCparams();
		end
		% =================================================================
		
		
		
		function plot(obj, data)
			close all
			
			% Define limits for each of the variables here for plotting
			% purposes
			obj.range.lr=[0 min([prctile(obj.samples.lr(:),[99]) , 0.5])];
			%obj.range.alpha=[0 max(obj.samples.alpha(:))];
			obj.range.alpha=[0 prctile(obj.samples.alpha(:),[99])];
			% ranges for m and c to contain ALL samples.
			obj.range.m=[min(obj.samples.m(:)) max(obj.samples.m(:))];
			obj.range.c=[min(obj.samples.c(:)) max(obj.samples.c(:))];
			% zoom to contain virtually all samples.
			% 			obj.range.m=prctile([obj.samples.glM(:); obj.samples.m(:)],...
			% 				[0 100]);
			% 			obj.range.c=prctile([obj.samples.glC(:); obj.samples.c(:)],...
			% 				[0 100]);
			
			% plot univariate summary statistics for the parameters we have
			% made inferences about
			obj.figGroupedForestPlot(obj.analyses.univariate)
			% EXPORTING ---------------------
			latex_fig(16, 7, 9)
			myExport(data.saveName, obj.modelType, '-UnivariateSummary')
			% -------------------------------
			
			obj.figGroupLevel(data)
			
			obj.figParticipantLevelWRAPPER(data)
			
			%obj.MCMCdiagnostics(data)
		end
		
		
		function MCMCdiagnostics(obj, data)
			
			variablesToPlot = {'groupMmu', 'groupCmu', 'lr', 'alpha', 'm', 'c','groupW'};
			supp			= {[], [], [0 0.5], 'positive', [], [],[0 1]};
			paramString		= {'\mu_m', '\mu_c', '\epsilon', '\alpha', 'm', 'c', '\omega'};
			
			true=[];
			
			% PLOT -------------------
			MCMCdiagnoticsPlot(obj.samples, obj.stats,...
				true,...
				variablesToPlot, supp, paramString, data,...
				obj.modelType);
		end
		
		
		
		
		function plotCovariates(obj, data)
			
			figure, colormap(gray)
			subplot(2,2,1) % PLOT M as a function of COVARIATE for each participant
			hold on
			for p=1:data.nParticipants
				% plot CI
				x=data.observedData.covariate(p);
				plot( [x x] , obj.analyses.univariate.m.CI95(:,p),'k-')
				plot( x , obj.analyses.univariate.m.mode(p),'ko')
			end
			xlabel('covariate value')
			ylabel('m')
			% plot probe
			plot( data.observedData.covariateProbeVals, obj.analyses.univariate.probeM.mode,'k-')
			plot( data.observedData.covariateProbeVals, obj.analyses.univariate.probeM.CI95(1,:),'k--')
			plot( data.observedData.covariateProbeVals, obj.analyses.univariate.probeM.CI95(2,:),'k--')
			
			% plot slope distribution
			subplot(6,2,2)
			bandwidth = 0.005;
			bf = BayesFactor(obj.samples.thetaMprior(:),...
				vec(obj.samples.thetaM(:,:,1)),...
				0, bandwidth);
			
% 			opts.priorSamples = obj.samples.thetaMprior(:);
% 			opts.bayesFactorXvalue = 0;
% 			opts.xi = linspace(-1,1,1000);
% 			%opts.plotStyle='line';
% 			plotMCMCdist(vec(obj.samples.thetaM(:,:,1)), opts)
			xlabel('\theta_1^M (slope)')
			%vline(0, 'Color','k')
			
			% plot interept distribution
			subplot(6,2,4)
			plotMCMCdist(vec(obj.samples.thetaM(:,:,2)), [])
			%hist(vec(obj.samples.thetaM(:,:,2)),100)
			xlabel('\theta_2^M (intercept)')
			
			% plot std distribution
			subplot(6,2,6)
			plotMCMCdist(vec(obj.samples.thetaM(:,:,3)), [])
			%hist(vec(obj.samples.thetaM(:,:,2)),100)
			xlabel('\theta_3^M (std)')
			
			
			
			
			subplot(2,2,3) % PLOT C as a function of COVARIATE for each participant
			hold on
			for p=1:data.nParticipants
				% plot CI
				x=data.observedData.covariate(p);
				plot( [x x] , obj.analyses.univariate.c.CI95(:,p),'k-')
				plot( x , obj.analyses.univariate.c.mode(p),'ko')
			end
			xlabel('covariate value')
			ylabel('c')
			% plot probe
			plot( data.observedData.covariateProbeVals, obj.analyses.univariate.probeC.mode,'k-')
			plot( data.observedData.covariateProbeVals, obj.analyses.univariate.probeC.CI95(1,:),'k--')
			plot( data.observedData.covariateProbeVals, obj.analyses.univariate.probeC.CI95(2,:),'k--')

			% plot slope distribution
			subplot(6,2,8)
% 			opts.priorSamples = obj.samples.thetaCprior(:);
% 			opts.bayesFactorXvalue = 0;
% 			opts.xi = linspace(-1,1,1000);
% 			%hist(vec(obj.samples.thetaC(:,:,1)),100)
% 			plotMCMCdist(vec(obj.samples.thetaC(:,:,1)), opts)
			bf = BayesFactor(obj.samples.thetaCprior(:),...
				vec(obj.samples.thetaC(:,:,1)),...
				0, bandwidth);
			xlabel('\theta_1^C (slope)')
			vline(0, 'Color','k')
			
			% plot interept distribution
			subplot(6,2,10)
			hist(vec(obj.samples.thetaC(:,:,2)),100)
			plotMCMCdist(vec(obj.samples.thetaC(:,:,2)), [])
			xlabel('\theta_2^C (intercept)')
			
			% plot std distribution
			subplot(6,2,12)
			plotMCMCdist(vec(obj.samples.thetaC(:,:,3)), [])
			%hist(vec(obj.samples.thetaM(:,:,2)),100)
			xlabel('\theta_3^C (std)')
			
			% EXPORTING ---------------------
			latex_fig(16, 9, 10)
			myExport(data.saveName, obj.modelType, '-covariatePlot')
			% -------------------------------
		end
		
		
		
		
		
		
		function figGroupedForestPlot(obj, uni)
			% figGroupedForestPlot
			% is basically a wrapper to plot multiple subplots of
			% plotGroupedForestPlot
			%
			% takes in a structure called uni
			% uni holds stats for multiple model fits
			
			figure
			
			GROUPS = numel(uni);
			
			clear CI95
			
			% % -----------------------------------------------------------
			% subplot(4,1,1)
			% for g=1:GROUPS
			% 	modeVals(:,g) = [uni(g).glM.mode  uni(g).m.mode];
			% 	CI95(:,:,g) = [uni(g).glM.CI95 uni(g).m.CI95];
			% end
			%
			% [N, nGroups] = size(modeVals);
			%
			% % create labels ---
			% xlabels=cell(N+1,1);
			% xlabels{1} = 'G^m';
			% for n=1:N, xlabels{n+1} = n; end
			% % -------
			%
			% % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			% plotGroupedForestPlot(xlabels, modeVals, CI95, '$m$')
			% % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			% xlim([0.5 N+0.5])
			% hline(0,...
			% 	'Color','k',...
			% 	'LineStyle','--')
			%
			% clear CI95 modeValsCI95
			%
			% % -----------------------------------------------------------
			% subplot(4,1,2)
			% for g=1:GROUPS
			% 	modeVals(:,g) = [uni(g).glC.mode  uni(g).c.mode];
			% 	CI95(:,:,g) = [uni(g).glC.CI95 uni(g).c.CI95];
			% end
			% xlabels{1} = 'G^c';
			% plotGroupedForestPlot(xlabels, modeVals, CI95, '$c$')
			% xlim([0.5 N+0.5])
			%
			% clear CI95 modeValsCI95
			
			% -----------------------------------------------------------
			subplot(4,1,3) % LAPSE RATE
			for g=1:GROUPS
				modeVals(:,g) = [uni(g).glLR.mode uni(g).lr.mode];
				CI95(:,:,g) = [uni(g).glLR.CI95 uni(g).lr.CI95];
			end
			[N, nGroups] = size(modeVals);
			% modeVals = [uniH.lr.mode ; uniS.lr.mode];
			% CI95(:,:,1) = uniH.lr.CI95;
			% CI95(:,:,2) = uniS.lr.CI95;
			
			% create labels ---
			xlabels=cell(N+1,1);
			xlabels{1} = 'G^\lambda';
			for n=1:N, xlabels{n+1} = n; end
			% -------
			
			plotGroupedForestPlot(xlabels, modeVals, CI95, '$\lambda$')
			xlim([0.5 N+0.5])
			a=axis; ylim([0 a(4)])
			clear CI95 modeVals CI95
			
			% -----------------------------------------------------------
			subplot(4,1,4) % COMPARISON ACUITY
			for g=1:GROUPS
				modeVals(:,g) = [uni(g).glALPHA.mode uni(g).alpha.mode];
				CI95(:,:,g) = [uni(g).glALPHA.CI95 uni(g).alpha.CI95];
			end
			[N, nGroups] = size(modeVals);
			% modeVals = [uniH.sigma.mode ; uniS.sigma.mode];
			% CI95(:,:,1) = uniH.sigma.CI95;
			% CI95(:,:,2) = uniS.sigma.CI95;
			
			% create labels ---
			xlabels=cell(N+1,1);
			xlabels{1} = 'G^\alpha';
			for n=1:N, xlabels{n+1} = n; end
			% -------
			
			plotGroupedForestPlot(xlabels, modeVals, CI95, '$\alpha$')
			xlim([0.5 N+0.5])
			a=axis; ylim([0 a(4)])
			
		end
		
	end
	
	
	
	methods (Access = protected)
		
		function [obj] = setObservedMonitoredValues(obj, data)
			obj.observed = data.observedData;
			obj.observed.logBInterp = log( logspace(0,5,99) );
			% group-level stuff
			obj.observed.nParticipants	= data.nParticipants;
			obj.observed.totalTrials	= data.totalTrials;
			
			obj.monitorparams = {'lr','lrprior', 'glLR',...
				'alpha','alphaprior', 'glALPHA',......
				'm', 'thetaM', 'thetaMprior',...
				'c', 'thetaC', 'thetaCprior',...
				'probeM','probeC'};
		end
		
		function figGroupLevel(obj, data)
			
			figure(99)
			set(gcf,'Name','GROUP LEVEL')
			clf
			
			% BIVARIATE PLOT: lapse rate & comparison accuity
			figure(99), subplot(1, 5, 1)
			[structName] = plot2DErrorAccuity(obj.samples.glLR(:),...
				obj.samples.glALPHA(:),...
				obj.range.lr,...
				obj.range.alpha);
			lrMODE = structName.modex;
			alphaMODE= structName.modey;
			
			% PSYCHOMETRIC FUNCTION (using my posterior-prediction-plot-matlab GitHub repository)
			figure(99), subplot(1, 5, 2)
			tempsamples.lr = obj.samples.glLR;
			tempsamples.alpha = obj.samples.glALPHA;
			plotPsychometricFunc(tempsamples, [lrMODE, alphaMODE])
			clear tempsamples
			
			
% 			figure(99), subplot(1,5,3)
% 			[groupLevelMCinfo] = plot2Dmc(obj.samples.glM(:),...
% 				obj.samples.glC(:), obj.range.m, obj.range.c);
% 			
% 			GROUPmodeM = groupLevelMCinfo.modex;
% 			GROUPmodeC = groupLevelMCinfo.modey;
% 			
% 			
% 			figure(99), subplot(1,5,4)
% 			tempsamples.m = obj.samples.glM(:);
% 			tempsamples.c = obj.samples.glC(:);
% 			plotMagnitudeEffect(tempsamples, [GROUPmodeM, GROUPmodeC])
% 			
% 			
% 			figure(99), subplot(1, 5, 5)
% 			opts.maxlogB	= max(data.observedData.B(:));
% 			opts.maxD		= max(data.observedData.DB(:));
% 			% PLOT A POINT-ESTIMATE DISCOUNT SURFACE
% 			calculateDiscountSurface(GROUPmodeM, GROUPmodeC, opts);
% 			set(gca,'XTick',[10 100])
% 			set(gca,'XTickLabel',[10 100])
% 			set(gca,'XLim',[10 100])
% 			% PLOT A DISCOUNT SURFACE WITH UNCERTAINTY
% 			% calculateDiscountSurfaceUNCERTAINTY(obj.samples.glM(:), obj.samples.glC(:), opts)
			
			
			% EXPORTING ---------------------
			latex_fig(16, 18, 4)
			myExport(data.saveName, obj.modelType, '-GROUP')
			% -------------------------------
			
		end
		
		
		function obj = setInitialParamValues(obj, data)
			for n=1:obj.mcmcparams.nchains
				% Values for which there are just one of
				%obj.initial_param(n).groupW = rand/10; % group mean lapse rate
				
				% 				obj.initial_param(n).groupMmu = normrnd(-1,1);
				% 				obj.initial_param(n).groupCmu = normrnd(0,1);
				
				obj.initial_param(n).mprior = normrnd(-1,2);
				obj.initial_param(n).cprior = normrnd(0,2);
				
				% M = f(covariate): slope
				obj.initial_param(n).thetaM(1) = randn*0.01; % slope
				obj.initial_param(n).thetaM(2) = randn*4; % intercept
				obj.initial_param(n).thetaM(3) = rand; % std
				obj.initial_param(n).thetaM(4) = rand; % nu
				
				% C = f(covariate): slope
				obj.initial_param(n).thetaC(1) = randn*0.01; % slope
				obj.initial_param(n).thetaC(2) = randn*4; % intercept
				obj.initial_param(n).thetaC(3) = rand; % std
				obj.initial_param(n).thetaC(4) = rand; % nu
				
				% One value for each participant
				for p=1:data.nParticipants
					obj.initial_param(n).alpha(p)	= abs(normrnd(0.01,0.001));
					obj.initial_param(n).lr(p)		= rand/10;
					
					obj.initial_param(n).m(p) = normrnd(-1,2);
					obj.initial_param(n).c(p) = normrnd(0,2);
				end
			end
		end
		
		
		function obj = doAnalysis(obj)
			% univariate summary stats
			obj.analyses.univariate = univariateAnalysisALL(obj.samples);
			
			% bivariate summary stats
		end
		
	end
	
end

