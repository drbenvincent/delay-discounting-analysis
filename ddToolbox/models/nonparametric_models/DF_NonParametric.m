classdef DF_NonParametric < DF1
	%DF_NonParametric The classic 1-parameter discount function
	
	methods (Access = public)

		function obj = DF_NonParametric(varargin)
			obj = obj@DF1(varargin{:});
        end

	end
	methods (Access = protected)
		
		% OVERRIDDEN FROM SUPERCLASS
		function delayValues = getDelayValues(obj)
			delayValues = obj.data.getUniqueDelays;
		end
	end
	
	methods (Static, Access = protected)
		
		function y = function_evaluation(~, theta)
			% TODO: basically, return theta as a matrix, but add zeros for
			% zero delay
			y = theta.Rstar;
			y = [ ones(1,size(y,2)); y  ];
		end
		
	end

end
