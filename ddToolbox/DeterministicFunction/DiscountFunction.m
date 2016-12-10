classdef (Abstract) DiscountFunction < DeterministicFunction
	%DiscountFunction
	
	methods (Access = public)
		
		function obj = DiscountFunction()
			obj = obj@DeterministicFunction();
		end
		
		
		function plot(obj, pointEstimateType)
			
			x = obj.determineDelayValues();
			
			%% don't plot if we've been given NaN's
			if obj.anyNaNsPresent()
				warning('Not plotting due to NaN''s')
				return
			end
			
			%% Plot N samples from posterior
			discountFraction = obj.eval(x, 'nExamples', 100);
			try
				plot(x, discountFraction, '-', 'Color',[0.5 0.5 0.5 0.1])
			catch
				% backward compatability
				plot(x, discountFraction, '-', 'Color',[0.5 0.5 0.5])
			end
			hold on
			
			%% Plot point estimate
			discountFraction = obj.eval(x, 'pointEstimateType', pointEstimateType);
			plot(x, discountFraction, '-',...
				'Color', 'k',...
				'LineWidth', 2)
			
			%% Formatting
			xlabel('delay $D^B$', 'interpreter','latex')
			ylabel('discount factor', 'interpreter','latex')
			set(gca,'Xlim', [0 max(x)])
			box off
			axis square
			
			%% Overlay data
			obj.data.plot()
		end
		
		function delayValues = determineDelayValues(obj)
			maxDelayRange = max( obj.data.getDelayRange() )*1.2;
			if isempty(maxDelayRange)
				% default (happens when there is no data, ie group level
				% observer).
				maxDelayRange = 365;
			end
			delayValues = linspace(0, maxDelayRange, 1000);
		end
		
		function nansPresent = anyNaNsPresent(obj)
			nansPresent = false;
			for field = fields(obj.theta)'
				if any(isnan(obj.theta.(field{:}).samples))
					nansPresent = true;
					warning('NaN''s detected in theta')
					break
				end
			end
		end
		
	end
	
	methods (Abstract)
		
		
		
	end
	
	
	
end
