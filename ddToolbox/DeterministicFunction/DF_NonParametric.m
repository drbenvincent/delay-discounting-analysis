classdef DF_NonParametric < DiscountFunction
	%DF_NonParametric The classic 1-parameter discount function

	properties (Dependent)
		
	end
	
	methods (Access = public)

		function obj = DF_NonParametric()
			obj = obj@DiscountFunction();
			
			obj.theta.discountRate = Stochastic('discountRate');
        end

		
        function plot(obj)
			x.delay = [1:365];
			
			% TODO
			discountFraction = obj.evalDiscountFraction(x);
			plot(x.delay, discountFraction', 'k')
			
			xlabel('delay $D^B$', 'interpreter','latex')
			ylabel('discount factor', 'interpreter','latex')
			
			set(gca,'Xlim', [0 max(x.delay)],...
				'box', 'off')
			
			axis square
		end
        
        

        
        function discountFraction = eval(obj, x)
            % % evaluate the discount fraction :
            % % - at the delays (x.delays)
            % % - given the onj.parameters
            % if verLessThan('matlab','9.1')
            % 	discountFraction = (bsxfun(@times,...
            %      exp( - obj.theta.k.samples),...
            %      x.delay) );
            % else
            % 	% use new array broadcasting in 2016b
            % 	discountFraction = exp( - obj.theta.k.samples .* x.delay );
            % end
        end
        
	end

end
