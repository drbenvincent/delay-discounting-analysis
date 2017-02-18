classdef DF_Exponential1 < DiscountFunction
	%DF_Exponential1 The classic 1-parameter discount function

	properties (Dependent)
		
	end
	
	methods (Access = public)

		function obj = DF_Exponential1(varargin)
			obj = obj@DiscountFunction(varargin{:});
			
            % TODO: this violates dependency injection, so we may want to pass these Stochastic objects in
			obj.theta.k = Stochastic('k');
			
            obj = obj.parse_for_samples_and_data(varargin{:});
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
