classdef DF_BetaDelta < DF1
%DF_BetaDelta Deterministic object for the Beta Delta discount function.

	properties (Dependent)

	end

	methods (Access = public)

		function obj = DF_BetaDelta(varargin)
			obj = obj@DF1(varargin{:});
		end

	end


	methods (Static, Access = protected)

		function y = function_evaluation(x, theta)
			if verLessThan('matlab','9.1')
				y = bsxfun(@times, theta.beta,  bsxfun(@power, theta.delta, x ));
			else
				% use new array broadcasting in 2016b
                y = theta.beta .* (theta.delta .^ x);
			end
			% set y=1 when delay=0
			y(x==0) = 1;
		end

	end


end
