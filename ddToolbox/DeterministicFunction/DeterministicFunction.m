classdef (Abstract) DeterministicFunction
	%DeterministicFunction A class to deal with deterministic functions with parameters that we have a distribution of samples over.
	properties
		theta % Stochastic objects (or object array)
	end
	
	properties (Access = private)
		plot_options
	end
	
	
	methods (Access = public)
		
		function obj = DeterministicFunction(varargin)
			theta = struct([]);
			obj.plot_options = obj.set_plot_options(varargin{:});
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
	
	methods (Access = protected)
		
		function plot_options = set_plot_options(obj, varargin )
			p = inputParser;
			p.addParameter('plotStyle','hist',@(x)any(strcmp(x,{'hist','kde'})))
			p.addParameter('shouldPlot',true,@islogical);
			%p.addParameter('killYAxis',true,@islogical);
			p.addParameter('priorCol',[0.8 0.8 0.8],@isvector);
			p.addParameter('col',[0.6 0.6 0.6],@isvector);
			p.addParameter('shouldPlotPointEstimate',false,@islogical);
			p.addParameter('FaceAlpha',0.2,@isscalar);
			p.addParameter('patchProperties',{'FaceAlpha',0.8},@iscell);
			%p.addParameter('plotHDI',true,@islogical);
			p.addParameter('axisSquare',false,@islogical);
			
			p.parse(varargin{:});
			
			plot_options = p.Results;
		end
		
		function formatAxes(obj)
			
			% 			if obj.plot_options.killYAxis
			% 				mcmc.removeYaxis()
			% 			end
			%
			% 			if obj.plot_options.plotHDI
			% 				for n=1:obj.N
			% 					mcmc.showHDI(obj.samples(:,n))
			% 				end
			% 			end
			
			box off
			axis tight
			if obj.plot_options.axisSquare, axis square, end
			set(gca,'TickDir','out')
			set(gca,'Layer','top');
			xlabel(obj.name, 'interpreter', 'latex')
		end
		
	end
end
