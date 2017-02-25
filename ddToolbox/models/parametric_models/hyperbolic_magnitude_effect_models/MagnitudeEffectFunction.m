classdef MagnitudeEffectFunction < DeterministicFunction
	%MagnitudeEffectFunction 
	
	properties (Access = public)
		maxRewardValue
	end
	
	methods (Access = public)
		
		function obj = MagnitudeEffectFunction(varargin)
            obj = obj@DeterministicFunction(varargin{:});
			
% 			obj.theta.m = Stochastic('m');
% 			obj.theta.c = Stochastic('c');
% 			
% 			% Input parsing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 			p = inputParser;
% 			p.StructExpand = false;
% 			p.KeepUnmatched = true;
% 			%p.addParameter('samples',struct(), @isstruct)
% 			p.addParameter('maxRewardValue', 100, @isscalar)
% 			p.parse(varargin{:});
% % 			
% % 			% Add any provided samples
% % 			fieldnames = fields(p.Results.samples);
% % 			for n = 1:numel(fieldnames)
% % 				obj.theta.(fieldnames{n}).addSamples( p.Results.samples.(fieldnames{n}) );
% % 			end
% % 			
% 			% Add other inputs to object
% 			obj.maxRewardValue = p.Results.maxRewardValue;
% % 			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		end
        
        function plot(obj)
            N_EXAMPLES_TO_PLOT = 100;
            
			% convert maxRewardValue to rounded up order of magnitude
			upperOrderOfMagnitude = ceil(log10(obj.maxRewardValue));
			
			% +1 to add some padding/extrapolation around actual data
			x = logspace(0, upperOrderOfMagnitude+1, 100);
			
			% don't plot if we've been given NaN's
			if any(isnan(obj.theta.m.samples))
				warning('Not plotting due to NaN''s')
				return
			end
			
			% when plotting, we don't want to evaluate and plot ALL samples
			% of the parameters. Instead we will randomly select some
            [k] = obj.eval(x, 'nExamples', N_EXAMPLES_TO_PLOT);
            
			try
				plot(x, k, '-', 'Color',[0.5 0.5 0.5 0.1])
			catch 
				% backward compatability
				plot(x, k, '-', 'Color',[0.5 0.5 0.5])
			end
			
            set(gca,'XScale','log')
            set(gca,'YScale','log')
			set(gca,'XTick',logspace(1,6,6))
			set(gca,'YTick',logspace(-4,0,5))
			axis tight
			
			xlabel('reward magnitude', 'interpreter','latex')
			ylabel('discount rate, $k$', 'interpreter','latex')
            %title('Magnitude Effect')
			
			box off
			axis square
		end
        
	end
	
		methods (Static, Access = protected)
		
		function k = function_evaluation(x, theta)
			% x = reward
            if verLessThan('matlab','9.1')
                logk = bsxfun(@plus, bsxfun(@times, theta.m, log(x)) , theta.c);
            else
                % use new array broadcasting in 2016b
                logk = (theta.m .* log(x)) + theta.c;
            end
            logk = logk';
            k = exp(logk);
		end
		
	end

	
end
