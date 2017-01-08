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
		pointEstimateType
		
		postPred
		parameterEstimateTable
		pdata		% experiment level data for plotting
		%alldata		% cross-experiment level data for plotting
		experimentFigPlotFuncs
		mcmcParams % structure of user-supplied params
		observedData
		
		% User supplied preferences
		modelFilename % string (ie modelFilename.jags, or modelFilename.stan)
		varList
		plotFuncs % structure of function handles
		
		plotOptions
		shouldPlot, shouldExportPlots, exportFormats, savePath
		dataPlotType
		
		timeUnits % string whose name must be a function to create a Duration.
	end
	
	
	
	methods (Access = public)
		
		function obj = Model(data, varargin)
			% Input parsing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			p = inputParser;
			p.StructExpand = false;
			p.FunctionName = mfilename;
			% Required
			p.addRequired('data', @(x) isa(x,'Data'));
			% Optional preferences
			p.addParameter('pointEstimateType','mode',...
				@(x) any(strcmp(x,{'mean','median','mode'})));
			% Optional plotting-based parameters
			p.addParameter('exportFormats', {'png'}, @iscellstr);
			p.addParameter('savePath',tempname, @isstr);
			p.addParameter('shouldPlot', 'no', @(x) any(strcmp(x,{'yes','no'})));
			p.addParameter('shouldExportPlots', true, @islogical);
			% Optional inference related parameters
			p.addParameter('samplerType', 'jags', @(x) any(strcmp(x,{'jags','stan'})));
			p.addParameter('mcmcParams', struct, @isstruct)
			% Define the time units. This must correspond to Duration
			% creation function, such as hours, days, etc. See `help
			% duration` for more
			p.addParameter('timeUnits', 'days',...
				@(x) any(strcmp(x,{'seconds','minutes','hours','days', 'years'})))
			% parse inputs
			p.parse(data, varargin{:});
			% add p.Results fields into obj
			fields = fieldnames(p.Results);
			for n=1:numel(fields)
				obj.(fields{n}) = p.Results.(fields{n});
			end
			
			obj.mcmcParams = obj.parse_mcmcparams(obj.mcmcParams);
			
			obj.plotOptions.shouldPlot = p.Results.shouldPlot;
			obj.plotOptions.shouldExportPlots = p.Results.shouldExportPlots;
			obj.plotOptions.savePath = p.Results.savePath;
			obj.plotOptions.exportFormats = p.Results.exportFormats;
			obj.plotOptions.pointEstimateType = p.Results.pointEstimateType;
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
 			convergenceSummary(obj.coda.getStats('Rhat',[]), obj.savePath, obj.data.getIDnames('all'))
			
			exporter = ResultsExporter(obj.coda, obj.data, obj.postPred.postPred, obj.varList, obj.plotOptions);
			exporter.printToScreen();
			exporter.export(obj.savePath, obj.pointEstimateType);
			% TODO ^^^^ avoid this duplicate use of pointEstimateType
			
			if ~strcmp(obj.shouldPlot,'no')
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
			VA_point_estimate = obj.coda.getStats(obj.pointEstimateType, 'VA');
			VB_point_estimate = obj.coda.getStats(obj.pointEstimateType, 'VB');
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
		
		function [pdata] = packageUpDataForPlotting(obj)
			
            % #166
			% TODO: This is currently an intermediate step on the journey of code simplification. Really, what we should do is just directly go to participant / group / condition objects, which have their own data and plot methods.
			
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			% Package up all information into data structures to be sent
			% off to plotting functions.
			% The idea being we can just pass pdata(n) to a plot function
			% and it has all the information it needs
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			nRealExperiments = obj.data.getNExperimentFiles();
			nExperimentsIncludingUnobserved = numel(obj.data.getIDnames('all')); % TODO: replace with different get method
			
			pdata(1:nExperimentsIncludingUnobserved) = struct; % preallocation
			for p = 1:nExperimentsIncludingUnobserved
				% constant for all participants
				pdata(p).data.totalTrials	= obj.data.totalTrials;
				pdata(p).pointEstimateType	= obj.pointEstimateType;
				pdata(p).discountFuncType	= obj.discountFuncType;
				pdata(p).plotOptions		= obj.plotOptions;
				pdata(p).modelFilename		= obj.modelFilename;
				%pdata(p).shouldExportPlots  = obj.shouldExportPlots;
				
				% custom for each participant
				pdata(p).IDname							= obj.data.getIDnames(p);
				pdata(p).data.trialsForThisParticant	= obj.data.getTrialsForThisParticant(p);
				pdata(p).data.rawdata					= obj.data.getRawDataTableForParticipant(p);
				% gather posterior prediction info
				try
					pdata(p).postPred					= obj.postPred.postPred(p); % TODO: 
				catch
					pdata(p).postPred					= [];
				end
				pdata(p).samples.posterior	= obj.coda.getSamplesAtIndex_asStruct(p, obj.varList.participantLevel);
			end
			
		end
        
        function plotAllExperimentFigures(obj)
            % this is a wrapper function to loop over all data files, producing multi-panel figures. This is implemented by the experimentMultiPanelFigure method, which may be overridden by subclasses if need be.
            names = obj.data.getIDnames('all');
            
            for experimentIndex = 1:numel(names)
                fh = figure('Name', names{experimentIndex});
                
                obj.experimentMultiPanelFigure(experimentIndex)
                drawnow
                
                if obj.shouldExportPlots
                    myExport(obj.savePath, 'expt',...
                        'prefix', names{experimentIndex},...
                        'suffix', obj.modelFilename,...
                        'formats', obj.plotOptions.exportFormats);
                end
                
                close(fh)
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
		
	end
	
end
