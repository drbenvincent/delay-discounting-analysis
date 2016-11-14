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
		
		function plot(obj)
			x = [-100:0.5:100];
			
			try
				plot(x, obj.eval(x, 'nExamples', 100), '-', 'Color',[0.5 0.5 0.5 0.1])
			catch
				% backward compatability
				plot(x, obj.eval(x, 'nExamples', 100), '-', 'Color',[0.5 0.5 0.5])
			end
			
			
			
			xlabel('$V^B-V^A$', 'interpreter','latex')
			ylabel('P(choose delayed)', 'interpreter','latex')
			%title('Psychometric function')
			box off
			axis square
		end
		
		%         function y = eval(obj, x, varargin)
		%
		% 			p = inputParser;
		% 			p.addRequired('x', @isnumeric);
		% 			p.addParameter('nExamples', [], @isscalar);
		% 			p.parse(x, varargin{:});
		%
		% 			if ~isempty(p.Results.nExamples)
		% 				% shuffle the deck and pick the top nExamples
		% 				shuffledExamples = randperm(p.Results.nExamples);
		% 				ExamplesToPlot = shuffledExamples([1:p.Results.nExamples]);
		% 			else
		% 				ExamplesToPlot = 1:numel(obj.theta.c.samples);
		% 			end
		%
		%             if verLessThan('matlab','9.1')
		%             	y = bsxfun(@plus,...
		%             		obj.theta.epsilon.samples(ExamplesToPlot),...
		%             		bsxfun(@times, ...
		%             		(1-2*obj.theta.epsilon.samples(ExamplesToPlot)),...
		%             		normcdf( bsxfun(@rdivide, x, obj.theta.alpha.samples(ExamplesToPlot) ) , 0, 1)) );
		%             else
		%             	% use new array broadcasting in 2016b
		%             	y = obj.theta.epsilon.samples(ExamplesToPlot)...
		% 					+ (1-2*obj.theta.epsilon.samples(ExamplesToPlot))...
		% 					.* normcdf( (x ./ obj.theta.alpha.samples(ExamplesToPlot)) , 0, 1);
		%             end
		%         end
		
	end
	
	
	methods (Static)
		
		function y = function_evaluation(x, theta, ExamplesToPlot)
			if verLessThan('matlab','9.1')
				y = bsxfun(@plus,...
					theta.epsilon.samples(ExamplesToPlot),...
					bsxfun(@times, ...
					(1-2*theta.epsilon.samples(ExamplesToPlot)),...
					normcdf( bsxfun(@rdivide, x, theta.alpha.samples(ExamplesToPlot) ) , 0, 1)) );
			else
				% use new array broadcasting in 2016b
				y = theta.epsilon.samples(ExamplesToPlot)...
					+ (1-2*theta.epsilon.samples(ExamplesToPlot))...
					.* normcdf( (x ./ theta.alpha.samples(ExamplesToPlot)) , 0, 1);
			end
		end
		
	end
	
	
end
