classdef DF_EbertPrelec < DF1
	%DF_EbertPrelec 

	properties (Dependent)
		
	end
	
	methods (Access = public)

		function obj = DF_EbertPrelec(varargin)
			obj = obj@DF1(varargin{:});
		end
        
	end
	
	methods (Static, Access = protected)
		
		function y = function_evaluation(x, theta)
			if verLessThan('matlab','9.1')
				y = exp( - bsxfun(@power, bsxfun(@times, theta.k , x ), theta.tau) );
			else
				% use new array broadcasting in 2016b
				y = exp( - (theta.k .* x).^theta.tau );
			end
		end
		
	end

end
