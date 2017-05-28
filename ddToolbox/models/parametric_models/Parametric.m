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
            
            obj.plot_discount_functions_in_one();
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
            
            dfPlotFunc = @(fh,n) obj.plot_discount_function(fh,n);
            obj.postPred.plot(obj.plotOptions, obj.modelFilename, dfPlotFunc)
            
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
            %model.experimentMultiPanelFigure(N) Creates a multi-panel figure
            %   model.EXPERIMENTMULTIPANELFIGURE(N) creates a multi-panel figure
            %   corresponding to experiment N, where N is an integer.

            latex_fig(12, 14, 3)
            h = layout([1 2 3 4]);
            opts.pointEstimateType	= obj.plotOptions.pointEstimateType;
            opts.timeUnits			= obj.timeUnits;
            opts.dataPlotType		= obj.plotOptions.dataPlotType;
            
            obj.plot_density_alpha_epsilon(h(1), ind)
            obj.plot_psychometric_function(h(2), ind)
            obj.plot_discount_function_parameters(h(3), ind)
            obj.plot_discount_function(h(4), ind)
        end
        
    end    
    
    
    methods (Access = protected)
    
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
        

        function plot_psychometric_function(obj, subplot_handle, ind)
            responseErrorVariables = obj.getResponseErrorVariables();
            subplot(subplot_handle)
            psycho = PsychometricFunction('samples',...
                obj.coda.getSamplesAtIndex_asStochastic(ind, responseErrorVariables));
            psycho.plot(obj.plotOptions.pointEstimateType)
        end

        function plot_discount_function_parameters(obj, subplot_handle, ind)
            
            % TODO: remove duplication of "opts" in mulitple places, but also should perhaps be a single coherent structure in the first place.
            opts.pointEstimateType	= obj.plotOptions.pointEstimateType;
            opts.timeUnits			= obj.timeUnits;
            opts.dataPlotType		= obj.plotOptions.dataPlotType;
            
            discountFunctionVariables = obj.getDiscountFunctionVariables();
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
