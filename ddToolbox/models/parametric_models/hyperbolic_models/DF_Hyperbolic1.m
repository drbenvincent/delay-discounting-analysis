classdef DF_Hyperbolic1 < DiscountFunction
	%Hyperbolic1 The classic 1-parameter discount function
	
	properties (Dependent)
		
	end
	
	methods (Access = public)
		
		function obj = DF_Hyperbolic1(varargin)
			obj = obj@DiscountFunction();
			
			obj.theta.logk = Stochastic('logk');
			
			
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
				y = bsxfun(@rdivide, 1, 1 + (bsxfun(@times, exp(theta.logk), x.delay) ) );
			else
				% use new array broadcasting in 2016b
				y = 1 ./ ((1 + exp(theta.logk)) .* x);
			end
		end
		
	end
	
	
end
