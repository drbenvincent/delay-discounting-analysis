classdef ModelSeperate < ModelBaseClass
	%ModelSeperate A model to estimate the magnitide effect. 
	%	Models a number of participants, but they are all treated as independent. 
	%	There is no group-level estimation.
	
	properties (Access = protected)
	end
	
	
	methods (Access = public)
		
		% CONSTRUCTOR =====================================================
		function obj=ModelSeperate(toolboxPath)
			% Because this class is a subclass of "ModelBaseClass" then we use
			% this next line to create an instance
			obj = obj@ModelBaseClass(toolboxPath);

			obj.JAGSmodel = [toolboxPath '/jagsModels/seperateME.txt'];
			[~,obj.modelType,~] = fileparts(obj.JAGSmodel);
			%obj = obj.setSampler('JAGS');
			%obj = obj.setMCMCparams();
		end
		% =================================================================
		
		% function obj=conductInference(obj, data)
			
		% 	switch obj.sampler
		% 		case{'JAGS'}
		% 			assert(obj.mcmcparams.nchains>=2,'Use a minimum of 2 MCMC chains')
		% 			if isempty(gcp('nocreate')), parpool, end % Start parallel pool
		% 			obj = obj.setInitialParamValues(data);
		% 			obj = obj.setObservedMonitoredValues(data);
		% 			obj = obj.invokeJAGS();
		% 			%obj = obj.calculateTransformedValues();
					
		% 		otherwise
		% 			error('sampler should be JAGS')
		% 	end
		% 	obj.calcSampleRange()
		% 	obj.doAnalysis()
		% 	obj.convergenceSummary(data)
		% 	display('***** SAVE THE MODEL OBJECT HERE *****')
		% end
		
		
		% function obj = setMCMCtotalSamples(obj, totalSamples)
		% 	%samplesPerChain				= totalSamples / obj.mcmcparams.nchains;
		% 	obj.mcmcparams.nsamples     = totalSamples / obj.mcmcparams.nchains;
		% 	obj.mcmcparams.totalSamples = totalSamples;
		% 	fprintf('Total samples: %d\n', obj.mcmcparams.totalSamples)
		% 	fprintf('%d chains, with %d samples each\n', ...
		% 		obj.mcmcparams.nchains, obj.mcmcparams.nsamples)
		% end
		
		
		% function obj = setMCMCnumberOfChains(obj, nchains)
		% 	obj.mcmcparams.nchains = nchains;
		% 	obj.mcmcparams.nsamples= obj.mcmcparams.totalSamples / obj.mcmcparams.nchains;
		% 	fprintf('Total samples: %d\n', obj.mcmcparams.totalSamples)
		% 	fprintf('%d chains, with %d samples each\n', ...
		% 		obj.mcmcparams.nchains, obj.mcmcparams.nsamples)
		% end
		

		% function obj = setBurnIn(obj, nburnin)
		% 	obj.mcmcparams.nburnin = nburnin;
		% 	fprintf('Burn in: %d samples\n', obj.mcmcparams.nburnin)
		% end
		
		
		% function obj = setSampler(obj, sampler)
		% 	switch sampler
		% 		case{'JAGS'}
		% 			obj.sampler	  = 'JAGS';
		% 		otherwise
		% 			error('wrong')
		% 	end
		% 	fprintf('MCMC sampling software now set as: %s\n',obj.sampler)
		% end
		

		function plot(obj, data)
			close all
			% plot univariate summary statistics for the parameters we have
			% made inferences about
			obj.figUnivariateSummary(obj.analyses.univariate, data.IDname)
			%stackedForestPlot(obj.analyses.univariate)
			% EXPORTING ---------------------
			latex_fig(16, 5, 5)
			myExport(data.saveName, obj.modelType, '-UnivariateSummary')
			% -------------------------------
			
			obj.figParticipantLevelWRAPPER(data)
			obj.MCMCdiagnostics(data)
		end


		function calcSampleRange(obj)
			% Define limits for each of the variables here for plotting purposes
			%obj.range.epsilon=[0 min([prctile(obj.samples.epsilon(:),[99]), 0.5])];
			obj.range.epsilon=[0 0.5]; % show full range
			obj.range.alpha=[0 prctile(obj.samples.alpha(:), [99])];
			obj.range.m=prctile(obj.samples.m(:), [0.5 99.5]);
			obj.range.c=prctile(obj.samples.c(:), [1 99]);
		end


		function MCMCdiagnostics(obj, data)
			% Choose what to plot ---------------
			variablesToPlot = {'epsilon', 'alpha', 'm', 'c'};
			supp			= {[0 0.5], 'positive', [], []};
			paramString		= {'\epsilon', '\alpha', 'm', 'c'};
			
			true=[];
			
			% PLOT -------------------
			MCMCdiagnoticsPlot(obj.samples, obj.stats,...
				true,...
				variablesToPlot, supp, paramString, data,...
				obj.modelType);
		end
		
		
		% function convergenceSummary(obj, data)
		% 	% save to a text file
		% 	if ~exist(fullfile('figs',data.saveName),'dir')
		% 		mkdir(fullfile('figs',data.saveName))
		% 	end
		% 	fname = fullfile('figs',data.saveName,['ConvergenceReport.txt']);
		% 	fid=fopen(fname,'w');
		% 	% MCMC parameter report
		% 	logInfo(fid, 'MCMC inference was conducted with %d chains. ', obj.mcmcparams.nchains)
		% 	%fprintf(fid,'MCMC inference was conducted with %d chains. ', obj.mcmcparams.nchains )
		% 	logInfo(fid,'The first %d samples were discarded from each chain, ', obj.mcmcparams.nburnin )
		% 	logInfo(fid,'resulting in a total of %d samples to approximate the posterior distribution. ', obj.mcmcparams.totalSamples )
		% 	logInfo(fid,'\n\n\n');
		% 	warningFlag = false;
		% 	% get fields that we have Rhat statistic for
		% 	names = fieldnames(obj.stats.Rhat);
		% 	% loop over fields and report for either single values or
		% 	% multiple values (eg when we have multiple participants)
		% 	for n=1:numel(names)
		% 		RhatValues = obj.stats.Rhat.(names{n});
		% 		logInfo(fid,'\nRhat for: %s.\n',names{n});
		% 		for i=1:numel(RhatValues)
		% 			if numel(RhatValues)>1
		% 				logInfo(fid,'%s\t', data.IDname{i});
		% 			end
		% 			logInfo(fid,'%2.5f\t', RhatValues(i));
		% 			if RhatValues(i)>1.001
		% 				warningFlag = true;
		% 				logInfo(fid,'WARNING: poor convergence');
		% 			end
		% 			logInfo(fid,'\n');
		% 		end
		% 	end
		% 	if warningFlag 
		% 		logInfo(fid,'\n\n\n**** WARNING: convergence issues ****\n\n\n')
		% 		beep
		% 	end
		% 	fclose(fid);
		% 	fprintf('Convergence report saved in:\n\t%s\n\n',fname)
		% end


		% function exportParameterEstimates(obj, data)
		% 	participant_level = array2table(...
		% 		[obj.analyses.univariate.m.mode'...
		% 		obj.analyses.univariate.m.CI95'...
		% 		obj.analyses.univariate.c.mode'...
		% 		obj.analyses.univariate.c.CI95'...
		% 		obj.analyses.univariate.alpha.mode'...
		% 		obj.analyses.univariate.alpha.CI95'...
		% 		obj.analyses.univariate.epsilon.mode'...
		% 		obj.analyses.univariate.epsilon.CI95'],...
		% 		'VariableNames',{'m_mode' 'm_CI5' 'm_CI95'...
		% 		'c_mode' 'c_CI5' 'c_CI95'...
		% 		'alpha_mode' 'alpha_CI5' 'alpha_CI95'...
		% 		'epsilon_mode' 'epsilon_CI5' 'epsilon_CI95'},...
		% 		'RowNames',data.participantFilenames)
			
		% 	savename = ['parameterEstimates_' data.saveName '.txt'];
		% 	writetable(participant_level, savename,...
		% 		'Delimiter','\t')
		% 	fprintf('The above table of participant-level parameter estimates was exported to:\n')
		% 	fprintf('\t%s\n\n',savename)
		% end

	end
	
	
	methods (Access = protected)
		% function obj = setMCMCparams(obj)
		% 	% define mcmc parameters
		% 	obj.mcmcparams.doparallel 	= 1;
		% 	obj.mcmcparams.nchains  	= 2;
		% 	obj.mcmcparams.nburnin      = 1000;
		% 	obj.mcmcparams.nsamples     = 100000; % 100,000 min for GOOD results
		% 	obj.mcmcparams.model        = obj.JAGSmodel;
		% 	obj.mcmcparams.totalSamples = obj.mcmcparams.nchains * obj.mcmcparams.nsamples;
		% end
		
		function obj = setInitialParamValues(obj, data)
			for n=1:obj.mcmcparams.nchains
				% Values for which there are just one of
				%obj.initial_param(n).groupW = rand/10; % group mean lapse rate
				
				%obj.initial_param(n).mprior = normrnd(-0.243,1);
				%obj.initial_param(n).cprior = normrnd(0,4);
				
				% One value for each participant
				for p=1:data.nParticipants
					obj.initial_param(n).alpha(p)	= abs(normrnd(0.01,0.01));
					obj.initial_param(n).lr(p)		= rand/10;
					
					obj.initial_param(n).m(p) = normrnd(-0.243,1);
					obj.initial_param(n).c(p) = normrnd(0,4);
				end
			end
		end
		
		function [obj] = setObservedMonitoredValues(obj, data)
			obj.observed = data.observedData;
			obj.observed.logBInterp = log( logspace(0,5,99) );
			% group-level stuff
			obj.observed.nParticipants	= data.nParticipants;
			obj.observed.totalTrials	= data.totalTrials;
			
			obj.monitorparams = {'epsilon','epsilonprior',...
				'alpha','alphaprior',...
				'm','mprior',...
				'c','cprior'};%'participantlogk'};
		end
		
		% function obj = invokeJAGS(obj)
		% 	fprintf('\nRunning JAGS (%d chains, %d samples each)\n',...
		% 		obj.mcmcparams.nchains,...
		% 		obj.mcmcparams.nsamples);
		% 	[obj.samples, obj.stats] = matjags( ...
		% 		obj.observed, ...
		% 		obj.mcmcparams.model, ...
		% 		obj.initial_param, ...
		% 		'doparallel' , obj.mcmcparams.doparallel, ...
		% 		'nchains', obj.mcmcparams.nchains,...
		% 		'nburnin', obj.mcmcparams.nburnin,...
		% 		'nsamples', obj.mcmcparams.nsamples, ...
		% 		'thin', 1, ...
		% 		'monitorparams', obj.monitorparams, ...
		% 		'savejagsoutput' , 0 , ...
		% 		'verbosity' , 1 , ...
		% 		'cleanup' , 1 ,...
		% 		'rndseed', 1,...
		% 		'dic',0);
		% end
		

		% function figParticipantLevelWRAPPER(obj, data)
		% 	% PLOT INDIVIDUAL LEVEL STUFF HERE ----------
		% 	for n=1:data.nParticipants
		% 		fh = figure;
		% 		fh.Name=['participant: ' data.IDname{n}];
				
		% 		% get samples and data for this participant
		% 		[samples] = obj.getParticipantSamples(n);
		% 		[pData] = data.getParticipantData(n);
				
		% 		% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		% 		obj.figParticipant(samples, pData)
		% 		% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				
		% 		% EXPORTING ---------------------
		% 		latex_fig(16, 18, 4)
		% 		myExport(data.saveName, obj.modelType, ['-' data.IDname{n}])
		% 		% -------------------------------
				
		% 		% close the figure to keep everything tidy
		% 		close(fh)
		% 	end
		% end

		
% 		function figParticipant(obj, samples, data)
% 			rows=1; cols=5;
			
% 			% BIVARIATE PLOT: lapse rate & comparison accuity
% 			subplot(rows, cols, 1)
% 			[structName] = plot2DErrorAccuity(samples.epsilon(:),...
% 				samples.alpha(:),...
% 				obj.range.epsilon,...
% 				obj.range.alpha);
% 			lrMODE = structName.modex;
% 			alphaMODE= structName.modey;
			
% 			% PSYCHOMETRIC FUNCTION (using my posterior-prediction-plot-matlab GitHub repository)
% 			subplot(rows, cols, 2)
% 			plotPsychometricFunc(samples, [lrMODE, alphaMODE])
			
% 			% M/C bivariate plot
% 			subplot(rows, cols, 3)
% 			[structName] = plot2Dmc(samples.m(:), samples.c(:),...
% 				obj.range.m, obj.range.c);
% 			modeM = structName.modex;
% 			modeC = structName.modey;
			
% 			% PLOT magnitude effect
% 			subplot(rows, cols, 4)
% 			plotMagnitudeEffect(samples, [modeM, modeC])
			
% 			% Plot in 3D data space
% 			subplot(rows, cols, 5)
% 			plot3DdataSpace(data, [modeM, modeC])
% % 			set(gca,'XTick',[10 100])
% % 			set(gca,'XTickLabel',[10 100])
% % 			set(gca,'XLim',[10 100])
% 		end

		
		% function [samples] = getParticipantSamples(obj,participant)
		% 	% grabs samples just from one participant.
		% 	% For the purposes of plotting data for 1 participant
			
		% 	% 			names = fieldnames(obj.samples);
		% 	% 			for n=1:numel(names)
		% 	% 				if size(obj.samples.(names{n}),3)>1
		% 	% 					temp = obj.samples.(names{n});
		% 	% 					temp = temp(:,:,participant);
		% 	% 					samples.(names{n}) = temp;
		% 	% 				end
		% 	% 			end
			
		% 	fieldsToGet={'m','c','alpha','epsilon'};
		% 	for n=1:numel(fieldsToGet)
		% 		temp = obj.samples.(fieldsToGet{n});
		% 		samples.(fieldsToGet{n}) = vec(temp(:,:,participant));
		% 	end
			
		% end

		

		function obj = doAnalysis(obj)
			% univariate summary stats
			fields ={'epsilon', 'alpha', 'm', 'c'};
			support={'positive', 'positive', [], []};
			% Do the analysis
			uni = univariateAnalysis(obj.samples, fields, support );
			% Store the results
			obj.analyses.univariate = uni;
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