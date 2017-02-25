classdef (Abstract) Parametric < Model
		
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
            
            % Plot univariate summary stats
            plot_savename = 'UnivariateSummary';
            variables = obj.varList.participantLevel;
            obj.coda.plotUnivariateSummaries(variables,...
				obj.plotOptions,...
				obj.data.getParticipantNames());
            export_it(plot_savename)
			
			% summary figure of core discounting parameters
            plot_savename = 'summary_plot';
			clusterPlot(...
				obj.coda,...
				obj.data,...
				[1 0 0],...
				obj.plotOptions,...
			    obj.varList.discountFunctionParams)
            export_it(plot_savename)

                
            obj.plot_discount_functions_in_grid();
            % Export
            if obj.plotOptions.shouldExportPlots
                myExport(obj.plotOptions.savePath,...
                    'grid_discount_functions',...
                    'suffix', obj.modelFilename,...
                    'formats', obj.plotOptions.exportFormats);
            end
                
			%% Plots, one per data file ===================================		
			obj.plotAllExperimentFigures();
            obj.plotAllTriPlots(obj.plotOptions, obj.modelFilename)
            obj.postPred.plot(obj.plotOptions, obj.modelFilename)
            
            function export_it(savename)
                if obj.plotOptions.shouldExportPlots
                    myExport(obj.plotOptions.savePath,...
                        savename,...
                        'suffix', obj.modelFilename,...
                        'formats', obj.plotOptions.exportFormats)
                end
            end
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
			
            plot_density_alpha_epsilon(h(1))
            plot_psychometric_function(h(2))
            plot_discount_function_parameters(h(3))
            obj.plot_discount_function(h(4), ind)

            function plot_density_alpha_epsilon(subplot_handle)
                obj.coda.plot_bivariate_distribution(subplot_handle,...
    				responseErrorVariables(1),...
    				responseErrorVariables(2),...
    				ind,...
    				opts)
            end
            
            function plot_psychometric_function(subplot_handle)
                subplot(subplot_handle)
    			psycho = PsychometricFunction('samples',...
					obj.coda.getSamplesAtIndex_asStochastic(ind, responseErrorVariables));
    			psycho.plot(obj.plotOptions.pointEstimateType)
            end
            
            function plot_discount_function_parameters(subplot_handle)
                switch numel(discountFunctionVariables)
                    case{1}
                        obj.coda.plot_univariate_distribution(subplot_handle,...
                            discountFunctionVariables(1),...
                            ind,...
                            opts)
                    case{2}
                        obj.coda.plot_bivariate_distribution(subplot_handle,...
                            discountFunctionVariables(1),...
                            discountFunctionVariables(2),...
                            ind,...
                            opts)
                    otherwise
                        error('Currently only set up to plot univariate or bivariate distributions, ie discount functions 1 or 2 params.')
                end
            end

		end
		
	end
    
    methods (Access = private)
    
        % TODO: this should be moved to CODA
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
