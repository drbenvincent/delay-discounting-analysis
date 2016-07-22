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
		setDefaultMCMCparams(obj)
	end

	methods (Access = public)
		function obj = SamplerWrapper() % constructor
		end
	end
	
	methods (Access = protected)
		function n = samplesPerChain(obj)
			n = ceil( obj.mcmcparams.nsamples / obj.mcmcparams.nchains);
		end
	end
end
