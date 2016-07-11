classdef STANmcmc < mcmcContainer
	%STANmcmc This is an MCMC container which wraps around a StanFit
	%object. It provides useful getter functions

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
			obj.calcStatsFromSamples()
		end

		function calcStatsFromSamples(obj)
			f = fieldnames(obj.samples);
			for n=1:numel(f)
				obj.stats.mean.(f{n}) = mean(obj.samples.(f{n}));
				obj.stats.median.(f{n}) = median(obj.samples.(f{n}));
				obj.stats.mode.(f{n}) = mode(obj.samples.(f{n})); % TODO: do this by kernel density estimation
				obj.stats.std.(f{n}) = std(obj.samples.(f{n}));
				% get HDI
				tempSamples = obj.samples.(f{n});
				for i=1:size(tempSamples,2)
					[HDI] = HDIofSamples(tempSamples(:,i), 0.95);
					obj.stats.hdi_low.(f{n})(:,i) = HDI(1);
					obj.stats.hdi_high.(f{n})(:,i) = HDI(2);
				end
				% get 95% CI
				tempSamples = obj.samples.(f{n});
				for i=1:size(tempSamples,2)
					[CI] = prctile(tempSamples(:,i), [2.5 97.5]);
					obj.stats.ci_low.(f{n})(:,i) = CI(1);
					obj.stats.ci_high.(f{n})(:,i) = CI(2);
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

		function [columnVector] = getStats(obj, pointEstimateType, variable)
			% % return column vector
			% output = obj.stats.(field).(variable)';
			try
				columnVector = obj.stats.(pointEstimateType).(variable)';
			catch
				columnVector =[];
			end
		end

		function [output] = getAllStats(obj)
			beep
			error('Is this method being called any more?')
			% output = obj.stats;
		end

		function [predicted] = getParticipantPredictedResponses(obj, ind)
			RpostPred = obj.samples.Rpostpred(:,ind);
			predicted = sum(RpostPred,1) ./ size(RpostPred,1);
		end

		function [P] = getPChooseDelayed(obj, ind)
			% get samples for participant
			P = obj.samples.P(:,ind);
			P=P';
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

	end

end
