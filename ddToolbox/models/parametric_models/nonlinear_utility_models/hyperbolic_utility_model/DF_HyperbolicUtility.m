classdef DF_HyperbolicUtility < DF1
	
	properties (Dependent)
		
	end
	
	methods (Access = public)
		
		function obj = DF_HyperbolicUtility(varargin)
			obj = obj@DF1(varargin{:});
		end
		
	end
	
	
	methods (Static, Access = protected)
		
		function y = function_evaluation(x, theta)
			if verLessThan('matlab','9.1')
				error('implement me')
			else
				% use new array broadcasting in 2016b
                y = (1.^theta.U) ./ (1 + exp(theta.logk) .* x) ;
			end
		end
		
	end
	
	
end
