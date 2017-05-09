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
        
        function Z = calcAUC(obj)
            Z=[];
            
% 			x = obj.delays;
% 			y = obj.theta;
% 			
% % 			% convert from log(A/B) to A/B
% % 			y = exp(y);
% 			
% 			% Calculate the trapezoidal area under curve. NOTE: Normalized x-axis.
% 			
% 			assert(isrow(x), 'x must be a row vector, ie [1, N]')
% 			assert(size(y,2)==numel(x),'y must have same number of columns as x')
% 			
% 			%% Add new column representing (delay=0, discount fraction=1)
% 			nCols = size(y,1);
% 			x = [0 x];
% 			y = [ones(nCols,1) , y];
% 			
% 			%% Normalise x
% 			x = x ./ max(x);
% 			
% 			%% Calculate trapezoidal AUC
% 			Z = zeros(nCols,1);
% 			for s=1:nCols
% 				Z(s) = trapz(x,y(s,:));
% 			end
    
        end
        
    end
end
