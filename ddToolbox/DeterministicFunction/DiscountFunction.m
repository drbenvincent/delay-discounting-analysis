classdef (Abstract) DiscountFunction < DeterministicFunction
	%DiscountFunction
	
	properties
		%timeUnits % string
	end
	
	% % methods that subclasses must implement
	% methods (Abstract, Access = public)
	%     calcAUC(obj, maxDelay)
	% end
	
	methods (Access = public)
		
		function obj = DiscountFunction(varargin)
			obj = obj@DeterministicFunction(varargin{:});
		end
		
	end
	
    methods (Abstract, Access = public)
		calcAUC()
	end
	
	methods (Access = protected)
		
		function delayValues = getDelayValues(obj)
			% TODO: remove this stupid special-case handling of group-level
			% participant with no data
			try
				maxDelayRange = max( obj.data.getUniqueDelays() )*1.2;
			catch
				% default (happens when there is no data, ie group level
				% observer).
				maxDelayRange = 365;
			end
			
			% WARNING: Potential error occuring with delay being zero. But
			% not sure yet - it could just be poor priors leading to bad
			% param values.
			delayValues = linspace(0, maxDelayRange, 1000);
		end
		
	end
	
end
