classdef (Abstract) DF1 < DiscountFunction
	%DF1
	
	properties
		% AUC % A Stochastic object
	end
	
	methods (Access = public)
		
		function obj = DF1(varargin)
			obj = obj@DiscountFunction(varargin{:});
			
			% % We will estimate AUC
			% AUC_samples = obj.calcAUC();
			%
			% % create AUC as a Stochastic object
			% % TODO: this violates dependency injection, so we may want to pass these Stochastic objects in
			% obj.AUC = Stochastic('AUC');
			% obj.AUC.addSamples(AUC_samples);
		end
		
		
		function plot(obj, plotOptions)
			
			timeUnitFunction = str2func(plotOptions.timeUnits);
			N_SAMPLES_FROM_POSTERIOR = 100;
			
			delays = obj.getDelayValues();
			if verLessThan('matlab','9.1') % backward compatability
				delaysDuration = delays;
			else
				delaysDuration = timeUnitFunction(delays);
			end
			
			switch plotOptions.plotMode
				case{'point_estimate_only'}
					%% Plot point estimate
					discountFraction = obj.eval(delays, 'pointEstimateType', plotOptions.pointEstimateType);
					plot(delaysDuration,...
						discountFraction,...
						'-',...
						'Color', 'k',...
						'LineWidth', 2)
					
				case{'full'}
					%             %% don't plot if we've been given NaN's
					%             if obj.anyNaNsPresent()
					%                 warning('Not plotting due to NaN''s')
					%                 return
					%             end
					
					%% Plot N samples from posterior
					discountFraction = obj.eval(delays, 'nExamples', N_SAMPLES_FROM_POSTERIOR);
					plot(delaysDuration,...
						discountFraction,...
						'-', 'Color',[0.5 0.5 0.5 0.1])
					hold on
					
					%% Plot point estimate
					discountFraction = obj.eval(delays, 'pointEstimateType', plotOptions.pointEstimateType);
					plot(delaysDuration,...
						discountFraction,...
						'-',...
						'Color', 'k',...
						'LineWidth', 2)
					
					%% Overlay data
					%TODO: fix this special-case check for group-level
					if ~isempty(obj.data)
						obj.data.plot(plotOptions.dataPlotType, plotOptions.timeUnits);
					end
			end
			
			%% Formatting
			xlabel('delay $D^B$', 'interpreter','latex')
			ylabel('discount factor', 'interpreter','latex')
			set(gca,'Xlim', [0 max(delaysDuration)])
			box off
			axis square
			
			drawnow
		end
		
		function AUC = calcAUC(obj, MAX_DELAY, ~)
			% calculate area under curve
			% returns a distribution over AUC, as a Stochastic object
			
			x = [0:1:MAX_DELAY];
			y = obj.eval(x);
			
			%% Normalise x, so that AUC is scaled between 0-1
			x = x ./ max(x);
			
			%% Calculate trapezoidal AUC
			% preallocate
			Z = zeros(obj.nSamples,1);
			% Calcul AUC for each sample
			for s = 1:obj.nSamples
				Z(s) = trapz(x,y(s,:));
			end
			
			%% Return as a Stochastic object
			AUC = Stochastic('AUC');
			AUC.addSamples(Z);
		end
		
	end
end
