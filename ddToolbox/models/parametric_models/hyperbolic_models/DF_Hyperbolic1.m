classdef DF_Hyperbolic1 < DF1
	%Hyperbolic1 The classic 1-parameter discount function
	
	properties (Dependent)
		
	end
	
	methods (Access = public)
		
		function obj = DF_Hyperbolic1(varargin)
			obj = obj@DF1(varargin{:});
		end
		
	end
	
	
	methods (Static, Access = protected)
		
		function y = function_evaluation(x, theta)
			if verLessThan('matlab','9.1')
				y = bsxfun(@rdivide, 1, 1 + (bsxfun(@times, exp(theta.logk), x) ) );
			else
				% use new array broadcasting in 2016b
				y = 1 ./ (1 + exp(theta.logk) .* x);
			end
		end
		
	end
	
	
end
