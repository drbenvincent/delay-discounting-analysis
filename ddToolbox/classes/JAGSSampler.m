classdef JAGSSampler < SamplerClass
	%Sampler Base class to provide basic functionality
	%	xxxx

	properties (GetAccess = public, SetAccess = private)
		samples, stats % structures returned by `matjags`
		%analyses % struct
	end

	methods (Access = public)

		% CONSTRUCTOR =====================================================
		function obj = JAGSSampler(fileName)
			obj = obj@SamplerClass();

			obj.fileName = fileName;
			obj.sampler = 'JAGS';
			obj.setMCMCparams();
		end
		% =================================================================

		function setMCMCparams(obj)
			obj.mcmcparams.doparallel = 1;
			obj.mcmcparams.nchains = 2;
			obj.mcmcparams.nburnin = 1000;
			obj.mcmcparams.nsamples = 10^5; % 10^5 - 10^6 min for GOOD results
			obj.mcmcparams.model = obj.fileName;
			obj.mcmcparams.totalSamples = obj.mcmcparams.nchains * obj.mcmcparams.nsamples;
		end

		function setBurnIn(obj, nburnin)
			obj.mcmcparams.nburnin = nburnin;
			fprintf('Burn in: %d samples\n', obj.mcmcparams.nburnin)
		end

		function setMCMCtotalSamples(obj, totalSamples)
			%samplesPerChain				= totalSamples / obj.mcmcparams.nchains;
			obj.mcmcparams.nsamples     = totalSamples / obj.mcmcparams.nchains;
			obj.mcmcparams.totalSamples = totalSamples;
			fprintf('Total samples: %d\n', obj.mcmcparams.totalSamples)
			fprintf('%d chains, with %d samples each\n', ...
				obj.mcmcparams.nchains, obj.mcmcparams.nsamples)
		end

		function setMCMCnumberOfChains(obj, nchains)
			obj.mcmcparams.nchains = nchains;
			obj.mcmcparams.nsamples = obj.mcmcparams.totalSamples / obj.mcmcparams.nchains;
			fprintf('Total samples: %d\n', obj.mcmcparams.totalSamples)
			fprintf('%d chains, with %d samples each\n', ...
				obj.mcmcparams.nchains, obj.mcmcparams.nsamples)
		end

		function conductInference(obj)
			assert(obj.mcmcparams.nchains>=2,'Use a minimum of 2 MCMC chains')
			obj.startParallelPool();
			% Ask the model to set some things up, because it's model specific
			obj.modelHandle.setInitialParamValues();
			obj.modelHandle.setMonitoredValues();
			obj.modelHandle.setObservedValues();
			obj.invokeSampler();

			obj.modelHandle.calcSampleRange() % DONE IN MODEL???
			obj.modelHandle.doAnalysis()

			obj.convergenceSummary()
			display('***** SAVE THE MODEL OBJECT HERE *****')
		end

		function [samples] = getSamplesAtIndex(obj, index, fieldsToGet)
			% get all the samples for a given value of the 3rd dimension of
			% samples. Dimensions are:
			% 1. mcmc chain number
			% 2. mcmc sample number
			% 3. index of variable, meaning depends upon context of the
			% model
			[samples] = obj.flattenChains(fieldsToGet);
			for i = 1:numel(fieldsToGet)
			  samples.(fieldsToGet{i}) = samples.(fieldsToGet{i})(:,index);
			end
		end

		function [samples] = getSamples(obj, fieldsToGet)
			for n=1:numel(fieldsToGet)
				samples.(fieldsToGet{n}) = obj.samples.(fieldsToGet{n});
			end
		end

		function [samples] = flattenChains(obj, fieldsToGet)
			% collapse the first 2 dimensions of samples (number of MCMC
			% chains, number of MCMC samples)
			for n=1:numel(fieldsToGet)
				temp = obj.samples.(fieldsToGet{n});
				oldDims = size(temp);
				newDims = [oldDims(1)*oldDims(2) oldDims([3:end])];
				samples.(fieldsToGet{n}) = reshape(temp, newDims);
			end
		end

		function invokeSampler(obj)
			fprintf('\nRunning JAGS (%d chains, %d samples each)\n',...
				obj.mcmcparams.nchains,...
				obj.mcmcparams.nsamples);
			[obj.samples, obj.stats] = matjags( ...
				obj.observed, ...
				obj.fileName,... %obj.mcmcparams.model, ...
				obj.initial_param, ...
				'doparallel' , obj.mcmcparams.doparallel, ...
				'nchains', obj.mcmcparams.nchains,...
				'nburnin', obj.mcmcparams.nburnin,...
				'nsamples', obj.mcmcparams.nsamples, ...
				'thin', 1, ...
				'monitorparams', obj.modelHandle.monitorparams, ...
				'savejagsoutput' , 0 , ...
				'verbosity' , 1 , ...
				'cleanup' , 1 ,...
				'rndseed', 1,...
				'dic',0);
		end

		function convergenceSummary(obj)
			% save to a text file
			if ~exist(fullfile('figs',obj.modelHandle.data.saveName),'dir')
				mkdir(fullfile('figs',obj.modelHandle.data.saveName))
			end
			fname = fullfile('figs',obj.modelHandle.data.saveName,['ConvergenceReport.txt']);
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
						logInfo(fid,'%s\t', obj.modelHandle.data.IDname{i});
					end
					logInfo(fid,'%2.5f\t', RhatValues(i));
					if RhatValues(i)>1.01
						warningFlag = true;
						logInfo(fid,'WARNING: poor convergence');
					end
					logInfo(fid,'\n');
				end
			end
			if warningFlag
				logInfo(fid,'\n\n\n**** WARNING: convergence issues :( ****\n\n\n')
				beep
			else
				logInfo(fid,'\n\n\n**** No convergence issues :) ****\n\n\n')
			end
			fclose(fid);
			fprintf('Convergence report saved in:\n\t%s\n\n',fname)
		end




	end

	methods(Static)
		function startParallelPool()
			if isempty(gcp('nocreate')), parpool, end
		end
	end
end
