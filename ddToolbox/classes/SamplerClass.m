classdef (Abstract) SamplerClass < handle
	%Sampler Abstract base class sampler class.
	%	Specific sampler sub-classes must implement the methods outlined here.

	properties (Access = public)
		%modelType % string
		sampler % string {'JAGS'|'STAN'}
		%range % struct
		modelHandle % handle to model (eg ModelHierarchical or ModelSeperate)

		observed % struct
		fileName % string JAGS OR STAN FILE NAME
		initial_param % struct
		mcmcparams % struct
		monitorparams % struct
	end
	properties (GetAccess = public, SetAccess = protected)
		%samples, stats % structures returned by `matjags`
		%analyses % struct
	end


	methods(Abstract, Access = public)
		setMCMCparams(obj)
		conductInference(obj)
		%setMonitoredValues(obj, data) % DONE IN THE MODEL
		%setObservedValues(obj, data) % DONE IN THE MODEL
		%setInitialParamValues(obj, data) % DONE IN THE MODEL
		getSamplesAtIndex(obj,index)
		invokeSampler(obj)

		setMCMCtotalSamples(obj, totalSamples)
		setMCMCnumberOfChains(obj, nchains)
		setBurnIn(obj, nburnin)
		%calcSampleRange(obj) % DONE IN MODEL??
		convergenceSummary(obj, data)
	end


	methods (Access = public)

		% CONSTRUCTOR =====================================================
		function obj = SamplerClass()
		end
		% =================================================================


	end
end
