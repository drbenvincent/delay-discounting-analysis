classdef MagnitudeEffectFunction < DeterministicFunction
	%MagnitudeEffectFunction 
	
	methods (Access = public)
		
		function obj = MagnitudeEffectFunction()
            obj = obj@DeterministicFunction();
			
			obj.theta.m = Stochastic('m');
			obj.theta.c = Stochastic('c');
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
