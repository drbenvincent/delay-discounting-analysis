classdef (Abstract) SamplerWrapper
	%SamplerWrapper Abstract base class.
  % This is basically a wrapper to either matjags or matlabstan.

	properties (Access = public)
		observedData % struct
		modelFilename
		mcmcparams % struct
		monitorparams % cell array of parameter names
	end

	properties (GetAccess = public, SetAccess = protected)
	end

	methods(Abstract, Access = public)
		conductInference(obj)
		%setDefaultMCMCparams(obj)
	end

	methods (Access = public)
		function obj = SamplerWrapper() % constructor
		end
		
		function obj = updateMCMCparams(obj, userProvidedMcmcPreferences)
			% update defaults (obj.mcmcparams) with any userProvidedMcmcPreferences
			
			% list of fields specified in kwarg structure
			fields = fieldnames(userProvidedMcmcPreferences);
			
			% loop through adding, or overwriting the fields in opts with that in
			% kwargs.
			for n=1:numel(fields)
				obj.mcmcparams.(fields{n}) = userProvidedMcmcPreferences.(fields{n});
			end
		end
	end
	
	methods (Access = protected)
		function n = samplesPerChain(obj)
			n = ceil( obj.mcmcparams.nsamples / obj.mcmcparams.nchains);
		end
		

		
	end
end
