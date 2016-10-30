classdef DF_Hyperbolic1 < DiscountFunction
	%Hyperbolic1 The classic 1-parameter discount function

	properties (Dependent)
		
	end
	
	methods (Access = public)

		function obj = DF_Hyperbolic1(varargin)
			obj = obj@DiscountFunction();
			
			obj.theta.logk = Stochastic('logk');
			
			
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
			x = [1:365];
			
			try
				plot(x, obj.eval(x)', '-', 'Color',[0.5 0.5 0.5 0.1])
			catch
				% backward compatability
				plot(x, obj.eval(x)', '-', 'Color',[0.5 0.5 0.5])
			end
			
			
			xlabel('delay $D^B$', 'interpreter','latex')
			ylabel('discount factor', 'interpreter','latex')
			set(gca,'Xlim', [0 max(x)])
			box off
			axis square
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
