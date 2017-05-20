classdef SubjectiveTimePowerFunctionEP < DeterministicFunction
	%SubjectiveTimePowerFunctionEP
	
	methods (Access = public)
		
		function obj = SubjectiveTimePowerFunctionEP(varargin)
			obj = obj@DeterministicFunction(varargin{:});
		end
		
		function plot(obj, pointEstimateType)
			
			%% PLOT N SAMPLES
			x = [0:1:365];
			try
				plot(x, obj.eval(x, 'nExamples', 100), '-', 'Color',[0.5 0.5 0.5 0.1])
			catch
				% backward compatability
				plot(x, obj.eval(x, 'nExamples', 100), '-', 'Color',[0.5 0.5 0.5])
			end
			
			hold on
			%% Plot point estimate
			y = obj.eval(x, 'pointEstimateType', pointEstimateType);
			plot(x, y, '-',...
				'Color', 'k',...
				'LineWidth', 2)
			
			%% Formatting
			xlabel('objective time', 'interpreter','latex')
			ylabel('subjective time', 'interpreter','latex')
			box off
			axis square
            axis tight
		end
		
	end
	
	
	methods (Static, Access = protected)
		
		function y = function_evaluation(x, theta)
			if verLessThan('matlab','9.1')
                y = bsxfun(@power, ...
                        bsxfun(@times, theta.k, x),...
                        theta.tau);
			else
				% use new array broadcasting in 2016b
				y = (theta.k .* x) .^ theta.tau;
			end
		end
		
	end
	
	
end
