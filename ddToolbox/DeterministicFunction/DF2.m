classdef DF2 < DiscountFunction
	%DF2
	
	methods (Access = public)
		
		function obj = DF2(varargin)
			obj = obj@DiscountFunction(varargin{:});
		end
		
		
		function plot(obj, pointEstimateType, dataPlotType, timeUnits, maxRewardValue, maxDelayValue)
			
			% 			maxRewardValue = 100;
			% 			maxDelayValue = 365;
			
			if verLessThan('matlab','9.1') % backward compatability
				timeUnitFunction = @(x) x; % do nothing
			else
				timeUnitFunction = str2func(timeUnits);
			end
			
			% don't plot if we've been given NaN's
			if any(isnan(obj.theta.m.samples))
				warning('Not plotting due to NaN''s')
				return
			end
			
			%% Calculate point estimates
			mcBivariate = mcmc.BivariateDistribution(...
				obj.theta.m.samples,...
				obj.theta.c.samples,...
				'shouldPlot',false,...
				'pointEstimateType', pointEstimateType);
			mc = mcBivariate.(pointEstimateType);
			m = mc(1);
			c = mc(2);
			
			
			%% x-axis = b
			% *** TODO: DOCUMENT WHAT THIS DOES ***
			nIndifferenceLines = 10;
			pow=1; while maxRewardValue > 10^pow; pow=pow+1; end
			logbvec=log(logspace(1, pow, nIndifferenceLines));
			
			%% y-axis = d
			dvec=linspace(0, maxDelayValue, 100);
			
			%% z-axis (AB)
			[logB,D] = meshgrid(logbvec,dvec); % create x,y (b,d) grid values
			k		= exp(m .* logB + c); % magnitude effect
			AB		= 1 ./ (1 + k.*D); % hyperbolic discount function
			B = exp(logB);
			
			%% PLOT
			hmesh = mesh(B,timeUnitFunction(D),AB);
			% shading
			hmesh.FaceColor		='interp';
			hmesh.FaceAlpha		=0.7;
			% edges
			hmesh.MeshStyle		='column';
			hmesh.EdgeColor		='k';
			hmesh.EdgeAlpha		=1;
			
			obj.formatAxes(pow)
			
			%% Overlay data
			% TODO: Fix this special case of their being no data (ie for
			% group level)
			if ~isempty(obj.data)
				obj.data.plot(dataPlotType, timeUnits);
			end
			
			drawnow
		end
	end
end
