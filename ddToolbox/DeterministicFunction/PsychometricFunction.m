classdef PsychometricFunction < DeterministicFunction
	%PsychometricFunction 
	
	methods (Access = public)
		
		function obj = PsychometricFunction(varargin)
            obj = obj@DeterministicFunction();
			
			% create Stochastic objects
			obj.theta.alpha = Stochastic('alpha');
			obj.theta.epsilon = Stochastic('epsilon');
			
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
			x = [-100:0.5:100];
			
			try
				plot(x, obj.eval(x), '-', 'Color',[0.5 0.5 0.5 0.1])
			catch 
				% backward compatability
				plot(x, obj.eval(x), '-', 'Color',[0.5 0.5 0.5])
			end
			
			
			
			xlabel('$V^B-V^A$', 'interpreter','latex')
			ylabel('P(choose delayed)', 'interpreter','latex')
            %title('Psychometric function')
			box off
			axis square
		end
		
        function y = eval(obj, x)
            if verLessThan('matlab','9.1')
            	y = bsxfun(@plus,...
            		obj.theta.epsilon.samples,...
            		bsxfun(@times, ...
            		(1-2*obj.theta.epsilon.samples),...
            		normcdf( bsxfun(@rdivide, x, obj.theta.alpha.samples ) , 0, 1)) );
            else
            	% use new array broadcasting in 2016b
            	y = obj.theta.epsilon.samples + (1-2*obj.theta.epsilon.samples) .* normcdf( (x ./ obj.theta.alpha.samples) , 0, 1);
            end
        end
        
    end

	
end
