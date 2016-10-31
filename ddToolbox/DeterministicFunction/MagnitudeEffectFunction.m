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
			
			% don't plot if we've been given NaN's
			if any(isnan(obj.theta.m.samples))
				warning('Not plotting due to NaN''s')
				return
			end
			
			
			% when plotting, we don't want to evaluate and plot ALL samples
			% of the parameters. Instead we will randomly select some
			
            [k] = obj.eval(x, 'nExamples', 100);
            
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
		
%         function [k, logk] = eval(obj, x, varargin)
% 			
% 			p = inputParser;
% 			p.addRequired('x', @isnumeric);
% 			p.addParameter('nExamples', [], @isscalar);
% 			p.parse(x, varargin{:});
% 			
% 			n_samples_requested = p.Results.nExamples;
% 			n_samples_got = numel(obj.theta.c.samples);
% 			n_samples_to_get = min([n_samples_requested n_samples_got]);
% 			if ~isempty(n_samples_requested)
% 				% shuffle the deck and pick the top nExamples
% 				shuffledExamples = randperm(n_samples_requested);
% 				ExamplesToPlot = shuffledExamples([1:n_samples_to_get]);
% 			else
% 				ExamplesToPlot = 1:n_samples_to_get;
% 			end
% 
% 			% x = reward
%             if verLessThan('matlab','9.1')
%                 logk = bsxfun(@plus, bsxfun(@times, obj.theta.m.samples(ExamplesToPlot), log(x)) , obj.theta.c.samples(ExamplesToPlot));
%             else
%                 % use new array broadcasting in 2016b
%                 logk = (obj.theta.m.samples(ExamplesToPlot) .* log(x)) + obj.theta.c.samples(ExamplesToPlot);
%             end
%             logk = logk';
%             k = exp(logk);
%         end
        
	end
	
		methods (Static)
		
		function k = function_evaluation(x, theta, ExamplesToPlot)
			% x = reward
            if verLessThan('matlab','9.1')
                logk = bsxfun(@plus, bsxfun(@times, theta.m.samples(ExamplesToPlot), log(x)) , theta.c.samples(ExamplesToPlot));
            else
                % use new array broadcasting in 2016b
                logk = (theta.m.samples(ExamplesToPlot) .* log(x)) + theta.c.samples(ExamplesToPlot);
            end
            logk = logk';
            k = exp(logk);
		end
		
	end

	
end
