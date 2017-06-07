classdef DF_ExponentialLog < DF1
	%DF_ExponentialLog 

	properties (Dependent)
		
	end
	
	methods (Access = public)

		function obj = DF_ExponentialLog(varargin)
			obj = obj@DF1(varargin{:});
		end
        
	end
	
	methods (Static, Access = protected)
		
		function y = function_evaluation(x, theta)
			if verLessThan('matlab','9.1')
				y = exp( - bsxfun(@times, theta.k , log(1 + bsxfun(@times, x, theta.tau) )) );
			else
				% use new array broadcasting in 2016b
				y = exp( - theta.k .* log( 1 + x.*theta.tau ) );
			end
		end
		
	end

end
