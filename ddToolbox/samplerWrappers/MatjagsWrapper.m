classdef MatjagsWrapper < SamplerWrapper
	%MatjagsWrapper

	properties
		initialParameters % struct required by matjags
	end

	methods (Access = public)

		function obj = MatjagsWrapper(modelFilename)
			obj = obj@SamplerWrapper();
			obj.modelFilename = modelFilename;
			obj = obj.setDefaultMCMCparams();
		end


		function mcmcFitObject = conductInference(obj, model)

			%% sampler-specific preparation
			obj.initialParameters = model.setInitialParamValues();
			obj.observed = model.observedData;
			obj.monitorparams = model.varList.monitored;
            startParallelPool()

			%% Get our sampler to sample
			fprintf('\nRunning JAGS (%d chains, %d samples each)\n',...
				obj.mcmcparams.nchains,...
				obj.samplesPerChain());
			[samples, stats] = matjags(...
				obj.observed,...
				obj.modelFilename,...
				obj.initialParameters,...
				'doparallel', obj.mcmcparams.doparallel,...
				'nchains', obj.mcmcparams.nchains,...
				'nburnin', obj.mcmcparams.nburnin,...
				'nsamples', obj.samplesPerChain(),... % nAdapt', 2000,...
				'thin', 1,...
				'monitorparams', obj.monitorparams,...
				'savejagsoutput', 0,...
				'verbosity', 1,...
				'cleanup', 1,...
				'rndseed', 1,...
				'dic', 0);

			% Create an MCMC object. This is basically a wrapper around the
			% outputs of MatJAGS which has useful getter functions.
			mcmcFitObject = JAGSmcmc(samples, stats, obj.mcmcparams);

			% Uncomment this line if you want auditory feedback
			%speak('sampling complete')
		end

		%% SET METHODS ----------------------------------------------------
		function obj = setDefaultMCMCparams(obj)
			obj.mcmcparams.doparallel	= 1;
			obj.mcmcparams.nburnin		= 5000;
			obj.mcmcparams.nchains		= 2;
			obj.mcmcparams.nsamples		= 10^4; % represents TOTAL number of samples we want
		end

	end

end
