classdef SubjectiveTimeWebber < DeterministicFunction
	%SubjectiveTimeWebber
	
	methods (Access = public)
		
		function obj = SubjectiveTimeWebber(varargin)
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
            % remove YTickLabel because:
            % subjective delay \propto f(objective delay)
            a = gca; a.YTickLabel = [];
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
                y = bsxfun(@times, ...
                    theta.S,...
                    log( 1 + bsxfun(@times, exp(theta.logk), x) ) );
			else
				% use new array broadcasting in 2016b
				y = theta.S .* log(1+ exp(theta.logk) .*x);
			end
		end
		
	end
	
	
end
