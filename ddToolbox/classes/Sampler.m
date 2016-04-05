classdef (Abstract) Sampler < handle
	%Sampler Abstract base class sampler class.

	properties (Access = public)
		sampler % string {'JAGS'|'STAN'}
		%modelHandle % handle to model (eg ModelHierarchical or ModelSeperate)

		observed % struct
		modelFilename

		mcmcparams % struct
		monitorparams % cell array of parameter names
	end
	properties (GetAccess = public, SetAccess = protected)
	end


	methods(Abstract, Access = public)
		conductInference(obj)
		%setMCMCparams(obj)

		getSamplesAtIndex(obj,index)
		getSamplesFromParticipantAsMatrix()
		getSamples()
		getSamplesAsMatrix()
		%getAllSamples()
		getStats()
		getAllStats()

		%invokeSampler(obj)
		%setMCMCtotalSamples(obj, totalSamples)
		%setMCMCnumberOfChains(obj, nchains)
		%setBurnIn(obj, nburnin)
		convergenceSummary(obj, data)
	end


	methods (Access = public)

		% CONSTRUCTOR =====================================================
		function obj = Sampler()
		end
		% =================================================================

	end
end
