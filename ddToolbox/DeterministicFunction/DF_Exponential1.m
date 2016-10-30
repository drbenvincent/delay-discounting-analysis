classdef DF_Exponential1 < DiscountFunction
	%DF_Exponential1 The classic 1-parameter discount function

	properties (Dependent)
		
	end
	
	methods (Access = public)

		function obj = DF_Exponential1(varargin)
			obj = obj@DiscountFunction();
			
			obj.theta.k = Stochastic('k');
			
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
			x = [1:365];
			
			% TODO
			discountFraction = obj.eval(x, 'nExamples', 100);
			
			try
				plot(x, discountFraction, '-', 'Color',[0.5 0.5 0.5 0.1])
			catch
				% backward compatability
				plot(x, discountFraction, '-', 'Color',[0.5 0.5 0.5])
			end
			
			xlabel('delay $D^B$', 'interpreter','latex')
			ylabel('discount factor', 'interpreter','latex')
			set(gca,'Xlim', [0 max(x)])
			box off
			axis square
		end
        
        

        
        function discountFraction = eval(obj, x, varargin)
            % evaluate the discount fraction :
            % - at the delays (x.delays)
            % - given the onj.parameters
			
			p = inputParser;
			p.addRequired('x', @isnumeric);
			p.addParameter('nExamples', [], @isscalar);
			p.parse(x, varargin{:});
			
			if ~isempty(p.Results.nExamples)
				% shuffle the deck and pick the top nExamples
				shuffledExamples = randperm(p.Results.nExamples);
				ExamplesToPlot = shuffledExamples([1:p.Results.nExamples]);
			else
				ExamplesToPlot = 1:numel(obj.theta.c.samples);
			end
			
			if verLessThan('matlab','9.1')
				discountFraction = (bsxfun(@times,...
					exp( - obj.theta.k.samples(ExamplesToPlot)),...
					x) );
			else
				% use new array broadcasting in 2016b
				discountFraction = exp( - obj.theta.k.samples(ExamplesToPlot) .* x );
			end
		end
        
	end

end
