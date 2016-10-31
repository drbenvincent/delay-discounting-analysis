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
			
			% don't plot if we've been given NaN's
			if any(isnan(obj.theta.m.samples))
				warning('Not plotting due to NaN''s')
				return
			end
			
			pointEstimateType = 'median'
			
			%% Calculate point estimates
			mcBivariate = mcmc.BivariateDistribution(...
				obj.theta.m.samples,...
				obj.theta.c.samples,...
				'shouldPlot',false,...
				'pointEstimateType', pointEstimateType);
			mc = mcBivariate.(pointEstimateType);
			m = mc(1);
			c = mc(2);
            
			
			% 					try
			% 			maxlogB = max( abs( plotdata.data.rawdata.B) );
			% 			maxD = max(plotdata.data.rawdata.DB);
			% 		catch
			maxlogB = 100;
			maxD = 365;
			% 					end
		
					
			
			%% x-axis = b
			% *** TODO: DOCUMENT WHAT THIS DOES ***
			nIndifferenceLines = 10;
			pow=1; while maxlogB > 10^pow; pow=pow+1; end
			logbvec=log(logspace(1, pow, nIndifferenceLines));
			
			%% y-axis = d
			dvec=linspace(0, maxD, 100);
			
			%% z-axis (AB)
			[logB,D] = meshgrid(logbvec,dvec); % create x,y (b,d) grid values
			k		= exp(m .* logB + c); % magnitude effect
			AB		= 1 ./ (1 + k.*D); % hyperbolic discount function
			B = exp(logB);
			
			%% PLOT
			hmesh = mesh(B,D,AB);
			% shading
			hmesh.FaceColor		='interp';
			hmesh.FaceAlpha		=0.7;
			% edges
			hmesh.MeshStyle		='column';
			hmesh.EdgeColor		='k';
			hmesh.EdgeAlpha		=1;
			
			
			obj.formatAxes(pow)
		end
        
        

        
	end
    
    methods (Access = protected)
    
        % NOTE: this is the function we want to use in order to calculate discount rate, for a given reward magnitude
       
		% TODO: THIS SHOULD BE DONE WITH A MagnitudeEffectFunction OBJECT
        function [k,logk] = magnitudeEffect(obj, reward)
			error('who is calling me')  % TODO: ARE WE EVER CALLING THIS?
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
		
		
		function formatAxes(obj, pow)
			box off
			view([-45, 34])
			axis vis3d
			axis tight
			axis square
			zlim([0 1])
			set(gca,'YDir','reverse')
			set(gca,'XScale','log')
			set(gca,'XTick',logspace(1,pow,pow-1+1))
			
			xlabel('$|reward|$', 'interpreter','latex')
			ylabel('delay $D^B$', 'interpreter','latex')
			zlabel('discount factor', 'interpreter','latex')
		end
		
	end
	
	
	methods (Static)
		
		function logk = function_evaluation(x, theta, ExamplesToPlot)
			if verLessThan('matlab','9.1')
				logk = bsxfun(@plus, bsxfun(@times, theta.m.samples(ExamplesToPlot), log(x)) , theta.c.samples(ExamplesToPlot));
			else
				% use new array broadcasting in 2016b
				logk = theta.m.samples(ExamplesToPlot) * log(x) + theta.c.samples(ExamplesToPlot);
			end
			%k = exp(logk);
		end
		
	end
	
	
end
