classdef DF_HyperboloidB < DF1
	
	properties (Dependent)
		
	end
	
	methods (Access = public)
		
		function obj = DF_HyperboloidB(varargin)
			obj = obj@DF1(varargin{:});
		end
		
	end
	
	
	methods (Static, Access = protected)
		
		function y = function_evaluation(x, theta)
			if verLessThan('matlab','9.1')
				y = bsxfun(@rdivide, 1,  1 + (bsxfun(@times, exp(theta.logk), bsxfun(@power, x, theta.S )) ));
			else
				% use new array broadcasting in 2016b
                y = 1 ./ (1 + exp(theta.logk) .* (x.^theta.S));
			end
		end
		
	end
	
	
end
