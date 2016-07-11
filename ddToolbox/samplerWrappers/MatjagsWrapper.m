classdef MatjagsWrapper < SamplerWrapper
	%MatjagsWrapper

	properties
		initialParameters % struct required by matjags
	end

	properties (Access = private)
		% samples % structure returned by matjags
		% stats % structure returned by matjags

	end

	methods (Access = public)

		% CONSTRUCTOR =====================================================
		function obj = MatjagsWrapper(modelFilename)
			obj = obj@SamplerWrapper();

			obj.modelFilename = modelFilename;
			%obj.samplerName = 'JAGS';
			obj.setMCMCparams();
		end
		% =================================================================

		function mcmc = conductInference(obj, model, data)
			%% preparation for MCMC sampling
			model.setInitialParamValues();
			obj.initialParameters = model.initialParams;
			
			
			variables = model.variables;
			nParticipants = data.nParticipants;
			saveFolder = model.saveFolder;
			IDnames = data.IDname;
			
			obj.displayMCMCparamInfo();
		
			assert(obj.mcmcparams.nchains>=2,'Use a minimum of 2 MCMC chains')
			startParallelPool()

			% TODO: rather than ask for this, the model is going to do its
			% model-specific process to go from raw data to observed variables.
			obj.observed = data.observedData;

			obj.monitorparams = model.varList.monitored;

			%% Get our sampler to sample
			% This returns an mcmc container object
			mcmc = obj.invokeSampler();

			speak('sampling complete')

% 			%% Post-sampling activities
% 			mcmc.convergenceSummary(saveFolder,IDnames)
% 			model.exportParameterEstimates();
		end


		function mcmcContainer = invokeSampler(obj)
			fprintf('\nRunning JAGS (%d chains, %d samples each)\n',...
				obj.mcmcparams.nchains,...
				obj.mcmcparams.nsamples);
			[samples, stats] = matjags(...
				obj.observed,...
				obj.modelFilename,...
				obj.initialParameters,...
				'doparallel', obj.mcmcparams.doparallel,...
				'nchains', obj.mcmcparams.nchains,...
				'nburnin', obj.mcmcparams.nburnin,...
				'nsamples', obj.mcmcparams.nsamples,... % nAdapt', 2000,...
				'thin', 1,...
				'monitorparams', obj.monitorparams,...
				'savejagsoutput', 0,...
				'verbosity', 1,...
				'cleanup', 1,...
				'rndseed', 1,...
				'dic', 0);

			% output an mcmcContainer object, made from the samples
			mcmcContainer = JAGSmcmc(samples, stats, obj.mcmcparams);
		end

		%% SET METHODS ----------------------------------------------------
		function setMCMCparams(obj)
			% Default parameters
			obj.mcmcparams.doparallel = 1;
			obj.mcmcparams.nburnin = 5000;
			obj.mcmcparams.nchains = 4;
			obj.setMCMCtotalSamples(10^5); % 10^5 - 10^6 minimum
			obj.mcmcparams.model = obj.modelFilename;
			obj.setMCMCnumberOfChains(4);
			obj.mcmcparams.totalSamples = obj.mcmcparams.nchains * obj.mcmcparams.nsamples;
		end

		function setBurnIn(obj, nburnin)
			obj.mcmcparams.nburnin = nburnin;
			fprintf('Burn in: %d samples\n', obj.mcmcparams.nburnin)
		end

		function setMCMCtotalSamples(obj, totalSamples)
			obj.mcmcparams.nsamples     = totalSamples / obj.mcmcparams.nchains;
			obj.mcmcparams.totalSamples = totalSamples;
			%obj.displayMCMCparamInfo();
		end

		function setMCMCnumberOfChains(obj, nchains)
			obj.mcmcparams.nchains = nchains;
			obj.mcmcparams.nsamples = obj.mcmcparams.totalSamples / obj.mcmcparams.nchains;
			%obj.displayMCMCparamInfo();
		end

		function displayMCMCparamInfo(obj)
			fprintf('Total samples: %d\n', obj.mcmcparams.totalSamples)
			fprintf('%d chains, with %d samples each\n', ...
				obj.mcmcparams.nchains, obj.mcmcparams.nsamples)
		end

	end

end
