classdef STANmcmc < mcmcContainer
	%STANmcmc

	properties (Access = public)
    stanFit % object returned by STAN
		stats
		mcmcparams
	end

	methods(Abstract, Access = public)

	end

	methods (Access = public)

		function obj = STANmcmc(stanFit)
			obj = obj@mcmcContainer(); % create instance of base class

			obj.stanFit = stanFit;

			obj.samples = obj.stanFit.extract('permuted',true);
			%obj.stats = stats;
			%obj.mcmcparams = mcmcparams;

		end

		function convergenceSummary(obj,saveFolder,IDnames)

			% [fid, fname] = setupFile(saveFolder);
			% MCMCParameterReport();
			% RhatInformation(IDnames);
			% fclose(fid);
			% fprintf('Convergence report saved in:\n\t%s\n\n',fname)
			%
			% function [fid, fname] = setupFile(saveFolder)
			% 	ensureFolderExists(fullfile('figs',saveFolder))
			% 	fname = fullfile('figs',saveFolder,['ConvergenceReport.txt']);
			% 	fid=fopen(fname,'w');
			% end
			%
			% function MCMCParameterReport()
			% 	%% MCMC parameter report
			% 	logInfo(fid, 'MCMC inference was conducted with %d chains. ', obj.mcmcparams.nchains)
			% 	logInfo(fid,'The first %d samples were discarded from each chain, ', obj.mcmcparams.nburnin )
			% 	logInfo(fid,'resulting in a total of %d samples to approximate the posterior distribution. ', obj.mcmcparams.totalSamples )
			% 	logInfo(fid,'\n\n\n');
			% end
			%
			% function RhatInformation(IDnames)
			% 	warningFlag = false;
			% 	names = fieldnames(obj.stats.Rhat);
			% 	% loop over fields and report for either single values or
			% 	% multiple values (eg when we have multiple participants)
			% 	for n=1:numel(names)
			% 		% skip posterior predictive variables
			% 		if strcmp(names(n),'Rpostpred')
			% 			continue
			% 		end
			% 		RhatValues = obj.stats.Rhat.(names{n});
			% 		logInfo(fid,'\nRhat for: %s.\n',names{n});
			% 		for i=1:numel(RhatValues)
			% 			if numel(RhatValues)>1
			% 				logInfo(fid,'%s\t', IDnames{i});
			% 			end
			% 			logInfo(fid,'%2.5f\t', RhatValues(i));
			% 			if RhatValues(i)>1.01
			% 				warningFlag = true;
			% 				logInfo(fid,'WARNING: poor convergence');
			% 			end
			% 			logInfo(fid,'\n');
			% 		end
			% 	end
			% 	if warningFlag
			% 		logInfo(fid,'\n\n\n**** WARNING: convergence issues :( ****\n\n\n')
			% 		beep
			% 	else
			% 		logInfo(fid,'\n\n\n**** No convergence issues :) ****\n\n\n')
			% 	end
			% end
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

			% % [flatSamples] = obj.flattenChains(obj.samples, fieldsToGet);
			for i = 1:numel(fieldsToGet)
			 	samples.(fieldsToGet{i}) = obj.samples.(fieldsToGet{i})(:,index);
			 end
		end

		function [samplesMatrix] = getSamplesFromParticipantAsMatrix(obj, participant, fieldsToGet)
			assert(iscell(fieldsToGet),'fieldsToGet must be a cell array')
			[samples] = obj.getSamplesAtIndex(participant, fieldsToGet);
			[samplesMatrix] = struct2Matrix(samples);
		end

		function [samples] = getSamples(obj, fieldsToGet)
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
			[samplesMatrix] = struct2Matrix(samples);
		end

		function [output] = getStats(obj, field, variable)
			% % return column vector
			% output = obj.stats.(field).(variable)';
			switch field
				case{'mean'}
					output = mean( obj.samples.(variable) );
			end
		end

		function [output] = getAllStats(obj)
			% warning('Try to remove this method')
			% output = obj.stats;
		end

		function [predicted] = getParticipantPredictedResponses(obj, participant)
			% % calculate the probability of choosing the delayed reward, for
			% % all trials, for a particular participant.
			% Rpostpred = obj.samples.Rpostpred;
			% % extract samples from the participant
			% Rpostpred = squeeze(Rpostpred(:,:,participant,:));
			% % flatten over chains
			% s = size(Rpostpred);
			% participantRpostpredSamples = reshape(Rpostpred, s(1)*s(2), s(3));
			% [nSamples,~] = size(participantRpostpredSamples);
			% % predicted probability of choosing delayed (response = 1)
			% predicted = sum(participantRpostpredSamples,1)./nSamples;
		end

	end

	% methods(Static)
	%
	% 	function [samples] = flattenChains(samples, fieldsToGet)
	% 		% collapse the first 2 dimensions of samples (number of MCMC
	% 		% chains, number of MCMC samples)
	% 		for n=1:numel(fieldsToGet)
	% 			temp = samples.(fieldsToGet{n});
	% 			oldDims = size(temp);
	% 			newDims = [oldDims(1)*oldDims(2) oldDims([3:end])];
	% 			samples.(fieldsToGet{n}) = reshape(temp, newDims);
	% 		end
	% 	end
	%
	% end
end
