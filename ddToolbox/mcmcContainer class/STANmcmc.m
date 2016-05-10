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
			for field = each(fieldsToGet)
			 	samples.(field) = obj.samples.(field)(:,index);
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
			for field = each(fieldsToGet)
			 	if isfield(obj.samples,field)
			 		samples.(field) = obj.samples.(field);
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
