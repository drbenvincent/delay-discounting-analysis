classdef (Abstract) Parametric < Model
	
	properties (Access = private)
		
	end
	
	methods (Access = public)
		
		function obj = Parametric(data, varargin)
			obj = obj@Model(data, varargin{:});
		end
		
		
		function plot(obj, varargin)
			p = inputParser;
			p.FunctionName = mfilename;
			p.addParameter('shouldExportPlots', true, @islogical);
			p.parse(varargin{:});
			
			%% Plot functions that use data from all participants ========
            variables = obj.varList.participantLevel;
            obj.coda.plotUnivariateSummaries(variables,...
				obj.plotOptions,...
				obj.data.getParticipantNames());
            
            % Export
            if obj.plotOptions.shouldExportPlots
                myExport(obj.plotOptions.savePath,...
                    'UnivariateSummary',...
                    'suffix', obj.modelFilename,...
                    'formats', obj.plotOptions.exportFormats)
            end
			
            
			% summary figure of core discounting parameters
			clusterPlot(...
				obj.coda,...
				obj.data,...
				[1 0 0],...
				obj.plotOptions,...
			    obj.varList.discountFunctionParams)
                
            % Export
            if obj.plotOptions.shouldExportPlots
            	myExport(obj.plotOptions.savePath,...
                    'summary_plot',...
            		'suffix', obj.modelFilename,...
                    'formats', obj.plotOptions.exportFormats)
            end
                
                
			%% Plots, one per data file ===================================		
			obj.plotAllExperimentFigures();
			
			% Corner plot of parameters
            obj.plotAllTriPlots(obj.plotOptions, obj.modelFilename)
			
			% Posterior prediction plot
            obj.postPred.plot(obj.plotOptions, obj.modelFilename)
		end
		
		
		function experimentMultiPanelFigure(obj, ind)
			
            latex_fig(12, 14, 3)
			h = layout([1 2 3 4]);
			opts.pointEstimateType	= obj.plotOptions.pointEstimateType;
			opts.timeUnits			= obj.timeUnits;
			opts.dataPlotType		= obj.plotOptions.dataPlotType;
			
			% create cell arrays of relevant variables
			discountFunctionVariables = {obj.varList.discountFunctionParams.name};
			responseErrorVariables    = {obj.varList.responseErrorParams.name};
			
			%% PLOT: density plot of (alpha, epsilon)
			obj.coda.plot_bivariate_distribution(h(1),...
				responseErrorVariables(1),...
				responseErrorVariables(2),...
				ind,...
				opts)
			
			%% Plot the psychometric function ----------------------------------
			subplot(h(2))
			psycho = PsychometricFunction('samples', obj.coda.getSamplesAtIndex_asStruct(ind, responseErrorVariables));
			psycho.plot(obj.plotOptions.pointEstimateType)
			
			%% Plot the discount function parameters ---------------------------
			switch numel(discountFunctionVariables)
				case{1}
					obj.coda.plot_univariate_distribution(h(3),...
						discountFunctionVariables(1),...
						ind,...
						opts)
				case{2}
					obj.coda.plot_bivariate_distribution(h(3),...
						discountFunctionVariables(1),...
						discountFunctionVariables(2),...
						ind,...
						opts)
				otherwise
					error('Currently only set up to plot univariate or bivariate distributions, ie discount functions 1 or 2 params.')
			end
			
			%% Plot the discount function parameters ----------------------
			subplot(h(4))
			discountFunction = obj.dfClass(...
				'samples', obj.coda.getSamplesAtIndex_asStruct(ind, discountFunctionVariables),...
				'data', obj.data.getExperimentObject(ind));
			discountFunction.plot(obj.plotOptions.pointEstimateType,...
				obj.plotOptions.dataPlotType,...
				obj.timeUnits);
			% TODO #166 avoid having to parse these args in here

		end
        
        function plot_discount_functions_in_grid(obj)
            error('Implement this! See #170')
        end
		
	end
    
    methods (Access = private)
    
        function plotAllTriPlots(obj, plotOptions, modelFilename)
            
            pVariableNames =  obj.varList.participantLevel;
            
            for p = 1:obj.data.getNExperimentFiles
                figure(87), clf
                
				posteriorSamples = obj.coda.getSamplesAtIndex_asMatrix(p, pVariableNames);
				
                mcmc.TriPlotSamples(posteriorSamples,...
                	pVariableNames,...
                	'pointEstimateType', plotOptions.pointEstimateType);

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
