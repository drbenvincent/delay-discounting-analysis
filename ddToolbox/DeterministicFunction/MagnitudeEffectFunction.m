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
			
            [k, logk] = obj.eval(x);
            
			plot(x, k, 'k-')
            
            set(gca,'XScale','log')
            set(gca,'YScale','log')
			
			xlabel('reward magnitude', 'interpreter','latex')
			ylabel('discount rate, $k$', 'interpreter','latex')
            title('Magnitude Effect')
			
			box off
			axis square
		end
		
        function [k, logk] = eval(obj, x)			
			% x = reward
            if verLessThan('matlab','9.1')
                logk = bsxfun(@plus, bsxfun(@times, obj.theta.m.samples, log(x)) , obj.theta.c.samples);
            else
                % use new array broadcasting in 2016b
                logk = (obj.theta.m.samples .* log(x)) + obj.theta.c.samples;
            end
            logk = logk';
            k = exp(logk);
        end
        
    end

	
end
