classdef DF_ExponentialPower < DF1
	%DF_ExponentialPower The classic 1-parameter discount function

	properties (Dependent)
		
	end
	
	methods (Access = public)

		function obj = DF_ExponentialPower(varargin)
			obj = obj@DF1(varargin{:});
			
            % TODO: this violates dependency injection, so we may want to pass these Stochastic objects in
			obj.theta.k = Stochastic('k');
            obj.theta.tau = Stochastic('tau');
            
            obj = obj.parse_for_samples_and_data(varargin{:});
		end
        
	end
	
	methods (Static, Access = protected)
		
		function y = function_evaluation(x, theta)
			if verLessThan('matlab','9.1')
				error('implement this using bsxfun: y = exp( - theta.k .* x.^theta.tau )')
			else
				% use new array broadcasting in 2016b
				y = exp( - theta.k .* x.^theta.tau );
			end
		end
		
	end

end
