classdef DF_Hyperboloid < DF1
	
	properties (Dependent)
		
	end
	
	methods (Access = public)
		
		function obj = DF_Hyperboloid(varargin)
			obj = obj@DF1(varargin{:});
		end
		
	end
	
	
	methods (Static, Access = protected)
		
		function y = function_evaluation(x, theta)
			if verLessThan('matlab','9.1')
                y = bsxfun(@rdivide, 1,  1 + (bsxfun(@times, exp(theta.logk), x) ));
				%y = bsxfun(@rdivide, 1,  bsxfun(@power, 1 + (bsxfun(@times, exp(theta.logk), x) ), theta.pow ));
			else
				% use new array broadcasting in 2016b
				y = 1 ./ (1 + exp(theta.logk) .* x);
                %y = 1 ./ (1 + exp(theta.logk) .* x).^theta.pow;
			end
		end
		
	end
	
	
end
