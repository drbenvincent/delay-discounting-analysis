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
		postPred
		mcmcParams % structure of user-supplied params
		observedData
		% User supplied preferences
		modelFilename % string (ie modelFilename.jags, or modelFilename.stan)
		varList
		plotOptions
		timeUnits % string whose name must be a function to create a Duration.
	end

    % methods that subclasses must implement
    methods (Abstract, Access = public)
        plot()
        experimentMultiPanelFigure()
        %plot_discount_function(obj, subplot_handle, ind)
        %getAUC(obj)
	end
	methods (Abstract, Access = protected)
		initialiseChainValues()
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

		function export(obj)
			% TODO: This should be a method of CODA
			% TODO: better function name. What does it do? Calculate or
			% export, or both?
			convergenceSummary(obj.coda.getStats('Rhat',[]),...
				obj.plotOptions.savePath,...
				obj.data.getIDnames('all'))
			
			exporter = ResultsExporter(obj.coda, obj.data,...
				obj.postPred,...
				obj.varList,...
				obj.plotOptions);
			exporter.printToScreen();
			exporter.export(obj.plotOptions.savePath, obj.plotOptions.pointEstimateType);
			% TODO ^^^^ avoid this duplicate use of pointEstimateType
		end
        
        function plot_discount_function(obj, axis_handle, ind, varargin)
			%plot_discount_function
			% Example public call. This will plot a discount function to a
			% specified subplot, for the experiment file determined by the
			% numerical 'index'
			% model.plot_discount_function(axis_handle, index)
			
			p = inputParser;
			p.FunctionName = mfilename;
			p.addParameter('plot_mode', 'full', @isstr);
			p.parse(varargin{:});
			
            discountFunctionVariables = {obj.varList.discountFunctionParams.name};
            
            subplot(axis_handle)
            
			samples = obj.coda.getSamplesAtIndex_asStochastic(ind, discountFunctionVariables);
			
            discountFunction = obj.dfClass(...
                'samples', samples,...
                'data', obj.data.getExperimentObject(ind));
                
            discountFunction.plot(obj.plotOptions.pointEstimateType,...
                obj.plotOptions.dataPlotType,...
                obj.timeUnits,...
				'plot_mode', p.Results.plot_mode);
            % TODO #166 avoid having to parse these args in here
        end

	end

	%%  GETTERS

	methods

		function [predicted_subjective_values] = get_inferred_present_subjective_values(obj)
			%get_inferred_present_subjective_values
			% returns the inferred present subjective values of the 
			% objective reward values
			
			%% calculate point estimates
			% get point estimates of present subjective values. These will
			% be vectors. Each value corresponds to one trial in the
			% overall dataset
            
            %% return point estimates of present subjective values...
			all_data_table = obj.data.groupTable;
            % add new columns for present subjective value (VA, VB)
			all_data_table.VA = obj.coda.getStats(obj.plotOptions.pointEstimateType, 'VA');
			all_data_table.VB = obj.coda.getStats(obj.plotOptions.pointEstimateType, 'VB');
            predicted_subjective_values.point_estimates = all_data_table;

			%% TODO: Return full posterior distributions of present subjective values
			% predicted_subjective_values.A_full_posterior =
			% predicted_subjective_values.B_full_posterior =
		end

	end











	%% Protected methods

	methods (Access = protected)

		function nChains = get_nChains(obj)
			nChains = obj.mcmcParams.nchains;
		end
		
		function [samples] = getGroupLevelSamples(obj, fieldsToGet)
			[samples] = obj.data.getGroupLevelSamples(fieldsToGet);
		end
		
		function obj = postSamplingActivities(obj)
			%% Post-sampling activities (for model sub-classes) -----------
			% If a model has additional measures that need to be calculated
			% from the MCMC samples, then we can do by overriding this
			% method in the model sub-classes
			obj = obj.calcDerivedMeasures();
			
			%% Post-sampling activities (common to all models) ------------
			% posterior prediction calculation
			obj.postPred = PosteriorPrediction(obj.coda, obj.data, obj.observedData);
			
			% calc and export convergence summary and parameter estimates
			obj.export();
			
			% plot or not
			if ~strcmp(obj.plotOptions.shouldPlot,'no')
				% TODO: Allow public calls of obj.plot to specify options.
				% At the moment the options need to be provided on Model
				% object construction
				obj.plot()
			end
			
			obj.tellUserAboutPublicMethods()
		end
		
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
			observedData = obj.additional_model_specific_ObservedData(observedData);
		end

		function obj = calcDerivedMeasures(obj)
%             %% Calculate AUC
% 
%             % 1) Use the discount function object to calculate a distribution of AUC values, one for each MCMC sample
% 			discountFunctionVariables = {obj.varList.discountFunctionParams.name};
% 			
% 			N = obj.data.getNExperimentFiles();
% 			
% 			for ind = 1:N % loop over files
% 				
% 				samples = obj.coda.getSamplesAtIndex_asStochastic(ind, discountFunctionVariables);
% 				data = obj.data.getExperimentObject(ind);
% 				
% 				discountFunction = obj.dfClass(...
% 					'samples', samples,...
% 					'data', data);
% 				
% % 				% calc AUC values
% % 				AUC = discountFunction.calcAUC();
% 				
% 				% 2) Inject these into a new variable into coda
% 
% 			end
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
                    myExport(obj.plotOptions.savePath,...
                        'expt',...
                        'prefix', names{experimentIndex},...
                        'suffix', obj.modelFilename,...
                        'formats', obj.plotOptions.exportFormats);
                end

                close(fh);
            end
        end
        
        function plot_discount_functions_in_grid(obj)
            latex_fig(12, 11,11)
            clf, drawnow
            
            % TODO: extract the grid formatting stuff to be able to call
            % any plot function we want
            % USE: apply_plot_function_to_subplot_handle.m ??
            
            %fh = figure('Name', names{experimentIndex});
            names = obj.data.getIDnames('all');
            
            % create grid layout
            N = numel(names);
            subplot_handles = create_subplots(N, 'square');
            
            % Iterate over files, plotting
            disp('Plotting...')
            for n = 1:numel(names)
                obj.plot_discount_function(subplot_handles(n), n)
				title(names{n}, 'FontSize',10)
				set(gca,'FontSize',10)
            end
            drawnow
        end
        
        
        function plot_discount_functions_in_one(obj)
			latex_fig(12, 8,6)
			clf, drawnow
			
			% don't want the group level estimate, so not asking for 'all'
			names = obj.data.getIDnames('experiments');
			
			% plot curves in same axis
			subplot_handle = subplot(1,1,1);
			
			% Iterate over files, plotting
			disp('Plotting...')
			for n = 1:numel(names)
				hold on
				obj.plot_discount_function(subplot_handle, n,...
					'plot_mode', 'point_estimate_only')
			end
			set(gca,'PlotBoxAspectRatio',[1.5,1,1])
			y = get(gca,'ylim');
			set(gca, 'ylim', [0 min([y(2), 2])])
			%             title(names{n}, 'FontSize',10)
			%             set(gca,'FontSize',10)
			drawnow
		end

	end


	methods (Static, Access = protected)

		function observedData = additional_model_specific_ObservedData(observedData)
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
