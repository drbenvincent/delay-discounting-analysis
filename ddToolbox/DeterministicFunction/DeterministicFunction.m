classdef (Abstract) DeterministicFunction
	%DeterministicFunction A class to deal with deterministic functions with parameters that we have a distribution of samples over. The value of a deterministic function is determined by its parent's node values. In this implementation we have an explicitly separate list of parameters theta (ie Stochastic nodes) and fixed, observed data (here this is an object)
    
	properties         
		theta % Stochastic objects (or object array)
		
		% data is an object to store data associated with the function. It must have a plot method. 
        % TODO: at the moment this is only used to plot the data, and not to actually provide fixed input values to the function. Eg the values that we want to evaluate the expression for.
		data 
	end
	
	properties (Dependent)
		nSamples % Scalar. Number of samples we have
	end
	
	properties (Access = private)
		plot_options
	end
	
	
	methods
		
		function obj = DeterministicFunction(varargin)
			obj.plot_options = obj.set_plot_options(varargin{:});
			
			% Parse inputs ================================================
			p = inputParser;
			p.KeepUnmatched = true;
			p.StructExpand = false;
			p.addParameter('samples', struct(), @isstruct) % structure of Stochastics
			p.addParameter('data',[], @(x) isobject(x) | isempty(x) )
			p.parse(varargin{:});
			
			obj.theta = p.Results.samples;	
			obj.data = p.Results.data;
		end
		
		function obj = set.data(obj, dataObject)
			
			% deal with special case of group-level
			if isempty(dataObject)
				return
			end
			
			% adding a data object
			assert(isobject(dataObject), 'must provide an object as input')
			
			% confirm the provided object has a plot method
			methodsOfObject = methods(dataObject);
			hasPlotMethod = @() any(ismember(methodsOfObject, 'plot'));
			assert(hasPlotMethod() ,'Provided object must have a plot method')
			
			% set the property
			obj.data = dataObject;
		end
		
		function plotParameters(obj, pointEstimateType)
			
			fields = fieldnames(obj.theta);
			n_params = numel(fields);
			
			if n_params==1
				% plot univariate distribution
				obj.theta.(fields{:}).plot();
			elseif n_params==2
				% plot bivariate distribution
				
				varNames = fieldnames(obj.theta);
				
				% TODO: replace with new class
				mcmc.BivariateDistribution(...
					obj.theta.(varNames{1}).samples(:),...
					obj.theta.(varNames{2}).samples(:),...
					'xLabel', varNames{1},... % TODO: provide a proper label
					'ylabel', varNames{2},... % TODO: provide a proper label
					'pointEstimateType', pointEstimateType,...
					'plotStyle', 'hist',...
					'axisSquare', true);
			else
				error('not implemented plotting of >2 parameter dimensions')
			end
			
		end
		
		function y = eval(obj, xData, varargin)
			p = inputParser;
			p.addRequired('xData', @isnumeric);
			p.addParameter('nExamples', [], @isscalar);
			p.addParameter('pointEstimateType',[], @(x)any(strcmp(x,{'mean','median','mode'})));
			p.parse(xData, varargin{:});
			
            % Step 1) Determine which parameter values we want to use to evaluate the expression with. This is a hack workaround for efficiency. We could just evaluate for all theta values, it's just that this is wasteful if we only want to plot the function for the point estimate of the parameters, or just a random subset of parameters.
			theta_vals_to_evaluate = determineThetaValsToEvaluate();
			% BOTCH: this is being called with group level but for mixed
			% models. Ideally this will not even be called, but temp fix we
			% will abort if there are no samples.
			f = fields(theta_vals_to_evaluate);
			if isempty(theta_vals_to_evaluate.(f{1}))
				y=[];
				return
			end
			
            % Step 2) Actually evaluate the expression
			y = obj.function_evaluation(xData, theta_vals_to_evaluate);
			
            
			function thetaStruct = determineThetaValsToEvaluate()
				
				pointEstimateRequested = @() ~isempty(p.Results.pointEstimateType);
				
				if pointEstimateRequested()
					% loop over fields. TODO: use structfun, or make this not a structure
					thetaStruct = struct();
					for field = fields(obj.theta)'
						thetaStruct.(field{:}) = obj.theta.(field{:}).extractThetaPointEstimates(p.Results.pointEstimateType);
					end
				else
					examplesToPlot = getExamplesToPlot();
					% loop over fields. TODO: use structfun, or make this not a structure
					thetaStruct = struct();
					for field = fields(obj.theta)'
						thetaStruct.(field{:}) = obj.theta.(field{:}).extractTheseThetaSamples(examplesToPlot);
					end
				end
				
				
				function examplesToPlot = getExamplesToPlot()
					%% create a vector of indexes into the samples to evaluate
					n_samples_requested = p.Results.nExamples;
					n_samples_got = obj.nSamples;
					n_samples_to_get = min([n_samples_requested n_samples_got]);
					
					% shuffle the deck and pick the top nExamples
					shuffledExamples = randperm(n_samples_got);
					examplesToPlot = shuffledExamples([1:n_samples_to_get]);
				end
				
			end
			
		end
		

		function nSamples = get.nSamples(obj)
			% return the number of samples we have
		
			% loop over fields. TODO: use structfun, or make this not a structure
			f = fields(obj.theta);
			for n=1:numel(f)
				nSamples(n) = obj.theta.(f{n}).howManySamples();
			end
 			nSamples = nSamples(1);
		end
		
    end
    
    methods (Abstract)
		plot(obj);
		%discountFraction = eval(obj, x)
		%function_evaluation(obj);
	end
	
	methods (Abstract, Static, Access = protected)
		function_evaluation();
	end
	
	methods (Access = protected)
		
		function plot_options = set_plot_options(obj, varargin)
			p = inputParser;
			p.KeepUnmatched = true;
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
