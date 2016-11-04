classdef DF_SLICE_PsychometricFunction < DeterministicFunction
	%DF_SLICE_PsychometricFunction Model a psychometric function for a
	%given delay period, modelling the probability of choosing delayed
	%option given A/B
	
	methods (Access = public)
		
		function obj = DF_SLICE_PsychometricFunction(varargin)
			obj = obj@DeterministicFunction();
			
			% create Stochastic objects
			obj.theta.indifference = Stochastic('indifference');
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
				obj.theta.(fieldnames{n}).addSamples( p.Results.samples.(fieldnames{n}) )
			end
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		end
		
		function plot(obj)
			% 
			x = [0:0.01:3];
			
			try
				plot(x, obj.eval(x, 'nExamples', 100), '-', 'Color',[0.5 0.5 0.5 0.1])
			catch
				% backward compatability
				plot(x, obj.eval(x, 'nExamples', 100), '-', 'Color',[0.5 0.5 0.5])
			end
			
			axis tight
			ylim([0 1])
			vline(1)
			xlabel('reward ratio $(A/B)$', 'interpreter','latex')
			ylabel('P(choose delayed)', 'interpreter','latex')
			box off
		end
		

		
	end
	
	
	methods (Static)
		
		function y = function_evaluation(x, theta, ExamplesToPlot)
			
			alpha	= theta.alpha.samples(ExamplesToPlot);
			epsilon = theta.epsilon.samples(ExamplesToPlot);
			Rstar	= theta.indifference.samples(ExamplesToPlot);
			
			if verLessThan('matlab','9.1')
				error('check this is correct')
				y = bsxfun(@plus,...
					epsilon,...
					bsxfun(@times, ...
					(1-2*epsilon),...
					normcdf( bsxfun(@rdivide, x-Rstar, alpha ) , 0, 1)) );
			else
				% use new array broadcasting in 2016b
				y = epsilon + (1-2*epsilon)...
					.* (1- normcdf( ((x-Rstar) ./ alpha) , 0, 1));
			end
		end
		
	end
	
	
end
