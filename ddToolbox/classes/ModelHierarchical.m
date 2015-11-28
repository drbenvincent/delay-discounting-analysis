classdef ModelHierarchical < ModelSeperate
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here
	
	properties
	end
	
	
	methods (Access = public)
		% =================================================================
		function obj = ModelHierarchical(toolboxPath)
			% Because this class is a subclass of "modelME" then we use
			% this next line to create an instance
			obj = obj@ModelSeperate(toolboxPath);
			
			% Overwrite
			obj.JAGSmodel = [toolboxPath '/jagsModels/hierarchicalME.txt'];
			[~,obj.modelType,~] = fileparts(obj.JAGSmodel);
			obj = obj.setMCMCparams();
		end
		% =================================================================
		

		function plot(obj, data)
			close all
			% plot univariate summary statistics for the parameters we have
			% made inferences about
			figGroupedForestPlot(obj.analyses.univariate)
			% EXPORTING ---------------------
			latex_fig(16, 5, 5)
			myExport(data.saveName, obj.modelType, '-UnivariateSummary')
			% -------------------------------
			
			obj.figPriorPost()
			obj.figGroupLevel(data)
			obj.figParticipantLevelWRAPPER(data)
			obj.MCMCdiagnostics(data)
		end
		
		function calcSampleRange(obj)
			% Define limits for each of the variables here for plotting purposes
			obj.range.epsilon=[0 min([prctile(obj.samples.epsilon(:),[99]), 0.5])];
			obj.range.alpha=[0 prctile(obj.samples.alpha(:), [99])];
			obj.range.m=prctile([obj.samples.glM(:); obj.samples.m(:)], [0.5 99.5]);
			obj.range.c=prctile([obj.samples.glC(:); obj.samples.c(:)], [1 99]);
		end
		
		function MCMCdiagnostics(obj, data)
			
			variablesToPlot = {'glM', 'glC', 'glEpsilon', 'glALPHA', 'm', 'c', 'groupALPHAmu', 'groupALPHAsigma'};
			supp			= {[], [], [0 0.5], 'positive', [], [], [], 'positive'};
			paramString		= {'G^m', 'G^c', 'G^{\epsilon}', 'G^{\alpha}', 'm', 'c', '\mu^\alpha', '\sigma^\alpha'};
			
			true=[];
			
			% PLOT -------------------
			MCMCdiagnoticsPlot(obj.samples, obj.stats,...
				true,...
				variablesToPlot, supp, paramString, data,...
				obj.modelType);
		end
		
		
		function figPriorPost(obj)
			% plot prior and posterior distributions of the group level parameters
			figure
			
			subplot(2,2,1)
			hPrior = histogram(obj.samples.glEpsilonprior(:),...
				'DisplayStyle','stairs',...
				'Normalization', 'pdf');
			hPrior.LineStyle='--';
			hold on
			hPosterior = histogram(obj.samples.glEpsilon(:),...
				'DisplayStyle','stairs',...
				'Normalization', 'pdf');
			xlim(hPosterior.BinLimits)
			title('G^\epsilon')
			box off
			
			subplot(2,2,2)
			hPrior = histogram(obj.samples.glALPHAprior(:),...
				'DisplayStyle','stairs',...
				'Normalization', 'pdf');
			hPrior.LineStyle='--';
			hold on
			hPosterior = histogram(obj.samples.glALPHA(:),...
				'DisplayStyle','stairs',...
				'Normalization', 'pdf');
			xlim(hPosterior.BinLimits)
			title('G^\alpha')
			box off
			
			% 			clear opts
			% 			posteriorSamples	= obj.samples.glEpsilon(:);
			% 			opts.priorSamples	= obj.samples.glEpsilonprior(:);
			% 			opts.PlotBoxAspectRatio=[1 1 1];
			% 			opts.plotStyle = 'line';
			% 			opts.nbins = 1000;
			% 			subplot(1,2,1), plotMCMCdist(posteriorSamples, opts);
			% 			title('G^\epsilon')
			

			%			clear opts
			% 			posteriorSamples	= obj.samples.glALPHA(:);
			% 			opts.priorSamples	= obj.samples.glALPHAprior(:);
			% 			opts.PlotBoxAspectRatio=[1 1 1];
			% 			opts.plotStyle = 'line';
			% 			opts.nbins = 1000;
			% 			subplot(1,2,2), plotMCMCdist(posteriorSamples, opts);
			% 			title('G^\alpha')
			
			
			subplot(2,2,3)
			hPrior = histogram(obj.samples.glMprior(:),...
				'DisplayStyle','stairs',...
				'Normalization', 'pdf');
			hPrior.LineStyle='--';
			hold on
			hPosterior = histogram(obj.samples.glM(:),...
				'DisplayStyle','stairs',...
				'Normalization', 'pdf');
			xlim(hPosterior.BinLimits)
			title('G^m')
			box off
			
			subplot(2,2,4)
			hPrior = histogram(obj.samples.glCprior(:),...
				'DisplayStyle','stairs',...
				'Normalization', 'pdf');
			hPrior.LineStyle='--';
			hold on
			hPosterior = histogram(obj.samples.glC(:),...
				'DisplayStyle','stairs',...
				'Normalization', 'pdf');
			xlim(hPosterior.BinLimits)
			title('G^c')
			box off
			
% 			clear opts
% 			posteriorSamples	= obj.samples.glM(:);
% 			opts.priorSamples	= obj.samples.glMprior(:);
% 			opts.PlotBoxAspectRatio=[1 1 1];
% 			opts.plotStyle = 'line';
% 			opts.nbins = 100;
% 			subplot(1,2,1), plotMCMCdist(posteriorSamples, opts);
% 			title('G^m')
% 			
% 			clear opts
% 			posteriorSamples	= obj.samples.glC(:);
% 			opts.priorSamples	= obj.samples.glCprior(:);
% 			opts.PlotBoxAspectRatio=[1 1 1];
% 			opts.plotStyle = 'line';
% 			opts.nbins = 1000;
% 			subplot(1,2,2), plotMCMCdist(posteriorSamples, opts);
% 			title('G^c')
			
		end
		

		function HTgroupSlopeLessThanZero(obj, data)
			% Test the hypothesis that the group level slope (G^m) is less
			% than one
			
			%% METHOD 1 - BAYES FACTOR ------------------------------------
			% extract samples
			priorSamples = obj.samples.glMprior(:);
			posteriorSamples = obj.samples.glM(:);
			% in order to evaluate the order-restricted hypothesis m<0, then we need to
			% remove samples where either prior or posterior contain samples
			priorSamples = priorSamples(priorSamples<0);
			posteriorSamples = posteriorSamples(posteriorSamples<0);
			
			% 			% calculate the density at m=0, using kernel density estimation
			% 			MMIN = min([priorSamples; posteriorSamples])*1.1;
			% 			[bandwidth,priordensity,xmesh,cdf]=kde(priorSamples,500,MMIN,0);
			% 			trapz(xmesh,priordensity) % check the area is 1
			% 			[bandwidth,postdensity,xmesh,cdf]=kde(posteriorSamples,500,MMIN,0);
			% 			trapz(xmesh,postdensity) % check the area is 1
			%
			% 			%priordensity = priordensity./sum(priordensity);
			% 			%postdensity = postdensity./sum(postdensity);
			% 			% calculate log bayes factor
			% 			BF_01 =  priordensity(xmesh==0) / postdensity(xmesh==0) ;
			% 			BF_10 =  postdensity(xmesh==0) / priordensity(xmesh==0) ;
			
			binsize = 0.05;
			
			edges = [-5:binsize:0];
			% 			% First plot
			% 			histogram(priorSamples, edges, 'Normalization','pdf', 'DisplayStyle','stairs')
			% 			hold on
			% 			histogram(posteriorSamples, edges, 'Normalization','pdf', 'DisplayStyle','stairs')
			% Grab the actual density
			[Nprior,~] = histcounts(priorSamples, edges, 'Normalization','pdf');
			[Npost,~] = histcounts(posteriorSamples, edges, 'Normalization','pdf');
			% grab density at zero
			postDensityAtZero	= Npost(end);
			priorDensityAtZero	= Nprior(end);
			% Calculate Bayes Factor
			
			BF_10 = postDensityAtZero / priorDensityAtZero
			BF_01 = priorDensityAtZero / postDensityAtZero
			
			
			% plot
			figure
			subplot(1,2,1)
			%plot(xmesh,priordensity,'k--')
			h = histogram(priorSamples, edges, 'Normalization','pdf');
			h.EdgeColor = 'none';
			h.FaceColor = [0.7 0.7 0.7];
			hold on
			%plot(xmesh,postdensity,'k-')
			h = histogram(posteriorSamples, edges, 'Normalization','pdf');
			h.EdgeColor = 'none';
			h.FaceColor = [0.2 0.2 0.2];
			% plot density at x=0
			plot(0, priorDensityAtZero,'ko','MarkerFaceColor','w')
			plot(0, postDensityAtZero,'ko','MarkerFaceColor','k')
			%legend('prior','post', 'Location','NorthWest')
			%legend boxoff
			axis square
			box off
			axis tight, xlim([-2 0])
			removeYaxis()
			%addTextToFigure('TR',...
			%	sprintf('log BF_{10} = %2.2f',log(BF_10)),...
			%	15,	'latex')
			%ylabel('density')
			xlabel('G^m')
			title('Bayesian hypothesis testing')
			
			%% METHOD 2 ----------------------------------------------------
			% Now plot posterior distribution and examine HDI
			subplot(1,2,2)
			priorSamples = obj.samples.glMprior(:);
			posteriorSamples = obj.samples.glM(:);
			
			edges = [-5:binsize:2];
			% prior
			h = histogram(priorSamples, edges, 'Normalization','pdf');
			h.EdgeColor = 'none';
			h.FaceColor = [0.7 0.7 0.7];
			hold on
			
			% posterior
			h = histogram(posteriorSamples, edges, 'Normalization','pdf');
			h.EdgeColor = 'none';
			h.FaceColor = [0.2 0.2 0.2];
			
			%legend('prior','post', 'Location','NorthWest')
			%legend boxoff
			axis square
			box off
			axis tight, xlim([-2 1])
			removeYaxis()
			
			xlabel('G^m')
			title('Parameter estimation')
			
			showHDI(posteriorSamples)
			
			% 			opts.PlotBoxAspectRatio=[1 1 1];
			% 			opts.plotStyle = 'line';
			% 			opts.priorSamples = priorSamples;
			% 			opts.nbins = 1000;
			% 			subplot(1,2,2)
			% 			plotMCMCdist(posteriorSamples, opts);
			% 			title('b.')
			% 			xlabel('G^m')
			% 			xlim([-1.5 1])
			
			%%
			myExport(data.saveName, [], '-BayesFactorMLT1')
		end
		
		
		function conditionalDiscountRates(obj, reward, plotFlag)
			% For group level and all participants...
			% Extract and plot P( log(k) | reward)
			
			count=1;
			
			%% Participant level
			nParticipants = size(obj.samples.m,3);
			for p = 1:nParticipants
				samples.m = vec(obj.samples.m(:,:,p));
				samples.c = vec(obj.samples.c(:,:,p));
				params(:,1) = samples.m(:);
				params(:,2) = samples.c(:);
				% ==============================================
				[posteriorMode(count) , lh(count)] =...
					obj.calculateLogK_ConditionOnReward(reward, params, plotFlag);
				lh(count).DisplayName=sprintf('participant %d', p);
				row(count) = {sprintf('participant %d', p)};
				%title(['Participant: ' num2str(p)])
				% ==============================================
				count=count+1;
			end
			
			%% Group level
			samples.m = obj.samples.glM(:);
			samples.c = obj.samples.glC(:);
			params(:,1) = samples.m(:);
			params(:,2) = samples.c(:);
			% ==============================================
			[posteriorMode(count) , lh(count)] = obj.calculateLogK_ConditionOnReward(reward, params, plotFlag);
			lh(count).LineWidth = 3;
			lh(end).Color= 'k';
			lh(count).DisplayName = 'Group level';
			row(count) = {sprintf('Group level')};
			% ==============================================
			
			logkCondition = array2table([posteriorMode'],...
				'VariableNames',{'logK_posteriorMode'},...)
				'RowNames', row )
			
			if plotFlag
				% FORMATTING OF FIGURE
				removeYaxis
				title(sprintf('$P(\\log(k)|$reward=$\\pounds$%d$)$', reward),'Interpreter','latex')
				xlabel('$\log(k)$','Interpreter','latex')
				axis square
				% If you want the legend, then uncomment the next line
				%legend(lh.DisplayName)
			end
			
		end
		
		
		function exportParameterEstimates(obj, data)
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
				'RowNames',data.participantFilenames);
			
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
			
			savename = ['parameterEstimates_' data.saveName '.txt'];
			writetable(combinedParameterEstimates, savename,...
				'Delimiter','\t')
			fprintf('The above table of participant and group-level parameter estimates was exported to:\n')
			fprintf('\t%s\n\n',savename)
		end
		
	end
	
	
	
	methods (Access = protected)
		function [obj] = setObservedMonitoredValues(obj, data)
			obj.observed = data.observedData;
			obj.observed.logBInterp = log( logspace(0,5,99) );
			% group-level stuff
			obj.observed.nParticipants	= data.nParticipants;
			obj.observed.totalTrials	= data.totalTrials;
			
			obj.monitorparams = {'epsilon',...
				'alpha',...
				'm',...
				'c',...
				'groupMmu',...
				'groupW',...
				'groupMsigma','groupCsigma',...
				'groupALPHAmu','groupALPHAsigma'....
				'glM', 'glMprior',...
				'glC', 'glCprior',...
				'glEpsilon', 'glEpsilonprior',...
				'glALPHA', 'glALPHAprior',...
				};
		end
		
		function figGroupLevel(obj, data)
			
			figure(99)
			set(gcf,'Name','GROUP LEVEL')
			clf
			
			
			% BIVARIATE PLOT: lapse rate & comparison accuity
			figure(99), subplot(1, 5, 1)
			[structName] = plot2DErrorAccuity(obj.samples.glEpsilon(:),...
				obj.samples.glALPHA(:),...
				obj.range.epsilon,...
				obj.range.alpha);
			lrMODE = structName.modex;
			alphaMODE= structName.modey;
			
			% PSYCHOMETRIC FUNCTION (using my posterior-prediction-plot-matlab GitHub repository)
			figure(99), subplot(1, 5, 2)
			tempsamples.epsilon = obj.samples.glEpsilon;
			tempsamples.alpha = obj.samples.glALPHA;
			plotPsychometricFunc(tempsamples, [lrMODE, alphaMODE])
			clear tempsamples
			
			
			figure(99), subplot(1,5,3)
			[groupLevelMCinfo] = plot2Dmc(obj.samples.glM(:),...
				obj.samples.glC(:), obj.range.m, obj.range.c);
			
			GROUPmodeM = groupLevelMCinfo.modex;
			GROUPmodeC = groupLevelMCinfo.modey;
			
			
			figure(99), subplot(1,5,4)
			tempsamples.m = obj.samples.glM(:);
			tempsamples.c = obj.samples.glC(:);
			plotMagnitudeEffect(tempsamples, [GROUPmodeM, GROUPmodeC])
			
			
			figure(99), subplot(1, 5, 5)
			opts.maxlogB	= max(abs(data.observedData.B(:)));
			opts.maxD		= max(data.observedData.DB(:));
			% PLOT A POINT-ESTIMATE DISCOUNT SURFACE
			plotDiscountSurface(GROUPmodeM, GROUPmodeC, opts);
			%set(gca,'XTick',[10 100])
			%set(gca,'XTickLabel',[10 100])
			%set(gca,'XLim',[10 100])
			% PLOT A DISCOUNT SURFACE WITH UNCERTAINTY
			% calculateDiscountSurfaceUNCERTAINTY(obj.samples.glM(:), obj.samples.glC(:), opts)
			
			
			% EXPORTING ---------------------
			latex_fig(16, 18, 4)
			myExport(data.saveName, obj.modelType, '-GROUP')
			% -------------------------------
			
		end
		
		
		function obj = setInitialParamValues(obj, data)
			for n=1:obj.mcmcparams.nchains
				% Values for which there are just one of
				%obj.initial_param(n).groupW = rand/10; % group mean lapse rate
				
				obj.initial_param(n).groupMmu = normrnd(-0.243,1);
				obj.initial_param(n).groupCmu = normrnd(0,2);
				
				obj.initial_param(n).mprior = normrnd(-0.243,2);
				obj.initial_param(n).cprior = normrnd(0,4);
				
				% One value for each participant
				for p=1:data.nParticipants
					obj.initial_param(n).alpha(p)	= abs(normrnd(0.01,0.001));
					obj.initial_param(n).lr(p)		= rand/10;
					
					obj.initial_param(n).m(p) = normrnd(-0.243,2);
					obj.initial_param(n).c(p) = normrnd(0,4);
				end
			end
		end
		
		
		function obj = doAnalysis(obj)
			% univariate summary stats
			fields ={'epsilon', 'alpha', 'm', 'c', 'glM', 'glC', 'glEpsilon','glALPHA'};
			support={'positive', 'positive', [], [], [], [], 'positive', 'positive'};
			
			uni = univariateAnalysis(obj.samples, fields, support );
			obj.analyses.univariate = uni;
			
			% bivariate summary stats
		end
		
	end
	
	
	methods (Static)
		function [posteriorMode,lh] = calculateLogK_ConditionOnReward(reward, params, plotFlag)
			lh=[];
			% -----------------------------------------------------------
			% log(k) = m * log(B) + c
			% k = exp( m * log(B) + c )
			%fh = @(x,params) exp( params(:,1) * log(x) + params(:,2));
			% a FAST vectorised version of above ------------------------
			fh = @(x,params) exp( bsxfun(@plus, ...
				bsxfun(@times,params(:,1),log(x)),...
				params(:,2)));
			% -----------------------------------------------------------
			
			myplot = PosteriorPredictionPlot(fh, reward, params);
			myplot = myplot.evaluateFunction([]);
			
			% Extract samples of P(k|reward)
			kSamples = myplot.Y;
			logKsamples = log(kSamples);
			
			% Calculate kernel density estimate
			[f,xi] = ksdensity(logKsamples, 'function', 'pdf');
			
			% Calculate posterior mode
			[~, index] = max(f);
			posteriorMode = xi(index);
			
			if plotFlag
				figure(1)
				lh = plot(xi,f);
				hold on
				drawnow
			end
			
		end
	end
	
end

