classdef DF_HyperbolicMagnitudeEffect < DF_Hyperbolic1
	%HyperbolicMagnitudeEffect The classic 1-parameter discount function, but where

	
	properties
	end
	
	methods (Access = public)

		function obj = DF_HyperbolicMagnitudeEffect(varargin)
			obj = obj@DF_Hyperbolic1();
			
			obj.theta = []; % clear anything from superclass
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
			x.delay = [1:365];
			x.reward = [10:100:1000];
            
			% TODO
			%discountFraction = obj.evalDiscountFraction(x);
			%plot(x.delay, discountFraction', 'k')
			
			xlabel('$|reward|$', 'interpreter','latex')
			ylabel('delay $D^B$', 'interpreter','latex')
			zlabel('discount factor', 'interpreter','latex')
			
			title('** discount surface here **')
			box off
		end
        
        
        function discountFraction = eval(obj, x) 
            % When we evaluate, we want to know the discount fraction.
            % Because this is the 1-parameter hyperbolic discount function,
            % we need to calculate 
            
			
			% Step 1: calculate discount rates, using the
			% MagnitudeEffectFunction class
			
			me = MagnitudeEffectFunction();
			me.addSamples('m', obj.theta.m.samples )
			me.addSamples('c', obj.theta.c.samples )
			
			rewards = logspace(0,3,100);
			[k, logk] = me.eval(rewards)

			
			% TODO...
            
            % Calculate discount fraction
        end
        
	end
    
    methods (Access = private)
    
        % NOTE: this is the function we want to use in order to calculate discount rate, for a given reward magnitude
        
        function [k,logk] = magnitudeEffect(obj, reward)
            if verLessThan('matlab','9.1')
                logk = bsxfun(@plus, bsxfun(@times, paramValues.m,log(reward)) , paramValues.c);
            else
                % use new array broadcasting in 2016b
                logk = paramValues.m * log(reward) + paramValues.c;
            end
            k = exp(logk);
        end
        
        % function logk = calcLogK_conditional_upon_reward(obj, reward)
        %     [~,logk] = magnitudeEffect(obj, reward)
        % end
    end

end
