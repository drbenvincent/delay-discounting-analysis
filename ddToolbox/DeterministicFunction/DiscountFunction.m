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
	
    
    methods (Access = protected)

        function delayValues = getDelayValues(obj)
            % TODO: remove this stupid special-case handling of group-level
            % participant with no data
            try
                maxDelayRange = max( obj.data.getDelayRange() )*1.2;
            catch
                % default (happens when there is no data, ie group level
                % observer).
                maxDelayRange = 365;
            end
            delayValues = linspace(0, maxDelayRange, 1000);
        end
        
        function nansPresent = anyNaNsPresent(obj)
            nansPresent = false;
            for field = fields(obj.theta)'
                if any(isnan(obj.theta.(field{:}).samples))
                    nansPresent = true;
                    warning('NaN''s detected in theta')
                    break
                end
            end
        end

    end	
    
end
