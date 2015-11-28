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
			[~,obj.modelType,~] = fileparts(obj.JAGSmodel);
			obj = obj.setSampler('JAGS');
			
			obj = obj.setMCMCparams();
		end
		% =================================================================
		
		function obj=conductInference(obj, data)
			
			switch obj.sampler
				case{'JAGS'}
					assert(obj.mcmcparams.nchains>=2,'Use a minimum of 2 MCMC chains')
					if isempty(gcp('nocreate')), parpool, end % Start parallel pool
					obj = obj.setInitialParamValues(data);
					obj = obj.setObservedMonitoredValues(data);
					obj = obj.invokeJAGS();
					%obj = obj.calculateTransformedValues();
					
				otherwise
					error('sampler should be JAGS')
			end
			obj.calcSampleRange()
			obj.doAnalysis()
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
			obj.calcSampleRange()
			obj.figParticipant(obj.samples, data.observedData)
			% *** EXPORT FIGURE HERE ***
		end


		function calcSampleRange(obj)
			% Define limits for each of the variables here for plotting purposes
			obj.range.epsilon=[0 min([prctile(obj.samples.epsilon(:),[99]), 0.5])];
			obj.range.alpha=[0 prctile(obj.samples.alpha(:), [99])];
			obj.range.m=prctile(obj.samples.m(:), [0.5 99.5]);
			obj.range.c=prctile(obj.samples.c(:), [1 99]);
		end
		
		
		function convergenceSummary(obj, data)
			% save to a text file
			if ~exist(fullfile('figs',data.saveName),'dir')
				mkdir(fullfile('figs',data.saveName))
			end
			fname = fullfile('figs',data.saveName,['ConvergenceReport.txt']);
			fid=fopen(fname,'w');
			% MCMC parameter report
			logInfo(fid, 'MCMC inference was conducted with %d chains. ', obj.mcmcparams.nchains)
			%fprintf(fid,'MCMC inference was conducted with %d chains. ', obj.mcmcparams.nchains )
			logInfo(fid,'The first %d samples were discarded from each chain, ', obj.mcmcparams.nburnin )
			logInfo(fid,'resulting in a total of %d samples to approximate the posterior distribution. ', obj.mcmcparams.totalSamples )
			logInfo(fid,'\n\n\n');
			warningFlag = false;
			% get fields that we have Rhat statistic for
			names = fieldnames(obj.stats.Rhat);
			% loop over fields and report for either single values or
			% multiple values (eg when we have multiple participants)
			for n=1:numel(names)
				RhatValues = obj.stats.Rhat.(names{n});
				logInfo(fid,'\nRhat for: %s.\n',names{n});
				for i=1:numel(RhatValues)
					if numel(RhatValues)>1
						logInfo(fid,'%s\t', data.IDname{i});
					end
					logInfo(fid,'%2.5f\t', RhatValues(i));
					if RhatValues(i)>1.001
						warningFlag = true;
						logInfo(fid,'WARNING: poor convergence');
					end
					logInfo(fid,'\n');
				end
			end
			if warningFlag 
				logInfo(fid,'\n\n\n**** WARNING: convergence issues ****\n\n\n')
				beep
			end
			fclose(fid);
			fprintf('Convergence report saved in:\n\t%s\n\n',fname)
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