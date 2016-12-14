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
			p.parse(varargin{:});

			obj.pdata = obj.packageUpDataForPlotting();

			for n=1:numel(obj.pdata)
				obj.pdata(n).shouldExportPlots = p.Results.shouldExportPlots;
			end

			%% Plot functions that use data from all participants =========




			% #############################################################
			% #############################################################
			% THIS IS A LOT OF FAFF, JUST FOR UNIVARIATE SUMMARY PLOTS

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
			% #############################################################
			% #############################################################


			% summary figure of core discounting parameters
			clusterPlot(...
				obj.coda,...
				obj.data,...
				[1 0 0],...
				obj.modelFilename,...
				obj.plotOptions,...
				obj.varList.discountFunctionParams)


			%% Plots, one per data file ===================================
			obj.experimentPlot();

			% Corner plot of parameters
			arrayfun(@plotTriPlotWrapper, obj.pdata)

			% Posterior prediction plot
			arrayfun(@figPosteriorPrediction, obj.pdata)
		end


		function experimentPlot(obj)

			% create cell array
			discountFunctionVariables = {obj.varList.discountFunctionParams.name};
			responseErrorVariables = {obj.varList.responseErrorParams.name};

			names = obj.data.getIDnames('all');

			for ind = 1:numel(names)
				fh = figure('Name', names{ind});
				latex_fig(12, 10, 3)

				%%  Set up psychometric function
				respErrSamples = obj.coda.getSamplesAtIndex(ind, responseErrorVariables);
				psycho = PsychometricFunction('samples', respErrSamples);

				%% plot bivariate distribution of alpha, epsilon
				subplot(1,4,1)
				% TODO: replace with new class
				mcmc.BivariateDistribution(...
					respErrSamples.epsilon(:),...
					respErrSamples.alpha(:),...
					'xLabel', obj.varList.responseErrorParams(1).label,...
					'ylabel', obj.varList.responseErrorParams(2).label,...
					'pointEstimateType',obj.pointEstimateType,...
					'plotStyle', 'hist',...
					'axisSquare', true);

				%% Plot the psychometric function
				subplot(1,4,2)
				psycho.plot(obj.pointEstimateType)

				%% Set up discount function
				dfSamples = obj.coda.getSamplesAtIndex(ind, discountFunctionVariables);

				discountFunction = obj.dfClass('samples', dfSamples);
				% add data:  TODO: streamline this on object creation ~~~~~
				% NOTE: we don't have data for group-level
				data_struct = obj.data.getExperimentData(ind);
				data_object = DataFile(data_struct);
				discountFunction.data = data_object;
				% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				% TODO: this checking needs to be implemented in a
				% smoother, more robust way
				if ~isempty(dfSamples) || ~any(isnan(dfSamples))
					subplot(1,4,3)
					discountFunction.plotParameters(obj.pointEstimateType)

					subplot(1,4,4)
					discountFunction.plot(obj.pointEstimateType,...
						obj.dataPlotType,...
						obj.timeUnits)
				end

				if obj.shouldExportPlots
					myExport(obj.savePath, 'expt',...
						'prefix', names{ind},...
						'suffix', obj.modelFilename,...
						'formats', {'png'});
				end

				close(fh)
			end
		end

	end

end
