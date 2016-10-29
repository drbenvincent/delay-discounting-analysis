classdef DF_Hyperbolic1 < DiscountFunction
	%Hyperbolic1 The classic 1-parameter discount function

	properties (Dependent)
		
	end
	
	methods (Access = public)

		function obj = DF_Hyperbolic1()
			obj = obj@DiscountFunction();
			
			obj.theta.logk = Stochastic('logk');
        end

		
        function plot(obj)
			x = [1:365];
			
			% TODO
			plot(x, obj.eval(x)', 'k-')
			
			xlabel('delay $D^B$', 'interpreter','latex')
			ylabel('discount factor', 'interpreter','latex')
		end
        
        

        
        function discountFraction = eval(obj, x)
            % evaluate the discount fraction :
            % - at the delays (x.delays)
            % - given the onj.parameters
            if verLessThan('matlab','9.1')
            	discountFraction = bsxfun(@rdivide, 1, 1 + (bsxfun(@times, exp(obj.theta.logk.samples), x.delay) ) );
            else
            	% use new array broadcasting in 2016b
            	discountFraction = 1 ./ (1 + exp(obj.theta.logk.samples) .* x);
            end
        end
        
	end

end
