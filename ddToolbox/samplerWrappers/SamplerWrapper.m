classdef (Abstract) SamplerWrapper
	%SamplerWrapper Abstract base class.
  % This is basically a wrapper to either matjags or matlabstan.

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
		function obj = SamplerWrapper()
		end
		% =================================================================

	end
end
