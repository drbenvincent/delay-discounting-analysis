classdef DF_NonParametric < DiscountFunction
	%DF_NonParametric The classic 1-parameter discount function

	properties
		delays   % vector of delays
        AUC      % A Stochastic object
	end
	
	methods (Access = public)

		function obj = DF_NonParametric(varargin)
			obj = obj@DiscountFunction();
            
            % Input parsing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			p = inputParser;
			p.StructExpand = false;
			p.addParameter('delays',[], @isnumeric)
            p.addParameter('theta',[], @ismatrix)
			p.parse(varargin{:});
            
            obj.delays  = p.Results.delays;
            obj.theta   = p.Results.theta;
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            
			% We will estimate AUC
			obj.AUC = Stochastic('AUC');
        end

		
        function plot(obj)

            
            %% visualise the posterior predictive indifference points
			intervals = [50 95];
            ribbon_plot(obj.delays, obj.theta, intervals)
            hold on

            %% overlay behavioural data
            %plotDiscountingData(personInfo.data)

            %% formatting
            %title(personInfo.participantName)
            xlabel('delay')
            %axis square
            axis tight
            hline(1)
            set(gca,'YLim',[0 2.5])

            %% add AUC measure text to graph
            %auc_str = sprintf('mean AUC: %1.2f', mean(personInfo.AUCsamples));
            %addTextToFigure('TR',auc_str, 15, 'latex')


		end
        
        

        
        function discountFraction = eval(obj, x)
            % % evaluate the discount fraction :
            % % - at the delays (x.delays)
            % % - given the onj.parameters
            % if verLessThan('matlab','9.1')
            % 	discountFraction = (bsxfun(@times,...
            %      exp( - obj.theta.k.samples),...
            %      x.delay) );
            % else
            % 	% use new array broadcasting in 2016b
            % 	discountFraction = exp( - obj.theta.k.samples .* x.delay );
            % end
		end
		
		function calcAUC(obj)
			
		end
        
	end

end
