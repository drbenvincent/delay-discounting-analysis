classdef PsychometricFunction < DeterministicFunction
	%PsychometricFunction
	
	methods (Access = public)
		
		function obj = PsychometricFunction(varargin)
			obj = obj@DeterministicFunction();
			
			% create Stochastic objects
			obj.theta.alpha = Stochastic('alpha');
			obj.theta.epsilon = Stochastic('epsilon');
			
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
		
		function plot(obj, pointEstimateType)
			
			%% PLOT N SAMPLES
			x = [-100:0.5:100];
			try
				plot(x, obj.eval(x, 'nExamples', 100), '-', 'Color',[0.5 0.5 0.5 0.1])
			catch
				% backward compatability
				plot(x, obj.eval(x, 'nExamples', 100), '-', 'Color',[0.5 0.5 0.5])
			end
			
			hold on
			%% Plot point estimate
			discountFraction = obj.eval(x, 'pointEstimateType', pointEstimateType);
			plot(x, discountFraction, '-',...
				'Color', 'k',...
				'LineWidth', 2)
			
			%% Formatting
			xlabel('$V^B-V^A$', 'interpreter','latex')
			ylabel('P(choose delayed)', 'interpreter','latex')
			%title('Psychometric function')
			box off
			axis square
		end
		
	end
	
	
	methods (Static, Access = protected)
		
		function y = function_evaluation(x, theta)
			if verLessThan('matlab','9.1')
				y = bsxfun(@plus,...
					theta.epsilon,...
					bsxfun(@times, ...
					(1-2*theta.epsilon),...
					normcdf( bsxfun(@rdivide, x, theta.alpha ) , 0, 1)) );
			else
				% use new array broadcasting in 2016b
				y = theta.epsilon...
					+ (1-2*theta.epsilon)...
					.* normcdf( (x ./ theta.alpha) , 0, 1);
			end
		end
		
	end
	
	
end
