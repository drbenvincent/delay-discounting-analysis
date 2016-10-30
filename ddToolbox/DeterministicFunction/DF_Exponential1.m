classdef DF_Exponential1 < DiscountFunction
	%DF_Exponential1 The classic 1-parameter discount function

	properties (Dependent)
		
	end
	
	methods (Access = public)

		function obj = DF_Exponential1(varargin)
			obj = obj@DiscountFunction();
			
			obj.theta.k = Stochastic('k');
			
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
			x.delay = [1:365];
			
			% TODO
			discountFraction = obj.eval(x);
			
			try
				plot(x.delay, discountFraction, '-', 'Color',[0.5 0.5 0.5 0.1])
			catch
				% backward compatability
				plot(x.delay, discountFraction, '-', 'Color',[0.5 0.5 0.5])
			end
			
			xlabel('delay $D^B$', 'interpreter','latex')
			ylabel('discount factor', 'interpreter','latex')
			set(gca,'Xlim', [0 max(x.delay)])
			box off
			axis square
		end
        
        

        
        function discountFraction = eval(obj, x)
            % evaluate the discount fraction :
            % - at the delays (x.delays)
            % - given the onj.parameters
            if verLessThan('matlab','9.1')
            	discountFraction = (bsxfun(@times,...
                 exp( - obj.theta.k.samples),...
                 x.delay) );
            else
            	% use new array broadcasting in 2016b
            	discountFraction = exp( - obj.theta.k.samples .* x.delay );
            end
        end
        
	end

end
