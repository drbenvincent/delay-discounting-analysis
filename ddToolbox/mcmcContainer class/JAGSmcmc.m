classdef JAGSmcmc < mcmcContainer
	%JAGSmcmc Implements the mcmcContainer interface

	properties (Access = public)
		stats
		mcmcparams
	end

	methods(Abstract, Access = public)

	end

	methods (Access = public)

		function obj = JAGSmcmc(samples, stats, mcmcparams)
			obj = obj@mcmcContainer(); % create instance of base class

			obj.samples = samples;
			obj.stats = stats;
			obj.mcmcparams = mcmcparams;
		end


		function data = grabParamEstimates(obj, varNames, getCI, pointEstimateType)
			assert(islogical(getCI))
			data=[];
			for n=1:numel(varNames)
				data = [data obj.getStats(pointEstimateType,varNames{n})];
				if getCI
					data = [data obj.getStats('hdi_low',varNames{n})];
					data = [data obj.getStats('hdi_high',varNames{n})];
				end
			end
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
			for field = each(fieldsToGet)
				samples.(field) = flatSamples.(field)(:,index,:);
			end
		end

		function [samplesMatrix] = getSamplesFromParticipantAsMatrix(obj, participant, fieldsToGet)
			assert(iscell(fieldsToGet),'fieldsToGet must be a cell array')
			% TODO: This function is doing the same thing as getSamplesAtIndex() ???
			for field = each(fieldsToGet)
				samples.(field) = vec(obj.samples.(field)(:,:,participant));
			end
			[samplesMatrix] = struct2Matrix(samples);
		end

		function [samples] = getSamples(obj, fieldsToGet)
			% This will not flatten across chains
%			assert(iscell(fieldsToGet),'fieldsToGet must be a cell array')
			for field = each(fieldsToGet)
				if isfield(obj.samples,field)
					samples.(field) = obj.samples.(field);
				end
			end
		end

		function [samplesMatrix] = getSamplesAsMatrix(obj, fieldsToGet)
			[samples] = obj.getSamples(fieldsToGet);
			% flatten across chains
			for field = each(fieldsToGet)
				samples.(field) = vec(samples.(field));
			end
			[samplesMatrix] = struct2Matrix(samples);
		end

		function [columnVector] = getStats(obj, field, variable)
			try
				columnVector = obj.stats.(field).(variable)';
			catch
				columnVector =[];
			end
		end

		function pointEstimates = getParticipantPointEstimates(obj, n, variableNames)
			assert(iscellstr(variableNames))
			for var = each(variableNames)
				temp = obj.getStats('mean', var);
				pointEstimates.(var) = temp(n);
			end
		end


		function [predicted] = getParticipantPredictedResponses(obj, ind)
			% ind is a binary valued vector indicating the trials
			% corresponding to a particular participant
			assert(isvector(ind))
			RpostPred = obj.samples.Rpostpred(:,:,ind);
			% collapse over chains
			s = size(RpostPred);
			%if ndims(RpostPred) == 2
			%	participantRpostpredSamples = RpostPred(:);
			%else
			%	warning('IS THIS LINE EVER REACHED?')
				participantRpostpredSamples = reshape(RpostPred, s(1)*s(2), s(3));
			%end
            % Calculate predicted response probability
			predicted = sum(participantRpostpredSamples,1) ./ size(participantRpostpredSamples,1);
		end

		function [P] = getPChooseDelayed(obj, pInd)
			% get samples for participant
			P = obj.samples.P(:,:,pInd);
			% flatten over chains
			s = size(P);
			P = reshape(P, s(1)*s(2), s(3));
			P=P';
		end

	end

	methods(Static)

		function [samples] = flattenChains(samples, fieldsToGet)
			% collapse the first 2 dimensions of samples (number of MCMC
			% chains, number of MCMC samples)
			for field = each(fieldsToGet)
				temp = samples.(field);
				oldDims = size(temp);
				switch numel(oldDims)
					case{2}
						% only dealing with one participant
						samples.(field) = vec(temp);
					case{3}
						% dealing with multiple participants
						newDims = [oldDims(1)*oldDims(2) oldDims(3)];
						samples.(field) = reshape(temp, newDims);
					case{4}
						newDims = [oldDims(1)*oldDims(2) oldDims(3) oldDims(4)];
						samples.(field) = reshape(temp, newDims);
				end
			end
		end

	end
end
