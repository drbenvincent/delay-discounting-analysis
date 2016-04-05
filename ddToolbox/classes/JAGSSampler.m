classdef JAGSSampler < Sampler
	%JAGSSampler

	properties (GetAccess = public, SetAccess = private)

	end

	properties (Access = private)
		samples % structure returned by matjags
		stats % structure returned by matjags
		initialParameters % struct required by matjags
	end

	methods (Access = public)

		% CONSTRUCTOR =====================================================
		function obj = JAGSSampler(modelFilename)
			obj = obj@Sampler();

			obj.modelFilename = modelFilename;
			obj.sampler = 'JAGS';
			obj.setMCMCparams();
		end
		% =================================================================

		function conductInference(obj, model, data)
			variables = model.variables;
			nParticipants = data.nParticipants;
			saveFolder = model.saveFolder;
			IDnames = data.IDname;

			assert(obj.mcmcparams.nchains>=2,'Use a minimum of 2 MCMC chains')
			startParallelPool()
			obj.setInitialParamValues(variables, nParticipants);
			obj.setMonitoredValues(variables);
			obj.invokeSampler();
			obj.convergenceSummary(saveFolder,IDnames)
			% TODO: ***** SAVE THE MODEL OBJECT HERE *****
		end

		function setInitialParamValues(obj, variables, nParticipants)
			for chain=1:obj.mcmcparams.nchains
				for v = 1:numel(variables)
					if isempty(variables(v).seed), continue, end
					varName = variables(v).str;
					if variables(v).seed.single==false
						% participant level
						for p=1:nParticipants
							obj.initialParameters(chain).(varName)(p) = variables(v).seed.func();
						end
					else
						% non-participant level
						obj.initialParameters(chain).(varName) = variables(v).seed.func();
					end
				end
			end
		end

		function setMonitoredValues(obj, variables)
			% TODO: move this method to Sampler base class?
			% currently just monitors ALL variables
			obj.monitorparams = {variables.str};
		end

		function invokeSampler(obj)
			fprintf('\nRunning JAGS (%d chains, %d samples each)\n',...
				obj.mcmcparams.nchains,...
				obj.mcmcparams.nsamples);
			[obj.samples, obj.stats] = matjags(...
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
		end

		function convergenceSummary(obj,saveFolder,IDnames)

			[fid, fname] = setupFile(saveFolder);
			MCMCParameterReport();
			RhatInformation(IDnames);
			fclose(fid);
			fprintf('Convergence report saved in:\n\t%s\n\n',fname)

			function [fid, fname] = setupFile(saveFolder)
				ensureFolderExists(fullfile('figs',saveFolder))
				fname = fullfile('figs',saveFolder,['ConvergenceReport.txt']);
				fid=fopen(fname,'w');
			end

			function MCMCParameterReport()
				%% MCMC parameter report
				logInfo(fid, 'MCMC inference was conducted with %d chains. ', obj.mcmcparams.nchains)
				logInfo(fid,'The first %d samples were discarded from each chain, ', obj.mcmcparams.nburnin )
				logInfo(fid,'resulting in a total of %d samples to approximate the posterior distribution. ', obj.mcmcparams.totalSamples )
				logInfo(fid,'\n\n\n');
			end

			function RhatInformation(IDnames)
				warningFlag = false;
				names = fieldnames(obj.stats.Rhat);
				% loop over fields and report for either single values or
				% multiple values (eg when we have multiple participants)
				for n=1:numel(names)
					% skip posterior predictive variables
					if strcmp(names(n),'Rpostpred')
						continue
					end
					RhatValues = obj.stats.Rhat.(names{n});
					logInfo(fid,'\nRhat for: %s.\n',names{n});
					for i=1:numel(RhatValues)
						if numel(RhatValues)>1
							logInfo(fid,'%s\t', IDnames{i});
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
			end
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
			%samplesPerChain				= totalSamples / obj.mcmcparams.nchains;
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

		%% GET METHODS ----------------------------------------------------
		function [samples] = getSamplesAtIndex(obj, index, fieldsToGet)
			assert(iscell(fieldsToGet),'fieldsToGet must be a cell array')
			% get all the samples for a given value of the 3rd dimension of
			% samples. Dimensions are:
			% 1. mcmc chain number
			% 2. mcmc sample number
			% 3. index of variable, meaning depends upon context of the
			% model

			[flatSamples] = obj.flattenChains(obj.samples, fieldsToGet);
			for i = 1:numel(fieldsToGet)
				samples.(fieldsToGet{i}) = flatSamples.(fieldsToGet{i})(:,index);
			end
		end

		function [samplesMatrix] = getSamplesFromParticipantAsMatrix(obj, participant, fieldsToGet)
			assert(iscell(fieldsToGet),'fieldsToGet must be a cell array')
			% TODO: This function is doing the same thing as getSamplesAtIndex() ???

			for n=1:numel(fieldsToGet)
				samples.(fieldsToGet{n}) = vec(obj.samples.(fieldsToGet{n})(:,:,participant));
			end

			[samplesMatrix] = struct2Matrix(samples);
		end

		function [samples] = getSamples(obj, fieldsToGet)
			% This will not flatten across chains
			assert(iscell(fieldsToGet),'fieldsToGet must be a cell array')
			samples = [];
			for n=1:numel(fieldsToGet)
				if isfield(obj.samples,fieldsToGet{n})
					samples.(fieldsToGet{n}) = obj.samples.(fieldsToGet{n});
				end
			end
		end

		function [samplesMatrix] = getSamplesAsMatrix(obj, fieldsToGet)

			[samples] = obj.getSamples(fieldsToGet);

			% flatten across chains
			fields = fieldnames(samples);
			for n=1:numel(fields)
				samples.(fields{n}) = vec(samples.(fields{n}));
			end

			[samplesMatrix] = struct2Matrix(samples);
		end

		% function [samples] = getAllSamples(obj)
		% 	warning('Try to remove this method')
		% 	samples = obj.samples;
		% end

		function [output] = getStats(obj, field, variable)
			% return column vector
			output = obj.stats.(field).(variable)';
		end

		function [output] = getAllStats(obj)
			warning('Try to remove this method')
			output = obj.stats;
		end

		function [predicted] = getParticipantPredictedResponses(obj, participant)
			% calculate the probability of choosing the delayed reward, for
			% all trials, for a particular participant.
			Rpostpred = obj.samples.Rpostpred;
			% extract samples from the participant
			Rpostpred = squeeze(Rpostpred(:,:,participant,:));
			% flatten over chains
			s = size(Rpostpred);
			participantRpostpredSamples = reshape(Rpostpred, s(1)*s(2), s(3));
			[nSamples,~] = size(participantRpostpredSamples);
			% predicted probability of choosing delayed (response = 1)
			predicted = sum(participantRpostpredSamples,1)./nSamples;
		end

	end


	methods(Static)

		function [samples] = flattenChains(samples, fieldsToGet)
			% collapse the first 2 dimensions of samples (number of MCMC
			% chains, number of MCMC samples)
			for n=1:numel(fieldsToGet)
				temp = samples.(fieldsToGet{n});
				oldDims = size(temp);
				newDims = [oldDims(1)*oldDims(2) oldDims([3:end])];
				samples.(fieldsToGet{n}) = reshape(temp, newDims);
			end
		end

	end
end
