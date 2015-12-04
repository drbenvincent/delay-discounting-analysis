classdef ModelBaseClass < handle
	%ModelBaseClass Base class to provide basic functionality
	%	xxxx

	properties (Access = public)
		modelType % string
		data % handle to Data class
		sampler % handle to Sampler class
		range % struct
		monitorparams
	end

	properties (Access = protected)
		% inputs into `matjags` *** TODO These could all exist within a single `matjags` object? ***
		%observed % struct
		%JAGSmodel % string
		%initial_param % struct
		%mcmcparams % struct
		 % struct
	end
	properties (GetAccess = public, SetAccess = protected)
		%samples, stats % structures returned by `matjags`
		analyses % struct
	end


	methods(Abstract, Access = public)
		plot(obj, data)
		doAnalysis(obj) % <--- TODO: REMOVE THIS WRAPPER FUNCTION
		setMonitoredValues(obj, data)
		setObservedValues(obj, data)
		setInitialParamValues(obj, data)
	end

	methods (Access = public)

		% CONSTRUCTOR =====================================================
		function obj = ModelBaseClass(toolboxPath, sampler, data)
			obj.data = data;
			% switch sampler
			% 	case{'JAGS'}
			% 		obj.sampler = JAGSSampler([toolboxPath '/jagsModels/seperateME.txt'])
			% 	case{'STAN'}
			% 		error('NOT IMPLEMENTED YET')
			% end
			%obj.JAGSmodel = [toolboxPath '/jagsModels/seperateME.txt'];
			%[~,obj.modelType,~] = fileparts(obj.JAGSmodel);
			%obj.setSampler('JAGS');
			%obj.setMCMCparams();
		end
		% =================================================================

		function conductInference(obj)
			obj.sampler.conductInference()
		end

		% function conductInference(obj, data)
		% 	switch obj.sampler
		% 		case{'JAGS'}
		% 			assert(obj.mcmcparams.nchains>=2,'Use a minimum of 2 MCMC chains')
		% 			if isempty(gcp('nocreate')), parpool, end % Start parallel pool
		% 			obj.setInitialParamValues(data);
		% 			obj.setMonitoredValues(data);
		% 			obj.setObservedValues(data);
		% 			obj.invokeJAGS();
		% 		otherwise
		% 			error('sampler should be JAGS')
		% 	end
		% 	obj.calcSampleRange()
		% 	obj.doAnalysis()
		% 	obj.convergenceSummary(data)
		% 	display('***** SAVE THE MODEL OBJECT HERE *****')
		% end


		% function setMCMCtotalSamples(obj, totalSamples)
		% 	%samplesPerChain				= totalSamples / obj.mcmcparams.nchains;
		% 	obj.mcmcparams.nsamples     = totalSamples / obj.mcmcparams.nchains;
		% 	obj.mcmcparams.totalSamples = totalSamples;
		% 	fprintf('Total samples: %d\n', obj.mcmcparams.totalSamples)
		% 	fprintf('%d chains, with %d samples each\n', ...
		% 		obj.mcmcparams.nchains, obj.mcmcparams.nsamples)
		% end


		% function setMCMCnumberOfChains(obj, nchains)
		% 	obj.mcmcparams.nchains = nchains;
		% 	obj.mcmcparams.nsamples = obj.mcmcparams.totalSamples / obj.mcmcparams.nchains;
		% 	fprintf('Total samples: %d\n', obj.mcmcparams.totalSamples)
		% 	fprintf('%d chains, with %d samples each\n', ...
		% 		obj.mcmcparams.nchains, obj.mcmcparams.nsamples)
		% end


		% function setBurnIn(obj, nburnin)
		% 	obj.mcmcparams.nburnin = nburnin;
		% 	fprintf('Burn in: %d samples\n', obj.mcmcparams.nburnin)
		% end


		% function setSampler(obj, sampler)
		% 	switch sampler
		% 		case{'JAGS'}
		% 			obj.sampler	  = 'JAGS';
		% 		otherwise
		% 			error('currently, sampler must be ''JAGS''')
		% 	end
		% 	fprintf('MCMC sampling software now set as: %s\n',obj.sampler)
		% end


		function calcSampleRange(obj)
			% Define limits for each of the variables here for plotting purposes
			obj.range.epsilon = [0 0.5]; % show full range
			obj.range.alpha = [0 prctile(obj.sampler.samples.alpha(:), [99])];
			obj.range.m = prctile(obj.sampler.samples.m(:), [0.5 99.5]);
			obj.range.c = prctile(obj.sampler.samples.c(:), [1 99]);
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

		% **************************************************************************************************
		% TODO: THIS FUNCTION CAN BE GENERALISED TO LOOP OVER WHATEVER FIELDS ARE IN obj.analyses.univariate
		% **************************************************************************************************
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
				'RowNames', obj.data.participantFilenames)

			savename = ['parameterEstimates_' obj.data.saveName '.txt'];
			writetable(participant_level, savename,...
				'Delimiter','\t')
			fprintf('The above table of participant-level parameter estimates was exported to:\n')
			fprintf('\t%s\n\n',savename)
		end

	end


	methods (Access = protected)
		% function setMCMCparams(obj)
		% 	obj.mcmcparams.doparallel 	= 1;
		% 	obj.mcmcparams.nchains  	= 2;
		% 	obj.mcmcparams.nburnin      = 1000;
		% 	obj.mcmcparams.nsamples     = 10^5; % 10^5 - 10^6 min for GOOD results
		% 	obj.mcmcparams.model        = obj.JAGSmodel;
		% 	obj.mcmcparams.totalSamples = obj.mcmcparams.nchains * obj.mcmcparams.nsamples;
		% end


		% function invokeJAGS(obj)
		% 	fprintf('\nRunning JAGS (%d chains, %d samples each)\n',...
		% 		obj.mcmcparams.nchains,...
		% 		obj.mcmcparams.nsamples);
		% 	[obj.samples, obj.stats] = matjags( ...
		% 		obj.observed, ...
		% 		obj.JAGSmodel,... %obj.mcmcparams.model, ...
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


		function figParticipantLevelWrapper(obj)
			% PLOT INDIVIDUAL LEVEL STUFF HERE ----------
			for n = 1:obj.data.nParticipants
				fh = figure;
				fh.Name=['participant: ' obj.data.IDname{n}];

				% get samples and data for this participant
				[pSamples] = obj.sampler.getParticipantSamples(n, {'m','c','alpha','epsilon'});
				[pData] = obj.data.getParticipantData(n);

				% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				obj.figParticipant(pSamples, pData)
				% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				latex_fig(16, 18, 4)
				myExport(obj.data.saveName, obj.modelType, ['-' obj.data.IDname{n}])

				% close the figure to keep everything tidy
				close(fh)
			end
		end


		function figParticipant(obj, pSamples, pData)
			rows=1; cols=5;

			% BIVARIATE PLOT: lapse rate & comparison accuity
			subplot(rows, cols, 1)
			[structName] = plot2DErrorAccuity(pSamples.epsilon(:),...
				pSamples.alpha(:),...
				obj.range.epsilon,...
				obj.range.alpha);
			lrMODE = structName.modex;
			alphaMODE= structName.modey;

			% PSYCHOMETRIC FUNCTION (using my posterior-prediction-plot-matlab GitHub repository)
			subplot(rows, cols, 2)
			plotPsychometricFunc(pSamples, [lrMODE, alphaMODE])

			% M/C bivariate plot
			subplot(rows, cols, 3)
			[structName] = plot2Dmc(pSamples.m(:), pSamples.c(:),...
				obj.range.m, obj.range.c);
			modeM = structName.modex;
			modeC = structName.modey;

			% PLOT magnitude effect
			subplot(rows, cols, 4)
			plotMagnitudeEffect(pSamples, [modeM, modeC])

			% Plot in 3D data space
			subplot(rows, cols, 5)
			plot3DdataSpace(pData, [modeM, modeC])
% 			set(gca,'XTick',[10 100])
% 			set(gca,'XTickLabel',[10 100])
% 			set(gca,'XLim',[10 100])
		end


		% function [samples] = getParticipantSamples(obj,participant)
		% 	fieldsToGet={'m','c','alpha','epsilon'};
		% 	for n=1:numel(fieldsToGet)
		% 		temp = obj.samples.(fieldsToGet{n});
		% 		samples.(fieldsToGet{n}) = vec(temp(:,:,participant));
		% 	end
		% end

	end


end
