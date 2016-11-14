classdef (Abstract) Parametric < Model
	
	properties (Access = private)
		
	end
	
	methods (Access = public)
		
		function obj = Parametric(data, varargin)
			obj = obj@Model(data, varargin{:});
		end
		
		
		function plot(obj, varargin)
			
			% parse inputs
			p = inputParser;
			p.FunctionName = mfilename;
			p.addParameter('shouldExportPlots', true, @islogical);
			%p.addParameter('exportFormats', {'pdf'}, @iscellstr);
			p.parse(varargin{:});
			
			obj.pdata = obj.packageUpDataForPlotting();
			
			for n=1:numel(obj.pdata)
				obj.pdata(n).shouldExportPlots = p.Results.shouldExportPlots;
			end
			
			%% Plot functions that use data from all participants ==============
			
			% TODO --------------------------------------------------------
			% gather cross-experiment data for univariate sta
			alldata.shouldExportPlots = p.Results.shouldExportPlots;
			alldata.shouldExportPlots	= obj.shouldExportPlots;
			alldata.variables			= obj.varList.participantLevel;
			alldata.filenames			= obj.data.getIDnames('all');
			alldata.savePath			= obj.savePath;
			alldata.modelFilename		= obj.modelFilename;
			alldata.plotOptions 		= obj.plotOptions;
			for v = alldata.variables
				alldata.(v{:}).hdi =...
					[obj.coda.getStats('hdi_low',v{:}),... % TODO: ERROR - expecting a vector to be returned
					obj.coda.getStats('hdi_high',v{:})]; % TODO: ERROR - expecting a vector to be returned
				alldata.(v{:}).pointEstVal =...
					obj.coda.getStats(obj.pointEstimateType, v{:});
			end
			% -------------------------------------------------------------
			% TODO: Think about plotting this with GRAMM
            % https://github.com/piermorel/gramm
            figUnivariateSummary(alldata)
            
			
			% plot -------------------------------------------------------------
			% TODO: pass in obj.alldata or obj.pdata rather than all these args
			obj.plotFuncs.clusterPlotFunc(...
				obj.coda,...
				obj.data,...
				[1 0 0],...
				obj.modelFilename,...
				obj.plotOptions)
			
			
			%% Plots, one per participant ======================================
			obj.experimentPlot();
			
			
			% plot --------------------------------------------------------
			arrayfun(@plotTriPlotWrapper, obj.pdata)
			
			% plot --------------------------------------------------------
			arrayfun(@figPosteriorPrediction, obj.pdata)
		end
		
	end
	
	methods (Abstract)
		experimentPlot(obj)
	end
	
end
