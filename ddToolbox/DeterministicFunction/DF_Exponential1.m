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
				obj.theta.(fieldnames{n}).addSamples( p.Results.samples.(fieldnames{n}) );
			end
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			
        end

		
        function plot(obj)
			x = [1:365];
			
			% don't plot if we've been given NaN's
			if any(isnan(obj.theta.k.samples))
				warning('Not plotting due to NaN''s')
				return
			end
			
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
        
        

        
%         function discountFraction = eval(obj, x, varargin)
%             % evaluate the discount fraction :
%             % - at the delays (x.delays)
%             % - given the onj.parameters
% 			
% 			p = inputParser;
% 			p.addRequired('x', @isnumeric);
% 			p.addParameter('nExamples', [], @isscalar);
% 			p.parse(x, varargin{:});
% 			
% 			n_samples_requested = p.Results.nExamples;
% 			n_samples_got = numel(obj.theta.k.samples);
% 			n_samples_to_get = min([n_samples_requested n_samples_got]);
% 			if ~isempty(n_samples_requested)
% 				% shuffle the deck and pick the top nExamples
% 				shuffledExamples = randperm(n_samples_to_get);
% 				ExamplesToPlot = shuffledExamples([1:n_samples_to_get]);
% 			else
% 				ExamplesToPlot = 1:n_samples_to_get;
% 			end
% 			
% 			if verLessThan('matlab','9.1')
% 				discountFraction = (bsxfun(@times,...
% 					exp( - obj.theta.k.samples(ExamplesToPlot)),...
% 					x) );
% 			else
% 				% use new array broadcasting in 2016b
% 				discountFraction = exp( - obj.theta.k.samples(ExamplesToPlot) .* x );
% 			end
% 		end
        
	end
	
	methods (Static, Access = protected)
		
		function y = function_evaluation(x, theta, ExamplesToPlot)
			if verLessThan('matlab','9.1')
				y = (bsxfun(@times,...
					exp( - theta.k.samples(ExamplesToPlot)),...
					x) );
			else
				% use new array broadcasting in 2016b
				y = exp( - theta.k.samples(ExamplesToPlot) .* x );
			end
		end
		
	end

end
