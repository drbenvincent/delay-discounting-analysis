classdef MagnitudeEffectFunction < DeterministicFunction
	%MagnitudeEffectFunction 
	
	methods (Access = public)
		
		function obj = MagnitudeEffectFunction(varargin)
            obj = obj@DeterministicFunction();
			
			obj.theta.m = Stochastic('m');
			obj.theta.c = Stochastic('c');
			
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
			x = logspace(0,3,100);
			
			% when plotting, we don't want to evaluate and plot ALL samples
			% of the parameters. Instead we will randomly select some
			
            [k, logk] = obj.eval(x, 'nExamples', 100);
            
			try
				plot(x, k, '-', 'Color',[0.5 0.5 0.5 0.1])
			catch 
				% backward compatability
				plot(x, k, '-', 'Color',[0.5 0.5 0.5])
			end
			
						
			
            
            set(gca,'XScale','log')
            set(gca,'YScale','log')
			axis tight
			
			xlabel('reward magnitude', 'interpreter','latex')
			ylabel('discount rate, $k$', 'interpreter','latex')
            %title('Magnitude Effect')
			
			box off
			axis square
		end
		
        function [k, logk] = eval(obj, x, varargin)
			
			p = inputParser;
			p.addRequired('x', @isnumeric);
			p.addParameter('nExamples', [], @isscalar);
			p.parse(x, varargin{:});
			
			if ~isempty(p.Results.nExamples)
				% shuffle the deck and pick the top nExamples
				shuffledExamples = randperm(p.Results.nExamples);
				ExamplesToPlot = shuffledExamples([1:p.Results.nExamples]);
			else
				ExamplesToPlot = 1:numel(obj.theta.c.samples);
			end

			% x = reward
            if verLessThan('matlab','9.1')
                logk = bsxfun(@plus, bsxfun(@times, obj.theta.m.samples(ExamplesToPlot), log(x)) , obj.theta.c.samples(ExamplesToPlot));
            else
                % use new array broadcasting in 2016b
                logk = (obj.theta.m.samples(ExamplesToPlot) .* log(x)) + obj.theta.c.samples(ExamplesToPlot);
            end
            logk = logk';
            k = exp(logk);
        end
        
    end

	
end
