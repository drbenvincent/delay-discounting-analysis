classdef DF_NonParametric < DiscountFunction
	%DF_NonParametric The classic 1-parameter discount function

	
	% TODO: I'm not convinced that this is the right place in the
	% inheritance hierarchy... the non-parametric functions don't have an
	% eval() method in the same way that the parametric discount functions
	% do.
	properties
		delays   % vector of delays
        AUC      % A Stochastic object
		timeUnits = 'days' %<------------------- TODO: inject this
	end
	
	methods (Access = public)

		function obj = DF_NonParametric(varargin)
			obj = obj@DiscountFunction(varargin{:});
            
            % Input parsing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            % TODO: Currently construction of this class (DF_NonParametric) is dealt with differently from all the parametric modes (eg DF_ExponentialPower)
            % TODO: Do we need an additional DF_NonParametric in the inheritance hierarchy??
			p = inputParser;
            p.KeepUnmatched = true;
			p.StructExpand = false;
			p.addParameter('delays',[], @isnumeric);
            p.addParameter('theta',[], @ismatrix);
			p.parse(varargin{:});
            
            obj.delays  = p.Results.delays;
            obj.theta   = p.Results.theta;
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            
			% We will estimate AUC
			AUC_samples = obj.calcAUC();
            
			% create AUC as a Stochastic object
            % TODO: this violates dependency injection, so we may want to pass these Stochastic objects in
			obj.AUC = Stochastic('AUC');
			obj.AUC.addSamples(AUC_samples);
        end

		
        function plot(obj)
			% visualise the discount function
			SAMPLES_TO_PLOT = 100;
            timeUnitFunction = str2func(obj.timeUnits);
			
            %% RIBBON PLOT
			%intervals = [50 95]; %<----------- TODO: inject this
            %ribbon_plot(obj.delays, obj.theta, intervals); % TODO: replace, or inject the plot style we want
           
            %% PLOT N EXAMPLES
			% dont ask for more samples than we actually have
			samples_to_plot = [1:min(SAMPLES_TO_PLOT, size(obj.theta,1))];
% 			% convert logAoverB (what we fitted) to A/B (what we plot
% 			logAoverB = obj.theta(samples_to_plot,:);
% 			AoverB = exp(logAoverB);

			AoverB = obj.theta(samples_to_plot,:);
			
            plot(timeUnitFunction(obj.delays),...
				AoverB,...
				'Color',[0 0 0 0.05])
            hold on
			
			%% Plot data
			dataPlotType = '2D';  %<----------- TODO: inject this
			obj.data.plot(dataPlotType, obj.timeUnits);
			% ~~~~~~~~~~~~~
            
            %% formatting
            %title(personInfo.participantName)
            xlabel('delay')
            axis square
            axis tight
            hline(1);
            set(gca,'YLim',[0 2.5])
			box off

            %% add AUC measure text to graph
            %auc_str = sprintf('mean AUC: %1.2f', mean(personInfo.AUCsamples));
            %addTextToFigure('TR',auc_str, 15, 'latex')
		end
        
		
		
		function Z = calcAUC(obj)
			
			x = obj.delays;
			y = obj.theta;
			
% 			% convert from log(A/B) to A/B
% 			y = exp(y);
			
			% Calculate the trapezoidal area under curve. NOTE: Normalized x-axis.
			
			assert(isrow(x), 'x must be a row vector, ie [1, N]')
			assert(size(y,2)==numel(x),'y must have same number of columns as x')
			
			%% Add new column representing (delay=0, discount fraction=1)
			nCols = size(y,1);
			x = [0 x];
			y = [ones(nCols,1) , y];
			
			%% Normalise x
			x = x ./ max(x);
			
			%% Calculate trapezoidal AUC
			Z = zeros(nCols,1);
			for s=1:nCols
				Z(s) = trapz(x,y(s,:));
			end
	
		end
		
	end
	
	methods (Static, Access = protected)
		
		function function_evaluation()
		end
		
	end

end
