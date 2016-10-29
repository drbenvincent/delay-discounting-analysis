classdef (Abstract) DeterministicFunction
	%DeterministicFunction A class to deal with deterministic functions with parameters that we have a distribution of samples over.
	properties
		theta % Stochastic objects (or object array)
	end
	
	properties (SetAccess = protected, GetAccess = protected)

	end
	
	
	methods (Access = public)
		
		function obj = DeterministicFunction()
			theta = struct([]);
		end
		
		function obj = addSamples(obj, paramName, samples)
			obj.theta.(paramName).addSamples(samples);
		end
		
		function plotParameters(obj)
			
			fields = fieldnames(obj.theta);
			N = numel(fields);
			for n = 1:N
				%subplot(1,N,n) % TODO: work out best way to plot multiple
				%params
				% call the plot function of the stochastic variable
				obj.theta.(fields{n}).plot()
			end
			
		end
    end
    
    methods (Abstract)
		plot(obj)
		discountFraction = eval(obj, x)
    end
	
end
