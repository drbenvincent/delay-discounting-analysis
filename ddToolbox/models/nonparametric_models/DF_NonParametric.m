classdef DF_NonParametric < DF1
	%DF_NonParametric The classic 1-parameter discount function
	
	methods (Access = public)

		function obj = DF_NonParametric(varargin)
			obj = obj@DF1(varargin{:});
            
			% % TODO: this violates dependency injection, so we may want to pass these Stochastic objects in
			% obj.theta.Rstar = Stochastic('Rstar');
			% % ^^^ think this needs to be an array of objects
			
            %obj = obj.parse_for_samples_and_data(varargin{:});
        end

	end
	methods (Access = protected)
		
		% OVERRIDDEN FROM SUPERCLASS
		function delayValues = getDelayValues(obj)
			%delayValues = [0 365];
			delayValues = obj.data.getUniqueDelays;
		end
	end
	
	methods (Static, Access = protected)
		
		function y = function_evaluation(~, theta)
			% TODO: basically, return theta as a matrix, but add zeros for
			% zero delay
			y = theta.Rstar;
			y = [ ones(1,size(y,2)); y  ];
			%y = [1 0.5];
		end
		
	end

end
