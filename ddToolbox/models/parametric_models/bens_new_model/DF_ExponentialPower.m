classdef DF_ExponentialPower < DiscountFunction
	%DF_ExponentialPower The classic 1-parameter discount function

	properties (Dependent)
		
	end
	
	methods (Access = public)

		function obj = DF_ExponentialPower(varargin)
			obj = obj@DiscountFunction();
			
			obj.theta.k = Stochastic('k');
            obj.theta.tau = Stochastic('tau');
			
			% Input parsing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			p = inputParser;
			p.StructExpand = false;
			p.addParameter('samples',struct(), @isstruct)
			p.parse(varargin{:});
			
			fieldnames = fields(p.Results.samples);
			% Add any provided samples
			for n = 1:numel(fieldnames)
				obj.theta.(fieldnames{n}).addSamples( p.Results.samples.(fieldnames{n}) );
			end
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			
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
