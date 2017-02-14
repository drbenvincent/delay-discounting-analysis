classdef (Abstract) DiscountFunction < DeterministicFunction
	%DiscountFunction
	
	properties
		%timeUnits % string
	end
	
	methods (Access = public)
		
		function obj = DiscountFunction(varargin)
			obj = obj@DeterministicFunction(varargin{:});
		end
		
		
		function plot(obj, pointEstimateType, dataPlotType, timeUnits)
			timeUnitFunction = str2func(timeUnits);
			N_SAMPLES_FROM_POSTERIOR = 100;
			
			delays = obj.getDelayValues();
			if verLessThan('matlab','9.1') % backward compatability
				delaysDuration = delays;
			else
				delaysDuration = timeUnitFunction(delays);
			end
			
			%% don't plot if we've been given NaN's
			if obj.anyNaNsPresent()
				warning('Not plotting due to NaN''s')
				return
			end
			
			%% Plot N samples from posterior
			discountFraction = obj.eval(delays, 'nExamples', N_SAMPLES_FROM_POSTERIOR);
			plot(delaysDuration,...
				discountFraction,...
				'-', 'Color',[0.5 0.5 0.5 0.1])
			hold on
			
			%% Plot point estimate
			discountFraction = obj.eval(delays, 'pointEstimateType', pointEstimateType);
			plot(delaysDuration,...
				discountFraction,...
				'-',...
				'Color', 'k',...
				'LineWidth', 2)
			
			%% Formatting
			xlabel('delay $D^B$', 'interpreter','latex')
			ylabel('discount factor', 'interpreter','latex')
			set(gca,'Xlim', [0 max(delaysDuration)])
			box off
			axis square
			
			%% Overlay data
			%TODO: fix this special-case check for group-level
			if ~isempty(obj.data)
				obj.data.plot(dataPlotType, timeUnits);
			end
			
			drawnow
		end
        	
	end
	
    
    methods (Access = private)

        function delayValues = getDelayValues(obj)
            % TODO: remove this stupid special-case handling of group-level
            % participant with no data
            try
                maxDelayRange = max( obj.data.getDelayRange() )*1.2;
            catch
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
    
end
