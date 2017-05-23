classdef DF_SLICE_PsychometricFunction < DeterministicFunction
	%DF_SLICE_PsychometricFunction Model a psychometric function for a
	%given delay period, modelling the probability of choosing delayed
	%option given A/B
	
	methods (Access = public)
		
		function obj = DF_SLICE_PsychometricFunction(varargin)
			obj = obj@DeterministicFunction(varargin{:});
		end
		
		function plot(obj)
			% 
			%x = [-2:0.01:2];
			x = [0:0.01:2];
            
			try
				plot(x, obj.eval(x, 'nExamples', 100), '-', 'Color',[0.5 0.5 0.5 0.1])
			catch
				% backward compatability
				plot(x, obj.eval(x, 'nExamples', 100), '-', 'Color',[0.5 0.5 0.5])
			end
			
			axis tight
			ylim([0 1])
			%vline(0); xlabel('reward ratio $\log(A/B)$', 'interpreter','latex')
			vline(1); xlabel('reward ratio $A/B$', 'interpreter','latex')
			%vline(0); xlabel('reward ratio $A-B$', 'interpreter','latex')
			ylabel('P(choose delayed)', 'interpreter','latex')
			box off
		end
		

		
	end
	
	
	methods (Static, Access = protected)
		
		function y = function_evaluation(x, theta, ExamplesToPlot)
			
			% TODO: DOUBLE CHECK THIS EQUATION IS SAME AS IN JAGS FILE
			alpha	= theta.alpha;
			epsilon = theta.epsilon;
			Rstar	= theta.indifference;
			
			if verLessThan('matlab','9.1')
				y = bsxfun(@plus,...
					epsilon,...
					bsxfun(@times, ...
					(1-2*epsilon),...
					normcdf( bsxfun(@rdivide, bsxfun(@minus, x, Rstar), alpha ) , 0, 1)) );
			else
				% use new array broadcasting in 2016b
				y = epsilon + (1-2*epsilon)...
					.* (1- normcdf( ((x-Rstar) ./ alpha) , 0, 1));
			end
		end
		
	end
	
	
end
