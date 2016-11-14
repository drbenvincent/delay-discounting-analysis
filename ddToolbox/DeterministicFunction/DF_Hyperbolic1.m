classdef DF_Hyperbolic1 < DiscountFunction
	%Hyperbolic1 The classic 1-parameter discount function
	
	properties (Dependent)
		
	end
	
	methods (Access = public)
		
		function obj = DF_Hyperbolic1(varargin)
			obj = obj@DiscountFunction();
			
			obj.theta.logk = Stochastic('logk');
			
			
			% Input parsing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			p = inputParser;
			p.StructExpand = false;
			p.addParameter('samples',struct(), @isstruct)
			p.parse(varargin{:});
			
			fieldnames = fields(p.Results.samples);
			% Add any provided samples
			for n = 1:numel(fieldnames)
				obj.theta.(fieldnames{n}).addSamples( p.Results.samples.(fieldnames{n}) );
			end
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			
		end
		
		
		function plot(obj)
			x = [1:365];
			
			% don't plot if we've been given NaN's
			if any(isnan(obj.theta.logk.samples))
				warning('Not plotting due to NaN''s')
				return
			end
			
			try
				plot(x, obj.eval(x, 'nExamples', 100)', '-', 'Color',[0.5 0.5 0.5 0.1])
			catch
				% backward compatability
				plot(x, obj.eval(x, 'nExamples', 100)', '-', 'Color',[0.5 0.5 0.5])
			end
			
			
			xlabel('delay $D^B$', 'interpreter','latex')
			ylabel('discount factor', 'interpreter','latex')
			set(gca,'Xlim', [0 max(x)])
			box off
			axis square
		end
		
		
		
		
		%         function discountFraction = eval(obj, x, varargin)
		%
		% 			p = inputParser;
		% 			p.addRequired('x', @isnumeric);
		% 			p.addParameter('nExamples', [], @isscalar);
		% 			p.parse(x, varargin{:});
		%
		% 			n_samples_requested = p.Results.nExamples;
		% 			n_samples_got = numel(obj.theta.logk.samples);
		% 			n_samples_to_get = min([n_samples_requested n_samples_got]);
		% 			if ~isempty(n_samples_requested)
		% 				% shuffle the deck and pick the top nExamples
		% 				shuffledExamples = randperm(n_samples_requested);
		% 				ExamplesToPlot = shuffledExamples([1:n_samples_to_get]);
		% 			else
		% 				ExamplesToPlot = 1:n_samples_to_get;
		% 			end
		%
		% 			% evaluate the discount fraction :
		% 			% - at the delays (x.delays)
		% 			% - given the onj.parameters
		% 			if verLessThan('matlab','9.1')
		% 				discountFraction = bsxfun(@rdivide, 1, 1 + (bsxfun(@times, exp(obj.theta.logk.samples(ExamplesToPlot)), x.delay) ) );
		% 			else
		% 				% use new array broadcasting in 2016b
		% 				discountFraction = 1 ./ (1 + exp(obj.theta.logk.samples(ExamplesToPlot)) .* x);
		% 			end
		% 		end
		
	end
	
	
	methods (Static, Access = protected)
		
		function y = function_evaluation(x, theta, ExamplesToPlot)
			if verLessThan('matlab','9.1')
				y = bsxfun(@rdivide, 1, 1 + (bsxfun(@times, exp(theta.logk.samples(ExamplesToPlot)), x.delay) ) );
			else
				% use new array broadcasting in 2016b
				y = 1 ./ (1 + exp(theta.logk.samples(ExamplesToPlot)) .* x);
			end
		end
		
	end
	
	
end
