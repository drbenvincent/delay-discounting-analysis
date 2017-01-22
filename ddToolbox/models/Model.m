classdef (Abstract) Model
	%Model Base class to provide basic functionality

	% Allow acces to these via Model, but we still only get access to these
	% class's public interface.
	properties (SetAccess = protected, GetAccess = public)
		coda % handle to coda object
		data % handle to Data class
	end

	%% Private properties
	properties (SetAccess = protected, GetAccess = protected)
		dfClass % function handle to DiscountFunction class
		samplerType
		discountFuncType
		postPred
		parameterEstimateTable
		experimentFigPlotFuncs
		mcmcParams % structure of user-supplied params
		observedData
		% User supplied preferences
		modelFilename % string (ie modelFilename.jags, or modelFilename.stan)
		varList
		plotFuncs % structure of function handles
		plotOptions
		timeUnits % string whose name must be a function to create a Duration.
	end



	methods (Access = public)

		function obj = Model(data, varargin)
			% Input parsing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			p = inputParser;
			p.StructExpand = false;
			p.KeepUnmatched = true;
			p.FunctionName = mfilename;
			% Required
			p.addRequired('data', @(x) isa(x,'Data'));
			% Optional inference related parameters
			p.addParameter('samplerType', 'jags', @(x) any(strcmp(x,{'jags','stan'})));
			p.addParameter('mcmcParams', struct, @isstruct)
			% Define the time units. This must correspond to Duration
			% creation function, such as hours, days, etc. See `help
			% duration` for more
			p.addParameter('timeUnits', 'days',...
				@(x) any(strcmp(x,{'seconds','minutes','hours','days', 'years'})))
			% Parse inputs
			p.parse(data, varargin{:});
			% add p.Results fields into obj
			fields = fieldnames(p.Results);
			for n=1:numel(fields)
				obj.(fields{n}) = p.Results.(fields{n});
			end
			% parse input arguments into structures
			obj.mcmcParams	= obj.parse_mcmcparams(obj.mcmcParams);
			obj.plotOptions = obj.parse_plot_options(varargin{:});
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			obj.varList.responseErrorParams(1).name = 'alpha';
			obj.varList.responseErrorParams(1).label = 'comparison accuity, $\alpha$';

			obj.varList.responseErrorParams(2).name = 'epsilon';
			obj.varList.responseErrorParams(2).label = 'error rate, $\epsilon$';
		end


		function obj = conductInference(obj)
			% pre-sampling preparation
			obj.observedData = obj.constructObservedDataForMCMC();
			path_of_model_file = makeProbModelsPath(obj.modelFilename, obj.samplerType);
			% sampling
			samplerFunction = obj.selectSampler(obj.samplerType);
			obj.coda = samplerFunction(...
				path_of_model_file,...
				obj.observedData,...
				obj.mcmcParams,...
				obj.initialiseChainValues(obj.mcmcParams.nchains),...
				obj.varList.monitored);
			% This is a separate method, to allow for overriding in sub classes
			obj = obj.postSamplingActivities();
		end

		function obj = postSamplingActivities(obj)

			%% Post-sampling activities (for model sub-classes) -----------
			% If a model has additional measures that need to be calculated
			% from the MCMC samples, then we can do by overriding this
			% method in the model sub-classes
			obj = obj.calcDerivedMeasures();

			%% Post-sampling activities (common to all models) ------------
			obj.postPred = PosteriorPrediction(obj.coda, obj.data, obj.observedData);


			% TODO: This should be a method of CODA
 			convergenceSummary(obj.coda.getStats('Rhat',[]), obj.plotOptions.savePath, obj.data.getIDnames('all'))

			exporter = ResultsExporter(obj.coda, obj.data, obj.postPred.postPred, obj.varList, obj.plotOptions);
			exporter.printToScreen();
			exporter.export(obj.plotOptions.savePath, obj.plotOptions.pointEstimateType);
			% TODO ^^^^ avoid this duplicate use of pointEstimateType

			if ~strcmp(obj.plotOptions.shouldPlot,'no')
				% TODO: Allow public calls of obj.plot to specify options.
				% At the moment the options need to be provided on Model
				% object construction
				obj.plot()
			end

			obj.tellUserAboutPublicMethods()
		end

		%% Public MIDDLE-MAN METHODS

		function obj = plotMCMCchains(obj,vars)
			obj.coda.plotMCMCchains(vars);
		end

	end

	%%  GETTERS

	methods

		function nChains = get_nChains(obj)
			nChains = obj.mcmcParams.nchains;
		end

		function [samples] = getGroupLevelSamples(obj, fieldsToGet)
			if ~obj.data.isUnobservedPartipantPresent()
				% exit if we don't have any group level inference
				error('Looks like we don''t have group level estimates.')
			else
				index = obj.data.getIndexOfUnobservedParticipant();
				samples = obj.coda.getSamplesAtIndex_asStruct(index, fieldsToGet);
			end
		end

		function [predicted_subjective_values] = get_inferred_present_subjective_values(obj)
			%% calculate point estimates
			% get point estimates of present subjective values. These will
			% be vectors. Each value corresponds to one trial in the
			% overall dataset
			VA_point_estimate = obj.coda.getStats(obj.plotOptions.pointEstimateType, 'VA');
			VB_point_estimate = obj.coda.getStats(obj.plotOptions.pointEstimateType, 'VB');
			assert(isvector(VA_point_estimate))
			assert(isvector(VB_point_estimate))

			all_data_table = obj.data.groupTable;
			all_data_table.VA = VA_point_estimate;
			all_data_table.VB = VB_point_estimate;

			%% Return full posterior distributions of present subjective values
			% TODO
			% predicted_subjective_values.A_full_posterior =
			% predicted_subjective_values.B_full_posterior =

			%% return point estimates of present subjectiv values...
			predicted_subjective_values.point_estimates = all_data_table;
		end

	end











	%% Protected methods

	methods (Access = protected)

		function observedData = constructObservedDataForMCMC(obj)
			% This function can be overridden by model subclasses, however
			% we still expect them to call this model baseclass method to
			% set up the core data (unlikely to change across models).
			all_data = obj.data.groupTable;
			observedData = table2struct(all_data, 'ToScalar',true);
			observedData.participantIndexList = obj.data.getParticipantIndexList();
			observedData.nRealExperimentFiles = obj.data.getNRealExperimentFiles();
			observedData.totalTrials = height(all_data);
			% protected method which can be over-ridden by model sub-classes
			observedData = obj.addititional_model_specific_ObservedData(observedData);
		end

		function obj = calcDerivedMeasures(obj)
		end

		function tellUserAboutPublicMethods(obj)
			% TODO - the point is to guide them into what to do next
			methods(obj)
		end

		function obj = addUnobservedParticipant(obj, str)
			% TODO: Check we need this
			obj.data = obj.data.add_unobserved_participant(str);	% add name (eg 'GROUP')
		end

        function plotAllExperimentFigures(obj)
            % this is a wrapper function to loop over all data files, producing multi-panel figures. This is implemented by the experimentMultiPanelFigure method, which may be overridden by subclasses if need be.
            names = obj.data.getIDnames('all');

            for experimentIndex = 1:numel(names)
                fh = figure('Name', names{experimentIndex});

                obj.experimentMultiPanelFigure(experimentIndex);
                drawnow

                if obj.plotOptions.shouldExportPlots
                    myExport(obj.plotOptions.savePath, 'expt',...
                        'prefix', names{experimentIndex},...
                        'suffix', obj.modelFilename,...
                        'formats', obj.plotOptions.exportFormats);
                end

                close(fh);
            end
        end

	end


	methods (Static, Access = protected)

		function observedData = addititional_model_specific_ObservedData(observedData)
			% KEEP THIS HERE. IT IS OVER-RIDDEN IN SOME MODEL SUB-CLASSES

			% TODO: can we move this to NonParamtric abstract class?
		end

		function samplerFunction = selectSampler(samplerType)
			switch samplerType
				case{'jags'}
					samplerFunction = @sampleWithMatjags;
				case{'stan'}
					samplerFunction = @sampleWithMatlabStan;
			end
		end

		function mcmcparams = parse_mcmcparams(mcmcParams)
			defaultMCMCParams.doparallel	= 1;
			defaultMCMCParams.nburnin		= 1000;
			defaultMCMCParams.nchains		= 2;
			defaultMCMCParams.nsamples		= 10^4; % represents TOTAL number of samples we want
			% update with any user-supplied options
			if isfield(mcmcParams, 'chains')
				error('Please pass in ''nchains'', not ''chains''.')
			end
			mcmcparams = kwargify(defaultMCMCParams, mcmcParams);
		end

		function plotOptions = parse_plot_options(varargin)
			p = inputParser;
			p.StructExpand = false;
			p.KeepUnmatched = true;
			p.FunctionName = mfilename;

			p.addParameter('exportFormats', {'png'}, @iscellstr);
			p.addParameter('savePath',tempname, @isstr);
			p.addParameter('shouldPlot', 'no', @(x) any(strcmp(x,{'yes','no'})));
			p.addParameter('shouldExportPlots', true, @islogical);
			p.addParameter('pointEstimateType','mode',...
				@(x) any(strcmp(x,{'mean','median','mode'})));

			p.parse(varargin{:});

			plotOptions = p.Results;
		end

	end

end
