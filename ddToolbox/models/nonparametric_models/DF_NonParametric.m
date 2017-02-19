classdef DF_NonParametric < DF1
	%DF_NonParametric The classic 1-parameter discount function
	
	methods (Access = public)

		function obj = DF_NonParametric(varargin)
			obj = obj@DF1(varargin{:});
            
			% TODO: this violates dependency injection, so we may want to pass these Stochastic objects in
			obj.theta.Rstar = Stochastic('Rstar');
			% ^^^ think this needs to be an array of objects
			
            obj = obj.parse_for_samples_and_data(varargin{:});
        end

	end
	
	methods (Static, Access = protected)
		
		function y = function_evaluation(x, theta)
			
            % TODO: basically, return theta as a matrix
			y = [1 0.5];
			
		end
		
		% OVERRIDDEN FROM SUPERCLASS
		function delayValues = getDelayValues(obj)

			delayValues = [0 365];
			
		end
		
        
	end

end
