classdef DF_Exponential1 < DF1
	%DF_Exponential1 The classic 1-parameter discount function

	properties (Dependent)
		
	end
	
	methods (Access = public)

		function obj = DF_Exponential1(varargin)
			obj = obj@DF1(varargin{:});
        end

	end
	
	methods (Static, Access = protected)
		
		function y = function_evaluation(x, theta)
			if verLessThan('matlab','9.1')
				y = (bsxfun(@times,...
					exp( - theta.k),...
					x) );
			else
				% use new array broadcasting in 2016b
				y = exp( - theta.k .* x );
			end
		end
		
	end

end
