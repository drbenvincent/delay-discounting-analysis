classdef Model
	%Model Base class to provide basic functionality
	
	% Allow acces to these via Model, but we still only get access to these
	% class's public interface.
	properties (SetAccess = protected, GetAccess = public)
		coda % handle to coda object
		data % handle to Data class
	end
	
	properties (SetAccess = protected, GetAccess = protected)
		samplerType
		savePath
		discountFuncType
		pointEstimateType
				
		postPred
		parameterEstimateTable
		pdata		% experiment level data for plotting
		alldata		% cross-experiment level data for plotting
		participantFigPlotFuncs
		mcmcParams % structure of user-supplied params
		
		% User supplied preferences
		modelType % string (ie modelType.jags, or modelType.stan)
		
		varList
		plotFuncs % structure of function handles
		shouldPlot, shouldExportPlots
		observedData
	end
	
	methods(Abstract, Access = protected)
		calcDerivedMeasures(obj)
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
			p.addParameter('savePath',tempname, @isstr);
			p.addParameter('pointEstimateType','mode',@(x) any(strcmp(x,{'mean','median','mode'})));
			p.addParameter('shouldPlot', 'no', @(x) any(strcmp(x,{'yes','no'})));
			p.addParameter('shouldExportPlots', true, @islogical);
			% Optional inference related parameters
			p.addParameter('samplerType', 'jags', @(x) any(strcmp(x,{'jags','stan'})));
			p.addParameter('mcmcParams', struct, @isstruct)
			% parse inputs
			p.parse(data, varargin{:});
			% add p.Results fields into obj
			fields = fieldnames(p.Results);
			for n=1:numel(fields)
				obj.(fields{n}) = p.Results.(fields{n});
			end
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
		end
		
		
		function obj = conductInference(obj)
			
			switch obj.samplerType
				case{'jags'}
					samplerFunction = @sampleWithMatjags;
				case{'stan'}
					samplerFunction = @sampleWithMatlabStan;
			end
			
			% set default parameters
			defaultMCMCParams.doparallel	= 1;
			defaultMCMCParams.nburnin		= 1000;
			defaultMCMCParams.nchains		= 2;
			defaultMCMCParams.nsamples		= 10^4; % represents TOTAL number of samples we want
			
			% update with any user-supplied options
			mcmcparams = kwargify(defaultMCMCParams, obj.mcmcParams);
			
			obj.observedData = obj.constructObservedDataForMCMC( obj.data.get_all_data_table() );
			
			% do the sampling and get a CODA object back ~~~~~~~~~~~~
			obj.coda = samplerFunction(...
				makeProbModelsPath(obj.modelType, lower(obj.samplerType)),...
				obj.observedData,...
				mcmcparams,...
				obj.setInitialParamValues(mcmcparams.nchains),... % TODO not really a "set" method
				obj.varList.monitored);
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			
			%% Post-sampling activities (for model sub-classes) -----------
			% If a model has additional measures that need to be calculated
			% from the MCMC samples, then we can do by overriding this
			% method in the model sub-classes
			obj = obj.calcDerivedMeasures();
			
			%% Post-sampling activities (common to all models) ------------
			obj.postPred = obj.calcPosteriorPredictive();
			convergenceSummary(obj.coda.getStats('Rhat',[]), obj.savePath, obj.data.getIDnames('all'))
			obj.parameterEstimateTable = obj.exportParameterEstimates();
			[obj.pdata, obj.alldata] = obj.packageUpDataForPlotting();
			if ~strcmp(obj.shouldPlot,'no')
				obj.plot( 'shouldExportPlots', obj.shouldExportPlots )
			end
			obj.tellUserAboutPublicMethods()
		end
		
		
		function finalTable = exportParameterEstimates(obj, varargin)
			% Ideally, we are going to make a table. Each row is a
			% participant/experiment. We have one set of columns related to
			% the model variables, and another related to posterior
			% prediction. These are made separately and then joined.
			% Currently, this only works when the model variables are
			% scalar, we don't yet have support for vector or matrix
			% model variables.
			
			CREDIBLE_INTERVAL = 0.95;
			
			%% Make table 1 (model variable info)
			paramEstimateTable = obj.coda.exportParameterEstimates(...
				obj.varList.participantLevel,... %obj.varList.groupLevel,...
				obj.data.getIDnames('all'),...
				obj.savePath,...
				obj.pointEstimateType,...
				varargin{:});
			
			%% Make table 2 (posterior prediction)
			postPredTable = makePostPredTable();
			
			%% Horizontally join the tables
			finalTable = join(paramEstimateTable, postPredTable, 'Keys','RowNames');
			display(finalTable)
			
			%% Export to textfile
			tempSavePath = fullfile(...
				obj.savePath,...
				['parameterEstimates_Posterior_' obj.pointEstimateType '.csv']);
			exportTable(finalTable, tempSavePath);
			
			function postPredTable = makePostPredTable()
				% Create table of posterior prediction measures
				% Add mean score (log ratio of model vs control)
				ppScore = [obj.postPred(:).score]';
				% Calculate point estimates of perceptPredicted. use the point
				% estimate type that the user specified
				pointEstFunc = str2func(obj.pointEstimateType);
				percentPredicted = cellfun(pointEstFunc,...
					{obj.postPred.percentPredictedDistribution})';
				
				% Check if HDI of percentPredicted overlaps with 0.5
				hdiFunc = @(x) HDIofSamples(x, CREDIBLE_INTERVAL);
				warningFunc = @(x) x(1) < 0.5;
				warnOnHDI = @(x) warningFunc( hdiFunc(x) );
				warning_percent_predicted = cellfun( warnOnHDI,...
					{obj.postPred.percentPredictedDistribution})';
				
				% make table
				postPredTable = table(ppScore,...
					percentPredicted,...
					warning_percent_predicted,...
					'RowNames', obj.data.getIDnames('participants'));
				if obj.data.unobservedPartipantPresent
					% add extra row of NaN's on the bottom for the unobserved participant
					unobserved = table(NaN, NaN, NaN,...
						'RowNames', obj.data.getIDnames('group'),...
						'VariableNames', postPredTable.Properties.VariableNames);
					postPredTable = [postPredTable; unobserved];
				end
				
			end
		end
		
		
		
		function plot(obj, varargin)
			
			% parse inputs
			p = inputParser;
			p.FunctionName = mfilename;
			p.addParameter('shouldExportPlots', true, @islogical);
			p.parse(varargin{:});
			
			% act on inputs
			obj.alldata.shouldExportPlots = p.Results.shouldExportPlots;
			for n=1:numel(obj.pdata)
				obj.pdata(n).shouldExportPlots = p.Results.shouldExportPlots;
			end
			
			%% Plot functions that use data from all participants
			figUnivariateSummary( obj.alldata )
			
			% TODO: pass in obj.alldata or obj.pdata rather than all these args
			obj.plotFuncs.clusterPlotFunc(...
				obj.coda,...
				obj.data,...
				[1 0 0],...
				obj.pointEstimateType,...
				obj.savePath,...
				obj.modelType,...
				p.Results.shouldExportPlots)
			
			%% Plots, one per participant
			%arrayfun(@figParticipant, obj.pdata, obj.participantFigPlotFuncs) % multi-panel fig
			% TODO: replace this loop with use of partials
			% 			partial = @(x) figParticipant(x, obj.participantFigPlotFuncs);
			% 			arrayfun(partial, obj.pdata)
			for p=1:numel(obj.pdata)
				figParticipant(obj.participantFigPlotFuncs, obj.pdata(p));
			end
			
			arrayfun(@plotTriPlotWrapper, obj.pdata) % corner plot of posterior
			arrayfun(@figPosteriorPrediction, obj.pdata) % posterior prediction plot
		end
			
		
		
		% MIDDLE-MAN METHODS ================================================
		
		function obj = plotMCMCchains(obj,vars)
			obj.coda.plotMCMCchains(vars);
		end
		
	end
	
	
	methods (Access = protected)
		
		function observedData = constructObservedDataForMCMC(obj, all_data)
			% This function can be overridden by model subclasses, however
			% we still expect them to call this model baseclass method to
			% set up the core data (unlikely to change across models).
			assert(istable(all_data), 'all_data must be a table')
			observedData = table2struct(all_data, 'ToScalar',true);
			
			% Pass in a vector of [1,...P] where P is the number of
			% participants. BUT hierarchical models will have an extra
			% (unobserved) participant, so we need to be sensitive to
			% whether this exists of not
			if obj.data.unobservedPartipantPresent
				observedData.participantIndexList = [unique(all_data.ID) ; max(unique(all_data.ID))+1];
			else
				observedData.participantIndexList = unique(all_data.ID);
			end
			
			observedData.nRealParticipants	= max(all_data.ID);
			observedData.totalTrials		= height(all_data);
			% protected method which can be over-ridden by model sub-classes
			observedData = obj.addititional_model_specific_ObservedData(observedData);
		end
		
		
		function [pdata, alldata] = packageUpDataForPlotting(obj)
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			% Package up all information into data structures to be sent
			% off to plotting functions.
			% The idea being we can just pass pdata(n) to a plot function
			% and it has all the information it needs
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			nRealExperiments = obj.data.nExperimentFiles;
			nExperimentsIncludingUnobserved = numel(obj.data.getIDnames('all')); % TODO: replace with different get method
			
			pdata(1:nExperimentsIncludingUnobserved) = struct; % preallocation
			for p = 1:nExperimentsIncludingUnobserved
				% gather data from this experiment
				pdata(p).data.totalTrials				= obj.data.totalTrials;
				pdata(p).IDname							= obj.data.getIDnames(p);
				pdata(p).data.trialsForThisParticant	= obj.data.getTrialsForThisParticant(p);
				pdata(p).data.rawdata					= obj.data.getRawDataTableForParticipant(p);
				% gather posterior prediction info
				try
					pdata(p).postPred					= obj.postPred(p);
				catch
					pdata(p).postPred					= [];
				end
				% gather mcmc samples
				pdata(p).samples.posterior	= obj.coda.getSamplesAtIndex(p, obj.varList.participantLevel);
				% other misc info
				pdata(p).pointEstimateType	= obj.pointEstimateType;
				pdata(p).discountFuncType	= obj.discountFuncType;
				pdata(p).savePath			= obj.savePath;
				pdata(p).modelType			= obj.modelType;
				pdata(p).shouldExportPlots  = obj.shouldExportPlots;
			end
			
			% gather cross-experiment data for univariate stats
			alldata.shouldExportPlots = obj.shouldExportPlots;
			alldata.variables	= obj.varList.participantLevel;
			alldata.IDnames		= obj.data.getIDnames('all');
			alldata.savePath	= obj.savePath;
			alldata.modelType	= obj.modelType;
			for v = alldata.variables
				alldata.(v{:}).hdi =...
					[obj.coda.getStats('hdi_low',v{:}),... % TODO: ERROR - expecting a vector to be returned
					obj.coda.getStats('hdi_high',v{:})]; % TODO: ERROR - expecting a vector to be returned
				alldata.(v{:}).pointEstVal =...
					obj.coda.getStats(obj.pointEstimateType, v{:});
			end
		end
		
		
		function postPred = calcPosteriorPredictive(obj)
			%calcPosteriorPredictive Calculate various posterior predictive measures.
			% Data saved to a struture: postPred(p).xxx
			
			display('Calculating posterior predictive measures...')
			
			for p = 1:obj.data.nRealParticipants;
				% get data 
				trialIndOfThisParicipant	= obj.observedData.ID==p;
				responses_inferredPB		= obj.coda.getPChooseDelayed(trialIndOfThisParicipant);
				responses_actual			= obj.data.getParticipantResponses(p);
				responses_predicted			= obj.coda.getParticipantPredictedResponses(trialIndOfThisParicipant);
				
				% Calculate metrics
				postPred(p).score							= calcPostPredOverallScore(responses_predicted, responses_actual);
				postPred(p).GOF_distribtion					= calcGoodnessOfFitDistribution(responses_inferredPB, responses_actual);
				postPred(p).percentPredictedDistribution	= calcPercentResponsesCorrectlyPredicted(responses_inferredPB, responses_actual);
				% Store
				postPred(p).responses_actual	= responses_actual;
				postPred(p).responses_predicted = responses_predicted;
			end
		end
		
		
		function tellUserAboutPublicMethods(obj)
			% TODO - the point is to guide them into what to do next
			methods(obj)
		end

		
		function obj = addUnobservedParticipant(obj, str)
			% TODO: Check we need this
			obj.data = obj.data.add_unobserved_participant(str);	% add name (eg 'GROUP')
		end
	end
	
	methods (Static, Access = protected)
		
		function observedData = addititional_model_specific_ObservedData(observedData)
			% KEEP THIS HERE. IT IS OVER-RIDDEN IN SOME MODEL SUB-CLASSES
		end
	end
	
end
