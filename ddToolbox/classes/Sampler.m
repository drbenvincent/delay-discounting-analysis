classdef (Abstract) Sampler < handle
	%Sampler Abstract base class sampler class.
  % Responsibility is to invoke an MCMC sampler and return MCMC chains.

	properties (Access = public)
		observed % struct
		modelFilename
		mcmcparams % struct
		monitorparams % cell array of parameter names
	end

	properties (GetAccess = public, SetAccess = protected)
	end

	methods(Abstract, Access = public)
		conductInference(obj)
	end

	methods (Access = public)

		% CONSTRUCTOR =====================================================
		function obj = Sampler()
		end
		% =================================================================

	end
end
