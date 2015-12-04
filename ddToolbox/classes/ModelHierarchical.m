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

			% give sampler a handle back to the model (ie this hierarchicalME model)
			obj.sampler.modelHandle = obj;
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

			obj.figGroupLevelPriorPost()
			obj.figGroupLevel()
			obj.figParticipantLevelWrapper()

			MCMCdiagnoticsPlot(obj.sampler.samples, obj.sampler.stats, [],...
				{'glM', 'glC', 'glEpsilon', 'glALPHA', 'm', 'c', 'groupALPHAmu', 'groupALPHAsigma'},...
				{[], [], [0 0.5], 'positive', [], [], [], 'positive'},...
				{'G^m', 'G^c', 'G^{\epsilon}', 'G^{\alpha}', 'm', 'c', '\mu^\alpha', '\sigma^\alpha'},...
				obj.data,...
				obj.modelType);
		end

		function setInitialParamValues(obj)
			% the model is changing sampler information
			for n=1:obj.sampler.mcmcparams.nchains
				obj.sampler.initial_param(n).groupMmu = normrnd(-0.243,1);
				obj.sampler.initial_param(n).groupCmu = normrnd(0,2);
				obj.sampler.initial_param(n).mprior = normrnd(-0.243,2);
				obj.sampler.initial_param(n).cprior = normrnd(0,4);
				for p=1:obj.data.nParticipants
					obj.sampler.initial_param(n).alpha(p) = abs(normrnd(0.01,0.001));
					obj.sampler.initial_param(n).lr(p) = rand/10;
					obj.sampler.initial_param(n).m(p) = normrnd(-0.243,2);
					obj.sampler.initial_param(n).c(p) = normrnd(0,4);
				end
			end
		end

		function setMonitoredValues(obj)
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

		function setObservedValues(obj)
			% the model is changing sampler information
			obj.sampler.observed = obj.data.observedData;
			obj.sampler.observed.nParticipants	= obj.data.nParticipants;
			obj.sampler.observed.totalTrials	= obj.data.totalTrials;
		end

		function doAnalysis(obj) % <--- TODO: REMOVE THIS WRAPPER FUNCTION
			obj.analyses.univariate = univariateAnalysis(obj.sampler.samples,...
				{'epsilon', 'alpha', 'm', 'c', 'glM', 'glC', 'glEpsilon','glALPHA'},...
				{'positive', 'positive', [], [], [], [], 'positive', 'positive'} );
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

		% *********
		% TODO: CAN THIS BE MOVED TO THE BASE CLASS?
		% *********
		function conditionalDiscountRates(obj, reward, plotFlag)
			% For group level and all participants, extract and plot P( log(k) | reward)

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

			if plotFlag % FORMATTING OF FIGURE
				removeYaxis
				title(sprintf('$P(\\log(k)|$reward=$\\pounds$%d$)$', reward),'Interpreter','latex')
				xlabel('$\log(k)$','Interpreter','latex')
				axis square
				%legend(lh.DisplayName)
			end

		end



	end


	methods(Static)

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

		% ******
		% TODO: CAN WE MAKE figParticipant() IN THE BASE CLASS MORE GENERAL SO WE CAN AVOID THE REPETIION OF HAVING THIS FUNCTION?
		function figGroupLevel(obj)

			figure(99)
			set(gcf,'Name','GROUP LEVEL')
			clf


			% BIVARIATE PLOT: lapse rate & comparison accuity
			figure(99), subplot(1, 5, 1)
			[structName] = plot2DErrorAccuity(obj.sampler.samples.glEpsilon(:),...
				obj.sampler.samples.glALPHA(:),...
				obj.range.epsilon,...
				obj.range.alpha);
			lrMODE = structName.modex;
			alphaMODE= structName.modey;

			% PSYCHOMETRIC FUNCTION (using my posterior-prediction-plot-matlab GitHub repository)
			figure(99), subplot(1, 5, 2)
			tempsamples.epsilon = obj.sampler.samples.glEpsilon;
			tempsamples.alpha = obj.sampler.samples.glALPHA;
			plotPsychometricFunc(tempsamples, [lrMODE, alphaMODE])
			clear tempsamples


			figure(99), subplot(1,5,3)
			[groupLevelMCinfo] = plot2Dmc(obj.sampler.samples.glM(:),...
				obj.sampler.samples.glC(:), obj.range.m, obj.range.c);

			GROUPmodeM = groupLevelMCinfo.modex;
			GROUPmodeC = groupLevelMCinfo.modey;


			figure(99), subplot(1,5,4)
			tempsamples.m = obj.sampler.samples.glM(:);
			tempsamples.c = obj.sampler.samples.glC(:);
			plotMagnitudeEffect(tempsamples, [GROUPmodeM, GROUPmodeC])


			figure(99), subplot(1, 5, 5)
			opts.maxlogB	= max(abs(obj.data.observedData.B(:)));
			opts.maxD		= max(obj.data.observedData.DB(:));
			% PLOT A POINT-ESTIMATE DISCOUNT SURFACE
			plotDiscountSurface(GROUPmodeM, GROUPmodeC, opts);
			%set(gca,'XTick',[10 100])
			%set(gca,'XTickLabel',[10 100])
			%set(gca,'XLim',[10 100])

			% EXPORTING ---------------------
			latex_fig(16, 18, 4)
			myExport(obj.data.saveName, obj.modelType, '-GROUP')
			% -------------------------------

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
			posteriorMode = xi( argmax(f) );

			if plotFlag
				figure(1)
				lh = plot(xi,f);
				hold on
				drawnow
			end

		end




	end



	% HYPOTHESIS TEST FUNCTIONS ================================================
	methods (Access = public)
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
	end

end
