classdef (Abstract) DF2 < DiscountFunction
	%DF2
	
	methods (Access = public)
		
		function obj = DF2(varargin)
			obj = obj@DiscountFunction(varargin{:});
		end
		
		
		% TODO: contents of this function is NOT generic to all 2D discount
		% surfaces. It contains lots of code specific to Hyperbolic +
		% magnitude discounting
		function plot(obj, plotOptions)
			
			if verLessThan('matlab','9.1') % backward compatability
				timeUnitFunction = @(x) x; % do nothing
			else
				timeUnitFunction = str2func(plotOptions.timeUnits);
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
				'pointEstimateType', plotOptions.pointEstimateType);
			mc = mcBivariate.(plotOptions.pointEstimateType);
			m = mc(1);
			c = mc(2);
			
			%% Calculate (X,Y,Z) 2D matricies for plotting --------------
			
			% x-axis = reward
			nLines = 10;
			logRewardVector = calcLogRewardVector(nLines, plotOptions.maxRewardValue);
			
			% y-axis = delays
			delayVector = linspace(0, plotOptions.maxDelayValue, 100);
			
			% calculate 2D matricies
			[logB, delayMatrix] = meshgrid(logRewardVector,delayVector); % create x,y (b,d) grid values
			rewardMatrix = exp(logB);
			
			k = exp(m .* logB + c); % magnitude effect
			discountFractionMatrix = 1 ./ (1 + k.*delayMatrix); % hyperbolic discount function
			% -------------------------------------------------------------
			
			
			%% PLOT -------------------------------------------------------
			hmesh = mesh(rewardMatrix, timeUnitFunction(delayMatrix), discountFractionMatrix);
			% shading
			hmesh.FaceColor		='interp';
			hmesh.FaceAlpha		=0.7;
			% edges
			hmesh.MeshStyle		='column';
			hmesh.EdgeColor		='k';
			hmesh.EdgeAlpha		=1;
			
			obj.formatAxes( calcOrderOfMagnitude(plotOptions.maxRewardValue) )
			%set(gca,'XLim',[0 maxRewardValue])
			
			%% Overlay data
			% TODO: Fix this special case of their being no data (ie for
			% group level)
			if ~isempty(obj.data)
				obj.data.plot(plotOptions.dataPlotType, plotOptions.timeUnits);
			end

			drawnow
			
		end
        
        function AUC = calcAUC(~, ~)
            % Currently not calculating AUC for 2D discount functions (eg Magnitude Effect)
            
			% return an empty Stochastic object
			AUC = Stochastic('AUC');
        end
        
	end
end

function orderOfMagnitude = calcOrderOfMagnitude(maxRewardValue)
% Calculate the order of magnitude which contains all the
% rewards
orderOfMagnitude = 1;
while maxRewardValue > 10^orderOfMagnitude
	orderOfMagnitude = orderOfMagnitude+1;
end
end

function logRewardVector = calcLogRewardVector(nIndifferenceLines, maxRewardValue)
orderOfMagnitude = calcOrderOfMagnitude(maxRewardValue);
logRewardVector=log(logspace(1, orderOfMagnitude, nIndifferenceLines));
end
