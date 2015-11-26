classdef ModelSimple < handle
	%ModelSimple A model to estimate the magnitide effect
	%   Detailed explanation goes here
	
% 	properties (SetAccess = immutable)
% 		% these properties can only be set by the constructor
% 		modelType	% string
% 		JAGSmodel	% string
% 	end
	
	properties (Access = protected)
		modelType	% string
		JAGSmodel	% string
		
		sampler		% string {'JAGS'}
		
		range		% struct

		initial_param	% struct
		mcmcparams		% struct
		observed		% struct
		monitorparams	% struct
	end
	properties (GetAccess = public, SetAccess = protected)
		samples		% struct
		stats		% struct
		analyses	% struct
	end
	
	
	methods (Access = public)
		
		% CONSTRUCTOR =====================================================
		function obj=ModelSimple(toolboxPath)
			obj.JAGSmodel = [toolboxPath '/jagsModels/simpleME.txt'];
			obj.modelType = 'mSimple';
			obj = obj.setSampler('JAGS');
			
			obj = obj.setMCMCparams();
		end
		% =================================================================
		
		function obj=conductInference(obj, data)
			
			switch obj.sampler
				case{'JAGS'}
					% Start parallel pool
					if isempty(gcp('nocreate')), parpool, end
					obj = obj.setInitialParamValues(data);
					obj = obj.setObservedMonitoredValues(data);
					obj = obj.invokeJAGS();
					%obj = obj.calculateTransformedValues();
					
				otherwise
					error('sampler should be JAGS')
			end
			
			obj = doAnalysis(obj);
			
			display('***** CONVERGENCE CHECKS HERE *****')
			obj.convergenceSummary(data)
			
			display('***** SAVE THE MODEL OBJECT HERE *****')
		end
		
		
		function obj = setMCMCtotalSamples(obj, totalSamples)
			%samplesPerChain				= totalSamples / obj.mcmcparams.nchains;
			obj.mcmcparams.nsamples     = totalSamples / obj.mcmcparams.nchains;
			obj.mcmcparams.totalSamples = totalSamples;
			fprintf('Total samples: %d\n', obj.mcmcparams.totalSamples)
			fprintf('%d chains, with %d samples each\n', ...
				obj.mcmcparams.nchains, obj.mcmcparams.nsamples)
		end
		
		
		function obj = setMCMCnumberOfChains(obj, nchains)
			obj.mcmcparams.nchains = nchains;
			obj.mcmcparams.nsamples= obj.mcmcparams.totalSamples / obj.mcmcparams.nchains;
			fprintf('Total samples: %d\n', obj.mcmcparams.totalSamples)
			fprintf('%d chains, with %d samples each\n', ...
				obj.mcmcparams.nchains, obj.mcmcparams.nsamples)
		end
		
		function obj = setBurnIn(obj, nburnin)
			obj.mcmcparams.nburnin = nburnin;
			fprintf('Burn in: %d samples\n', obj.mcmcparams.nburnin)
		end
		
		
		
		function obj = setSampler(obj, sampler)
			switch sampler
				case{'JAGS'}
					obj.sampler	  = 'JAGS';
				otherwise
					error('wrong')
			end
			fprintf('MCMC sampling software now set as: %s\n',obj.sampler)
		end
		
		function plot(obj,data)
			close all
			% Define limits for each of the variables here for plotting
			% purposes
			obj.range.lr=[0 min([prctile(obj.samples.lr(:),[99]) , 0.5])];
			%obj.range.alpha=[0 max(obj.samples.alpha(:))];
			obj.range.alpha=[0 prctile(obj.samples.alpha(:),[99])];
			% ranges for m and c to contain ALL samples.
			%obj.range.m=[min(obj.samples.m(:)) max(obj.samples.m(:))];
			%obj.range.c=[min(obj.samples.c(:)) max(obj.samples.c(:))];
			% zoom to contain virtually all samples.
			obj.range.m=prctile(obj.samples.m(:),[0.1 100-0.1]);
			obj.range.c=prctile(obj.samples.c(:),[0.1 100-0.1]);
			
			obj.figParticipant(obj.samples, data.observedData)
			
			
			% *** EXPORT FIGURE HERE ***
		end
		
		
		function convergenceSummary(obj, data)
			% save to a text file
			fid=fopen(['convergenceReport.txt'],'w');
			warningFlag = false;
			% get fields that we have Rhat statistic for
			names = fieldnames(obj.stats.Rhat);
			% loop over fields and report for either single values or
			% multiple values (eg when we have multiple participants)
			for n=1:numel(names)
				RhatValues = obj.stats.Rhat.(names{n});
				fprintf(fid,'\nRhat for: %s.\n',names{n})
				for i=1:numel(RhatValues)
					if numel(RhatValues)>1
						fprintf('%s\t', data.IDname{i})
					end
					fprintf(fid,'%2.5f\t', RhatValues(i))
					if RhatValues(i)>1.001
						warningFlag = true;
						fprintf(fid,'WARNING: poor convergence')
					end
					fprintf(fid,'\n')
				end
			end
			if warningFlag 
				fprintf(fid,'\n\n\n**** WARNING: convergence issues ****\n\n\n')
				beep
			end
			fclose(fid);
		end

	end
	
	
	methods (Access = protected)
		function obj = setMCMCparams(obj)
			% define mcmc parameters
			obj.mcmcparams.doparallel 	= 1;
			obj.mcmcparams.nchains  	= 2;
			obj.mcmcparams.nburnin      = 1000;
			obj.mcmcparams.nsamples     = 100000; % 100,000 min for GOOD results
			obj.mcmcparams.model        = obj.JAGSmodel;
			obj.mcmcparams.totalSamples = obj.mcmcparams.nchains * obj.mcmcparams.nsamples;
		end
		
		function obj = setInitialParamValues(obj, data)
			% define intial parameter guesses
			for n=1:obj.mcmcparams.nchains
				obj.initial_param(n).lr		= abs(normrnd(0.01,0.001));
			end
		end
		
		function [obj] = setObservedMonitoredValues(obj, data)
			% OBSERVED PARAMETERS
			obj.observed = data.observedData;
			obj.observed.logBInterp = log( logspace(0,5,99) );
			
			% MONITOR THESE PARAMETERS
			obj.monitorparams = {'lr',...
				'alpha',...
				'm',...
				'c'};
		end
		
		function obj = invokeJAGS(obj)
			fprintf('\nRunning JAGS (%d chains, %d samples each)\n',...
				obj.mcmcparams.nchains,...
				obj.mcmcparams.nsamples);
			[obj.samples, obj.stats] = matjags( ...
				obj.observed, ...
				obj.mcmcparams.model, ...
				obj.initial_param, ...
				'doparallel' , obj.mcmcparams.doparallel, ...
				'nchains', obj.mcmcparams.nchains,...
				'nburnin', obj.mcmcparams.nburnin,...
				'nsamples', obj.mcmcparams.nsamples, ...
				'thin', 1, ...
				'monitorparams', obj.monitorparams, ...
				'savejagsoutput' , 0 , ...
				'verbosity' , 1 , ...
				'cleanup' , 1 ,...
				'rndseed', 1,...
				'dic',0);
		end
		
		
		function figParticipant(obj, samples, data)
			rows=1; cols=5;
			
			% BIVARIATE PLOT: lapse rate & comparison accuity
			subplot(rows, cols, 1)
			[structName] = plot2DErrorAccuity(samples.epsilon(:),...
				samples.alpha(:),...
				obj.range.epsilon,...
				obj.range.alpha);
			lrMODE = structName.modex;
			alphaMODE= structName.modey;
			
			% PSYCHOMETRIC FUNCTION (using my posterior-prediction-plot-matlab GitHub repository)
			subplot(rows, cols, 2)
			plotPsychometricFunc(samples, [lrMODE, alphaMODE])
			
			% M/C bivariate plot
			subplot(rows, cols, 3)
			[structName] = plot2Dmc(samples.m(:), samples.c(:),...
				obj.range.m, obj.range.c);
			modeM = structName.modex;
			modeC = structName.modey;
			
			% PLOT magnitude effect
			subplot(rows, cols, 4)
			plotMagnitudeEffect(samples, [modeM, modeC])
			
			% Plot in 3D data space
			subplot(rows, cols, 5)
			plot3DdataSpace(data, [modeM, modeC])
% 			set(gca,'XTick',[10 100])
% 			set(gca,'XTickLabel',[10 100])
% 			set(gca,'XLim',[10 100])
		end
		
		
		function samplePlots(obj)
			clf
			subplot(1,2,1)
			h=scatter( obj.samples.m(:), obj.samples.c(:), 4, 'filled', 'k');
			xlabel('m')
			ylabel('c')
			
			hold on
			scatter( median(obj.samples.m(:)),...
				median(obj.samples.c(:)),...
				'r','filled')
			
			subplot(1,2,2)
			scatter( obj.samples.lr(:), obj.samples.alpha(:), 4, 'filled', 'k');
			xlabel('lr')
			ylabel('alpha')
			drawnow
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
			forestPlot(xlabels, [uni.groupMmu.mode uni.m.mode],...
				[uni.groupMmu.CI95 uni.m.CI95],...
				'm')
			
			subplot(4,1,2)
			forestPlot(xlabels, [uni.groupCmu.mode uni.c.mode],...
				[uni.groupCmu.CI95 uni.c.CI95],...
				'c')
			
			subplot(4,1,3)
			forestPlot(xlabels, [uni.groupW.mode uni.lr.mode],...
				[uni.groupW.CI95 uni.lr.CI95], '\lambda')
			%xlim([-1 N+1])
			
			subplot(4,1,4)
			forestPlot(1:N, uni.alpha.mode, uni.alpha.CI95, '\alpha')
			xlim([-1 N+1])
		end
		
		
		function obj = doAnalysis(obj)
			% univariate summary stats
			fields ={'lr', 'alpha', 'm', 'c'};
			support={'positive', 'positive', [], []};
			% Do the analysis
			uni = univariateAnalysis(obj.samples, fields, support );
			% Store the results
			obj.analyses.univariate = uni;
		end
		
	end
	
end
