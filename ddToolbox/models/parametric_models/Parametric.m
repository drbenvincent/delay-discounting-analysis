classdef (Abstract) Parametric < Model
	
	methods (Access = public)
		
		function obj = Parametric(data, varargin)
			obj = obj@Model(data, varargin{:});
		end
		
	end
	
	
	
	
	
	
	% ==========================================================================
	% ==========================================================================
	% PLOTTING
	% ==========================================================================
	% ==========================================================================
	
	methods (Access = public)
		
		
		function plot(obj, varargin)
			%plot Plots EVERYTHING
			%   PLOT(model) or model.PLOT will call all plot functions.
			%
			%   Optional input arguments
			%   [...] = model.PLOT(PARAM1,VAL1,PARAM2,VAL2,...) specifies one
			%   or more of the following name/value pairs:
			%
			%      'shouldExportPlots' Either true or false. Default is true.
			
			p = inputParser;
			p.FunctionName = mfilename;
			p.addParameter('shouldExportPlots', true, @islogical);
			p.parse(varargin{:});
			
			%% Plot functions that use data from all participants ========
			
			% Plot univariate summary stats
			obj.plotUnivarateSummary('variablesToPlot', 'all')
			% obj.pleaseExportFigure('UnivariateSummary')
			
			% summary figure of core discounting parameters
			plot_savename = 'summary_plot';
			figure
			h = subplot(1,1,1);
			obj.plotPosteriorClusterPlot('axisHandle', h)
			obj.pleaseExportFigure(plot_savename)
			
			
			obj.plotDiscountFunctionGrid();
			% Export
			if obj.plotOptions.shouldExportPlots
				myExport(obj.plotOptions.savePath,...
					'grid_discount_functions',...
					'suffix', obj.modelFilename,...
					'formats', obj.plotOptions.exportFormats);
			end
			
			fh = figure(10);
			obj.plotDiscountFunctionsOverlaid('figureHandle', fh);
			% Export
			if obj.plotOptions.shouldExportPlots
				myExport(obj.plotOptions.savePath,...
					'discount_functions_overlaid',...
					'suffix', obj.modelFilename,...
					'formats', obj.plotOptions.exportFormats);
			end
			
			%% Plots, one per data file ===================================
			obj.plotAllExperimentFigures();
			obj.plotAllTriPlots(obj.plotOptions, obj.modelFilename)
			
			dfPlotFunc = @(n,fh) obj.plotDiscountFunction(n, 'axisHandle', fh);
			obj.postPred.plot(obj.plotOptions, obj.modelFilename, dfPlotFunc)
			
		end
		
		
		function plotExperimentOverviewFigure(obj, ind)
			%model.plotExperimentOverviewFigure(N) Creates a multi-panel figure
			%   model.plotExperimentOverviewFigure(N) creates a multi-panel figure
			%   corresponding to experiment N, where N is an integer.
			
			latex_fig(12, 14, 3)
			h = layout([1 2 3 4 5]);
% 			opts.pointEstimateType	= obj.plotOptions.pointEstimateType;
% 			opts.timeUnits			= obj.timeUnits;
% 			opts.dataPlotType		= obj.plotOptions.dataPlotType;
			
			obj.plotPosteriorErrorParams(ind, 'axisHandle', h(1))
			obj.plotPsychometricFunction(ind, 'axisHandle', h(2))
			obj.plotPosteriorDiscountFunctionParams(ind, 'axisHandle', h(3))
			obj.plotDiscountFunction(ind, 'axisHandle', h(4))
			obj.plotPosteriorAUC(ind, 'axisHandle', h(5))
		end
		
		function plotPosteriorCornerPlot(obj, n)
			%model.plotCornerPlot(N) Visualises posterior over parameters for experiment N
			%   model.PLOTCORNERPLOT(N) plots a corner plot to show all univariate
			%   marginal distributions and all combinations of bivariate marginal
			%   distributions.
			
			pVariableNames =  obj.varList.participantLevel;
			posteriorSamples = obj.coda.getSamplesAtIndex_asMatrix(n, pVariableNames);
			
			figure(87), clf
			mcmc.TriPlotSamples(posteriorSamples,...
				pVariableNames,...
				'pointEstimateType', obj.plotOptions.pointEstimateType);
		end
		
		function plotPosteriorDiscountFunctionParams(obj, ind, varargin)
			%plotPosteriorDiscountFunctionParams(H, N) Plots posterior distribuion over
			% discount function related parameters. Plot is applied to subplot handle H
			% and plots parameters for experiment N.
			%
			% Optional arguments as key/value pairs
			%       'axisHandle' - handle to axes
			%       'figureHandle' - handle to figure
			
			[figureHandle, axisHandle] = parseFigureAndAxisRequested(varargin{:});
			
			% TODO: remove duplication of "opts" in mulitple places, but also should perhaps be a single coherent structure in the first place.
			opts.pointEstimateType	= obj.plotOptions.pointEstimateType;
			opts.timeUnits			= obj.timeUnits;
			opts.dataPlotType		= obj.plotOptions.dataPlotType;
			
			discountFunctionVariables = obj.getDiscountFunctionVariables();
			switch numel(discountFunctionVariables)
				case{1}
					obj.coda.plot_univariate_distribution(axisHandle,...
						discountFunctionVariables(1),...
						ind,...
						opts)
				case{2}
					obj.coda.plot_bivariate_distribution(axisHandle,...
						discountFunctionVariables(1),...
						discountFunctionVariables(2),...
						ind,...
						opts)
				otherwise
					warning('Currently only set up to plot univariate or bivariate distributions, ie discount functions 1 or 2 params.')
			end
		end
        
        function plotPsychometricFunction(obj, ind, varargin)
            %plotPsychometricFunction
            %
            % Optional arguments as key/value pairs
            %       'axisHandle' - handle to axes
            %       'figureHandle' - handle to figure
            
            [figureHandle, axisHandle] = parseFigureAndAxisRequested(varargin{:});
            
            responseErrorVariables = obj.getResponseErrorVariables();
            psycho = PsychometricFunction('samples',...
                obj.coda.getSamplesAtIndex_asStochastic(ind, responseErrorVariables));
            psycho.plot(obj.plotOptions.pointEstimateType)
        end
		
	end
	
	
	methods (Access = protected)
		
		% TODO: this should be moved to CODA
		function plotAllTriPlots(obj, plotOptions, modelFilename)
			for p = 1:obj.data.getNExperimentFiles
				obj.plotPosteriorCornerPlot(p)
				%
				% figure(87), clf
				%
				% posteriorSamples = obj.coda.getSamplesAtIndex_asMatrix(p, pVariableNames);
				%
				% mcmc.TriPlotSamples(posteriorSamples,...
				%     pVariableNames,...
				%     'pointEstimateType', plotOptions.pointEstimateType);
				
				id_prefix = obj.data.getIDnames(p);
				
				% Export
				if plotOptions.shouldExportPlots
					myExport(plotOptions.savePath,...
						'triplot',...
						'prefix', id_prefix{:},...
						'suffix', modelFilename,...
						'formats', plotOptions.exportFormats);
				end
				
			end
		end
				
	end
	
end
