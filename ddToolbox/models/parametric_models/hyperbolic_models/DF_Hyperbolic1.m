classdef DF_Hyperbolic1 < DiscountFunction
	%Hyperbolic1 The classic 1-parameter discount function
	
	properties (Dependent)
		
	end
	
	methods (Access = public)
		
		function obj = DF_Hyperbolic1(varargin)
			obj = obj@DiscountFunction(varargin{:});
			
			obj.theta.logk = Stochastic('logk');
			
            obj = obj.parse_for_samples_and_data(varargin{:});
		end
		
	end
	
	
	methods (Static, Access = protected)
		
		function y = function_evaluation(x, theta)
			if verLessThan('matlab','9.1')
				y = bsxfun(@rdivide, 1, 1 + (bsxfun(@times, exp(theta.logk), x.delay) ) );
			else
				% use new array broadcasting in 2016b
				y = 1 ./ (1 + exp(theta.logk) .* x);
			end
		end
		
	end
	
	
end
