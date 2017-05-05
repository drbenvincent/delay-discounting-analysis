classdef (Abstract) DeterministicFunction
	%DeterministicFunction A class to deal with deterministic functions with parameters that we have a distribution of samples over.
	properties
		theta % Stochastic objects (or object array)
		% TODO: theta samples should be a Table !
		
		% This is Object to store data associated with the function. It
		% must have a plot method
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
			
			% deal with speecial case of group-level
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
		
		function y = eval(obj, x, varargin)
			p = inputParser;
			p.addRequired('x', @isnumeric);
			p.addParameter('nExamples', [], @isscalar);
			p.addParameter('pointEstimateType',[], @(x)any(strcmp(x,{'mean','median','mode'})));
			p.parse(x, varargin{:});
			
			theta_vals_to_evaluate = determineThetaValsToEvaluate();
			
			% BOTCH: this is being called with group level but for mixed
			% models. Ideally this will not even be called, but temp fix we
			% will abort if there are no samples.
			f = fields(theta_vals_to_evaluate);
			if isempty(theta_vals_to_evaluate.(f{1}))
				y=[];
				return
			end
			
			y = obj.function_evaluation(x, theta_vals_to_evaluate);
			
			function thetaStruct = determineThetaValsToEvaluate()
				
				pointEstimatePrivided = @() ~isempty(p.Results.pointEstimateType);
				
				if pointEstimatePrivided()
					thetaStruct = extractThetaPointEstimates();
				else
					examplesToPlot = getExamplesToPlot();
					thetaStruct = extractTheseThetaSamples(examplesToPlot);
				end
				
				
				function thetaStruct = extractThetaPointEstimates()
					thetaStruct = struct();
					for field = fields(obj.theta)'
						thetaStruct.(field{:}) = obj.theta.(field{:}).(p.Results.pointEstimateType);
						if numel( obj.theta.(field{:}))==1
							% one Stochastic object?
							thetaStruct.(field{:}) = obj.theta.(field{:})(1).(p.Results.pointEstimateType);
						elseif numel( obj.theta.(field{:}))>1
							% array of stochastics?
							for n=1:numel( obj.theta.(field{:}))
								temp(:,n) = obj.theta.(field{:})(n).(p.Results.pointEstimateType);
							end
							thetaStruct.(field{:}) = temp';
						end
					end
				end
				
				function thetaStruct = extractTheseThetaSamples(examplesToPlot)					
					thetaStruct = struct();
					for field = fields(obj.theta)'
						if numel( obj.theta.(field{:}))==1
							% one Stochastic object?
							thetaStruct.(field{:}) = obj.theta.(field{:})(1).samples(examplesToPlot);
						elseif numel( obj.theta.(field{:}))>1
							% array of stochastics?
							for n=1:numel( obj.theta.(field{:}))
								temp(:,n) = obj.theta.(field{:})(n).samples(examplesToPlot);
							end
							thetaStruct.(field{:}) = temp';
						end
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
			
			f = fields(obj.theta);
			for n=1:numel(f)
				
				% TODO: FIX THIS !!!
				try
					% array of stochastics?
					nSamples(n) = numel( obj.theta.(f{n})(1).samples );
				catch
					% plain vectors?
					nSamples(n) = numel(obj.theta.(f{n}));
				end
				
			end
			% TODO: check we have same number of samples for each theta
			
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
