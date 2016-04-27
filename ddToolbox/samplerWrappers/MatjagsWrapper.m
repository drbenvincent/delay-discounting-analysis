classdef MatjagsWrapper < SamplerWrapper
	%MatjagsWrapper

	properties (GetAccess = public, SetAccess = private)

	end

	properties (Access = private)
		% samples % structure returned by matjags
		% stats % structure returned by matjags
		initialParameters % struct required by matjags
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

		function setObservedValues(obj, data)
			obj.observed = data.observedData;
			obj.observed.nParticipants	= data.nParticipants;
			%obj.observed.totalTrials	= data.totalTrials;
		end

		function mcmc = conductInference(obj, model, data)
			variables = model.variables;
			%varsToMonitor = model.varList.monitored;
			nParticipants = data.nParticipants;
			saveFolder = model.saveFolder;
			IDnames = data.IDname;

			assert(obj.mcmcparams.nchains>=2,'Use a minimum of 2 MCMC chains')
			startParallelPool()
			obj.setObservedValues(data);
			obj.setInitialParamValues(variables, nParticipants);
			%obj.setMonitoredValues(varsToMonitor);
			obj.monitorparams = model.varList.monitored;
			mcmc = obj.invokeSampler();
			speak('sampling complete')

			mcmc.convergenceSummary(saveFolder,IDnames)
		end

		function setInitialParamValues(obj, variables, nParticipants)
			for chain=1:obj.mcmcparams.nchains
				for varName = each(fieldnames(variables))
					if isempty(variables.(varName).seed), continue, end

					% TODO: fix this. Why can't I call the seed func handle directly?
					seedFunc = variables.(varName).seed();

					if variables.(varName).single==false

						% participant level
						for p=1:nParticipants
							obj.initialParameters(chain).(varName)(p) = seedFunc();
						end
					else
						% non-participant level
						obj.initialParameters(chain).(varName) = seedFunc();
					end
				end
			end
		end

		% function setMonitoredValues(obj, varsToMonitor)
		% 	% cell array of strings defining the variables we want to monitor
		% 	%obj.monitorparams = fieldnames(variables);
		% 	%obj.monitorparams = {variables.str};
		% 	obj.monitorparams = varsToMonitor;
		% end

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
				'nsamples', obj.mcmcparams.nsamples,...
				'thin', 1,...
				'monitorparams', obj.monitorparams,...
				'savejagsoutput', 0,...
				'verbosity', 1,...
				'cleanup', 1,...
				'rndseed', 1,...
				'dic', 0);

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
			obj.displayMCMCparamInfo();
		end

		function setMCMCnumberOfChains(obj, nchains)
			obj.mcmcparams.nchains = nchains;
			obj.mcmcparams.nsamples = obj.mcmcparams.totalSamples / obj.mcmcparams.nchains;
			obj.displayMCMCparamInfo();
		end

		function displayMCMCparamInfo(obj)
			fprintf('Total samples: %d\n', obj.mcmcparams.totalSamples)
			fprintf('%d chains, with %d samples each\n', ...
				obj.mcmcparams.nchains, obj.mcmcparams.nsamples)
		end

	end

end
