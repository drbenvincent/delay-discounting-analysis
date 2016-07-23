classdef Model
	%Model Base class to provide basic functionality
	
	properties (Access = public)
		samplerType
		saveFolder
		discountFuncType
		pointEstimateType
	end
	
	properties (SetAccess = protected, GetAccess = public)
		modelFile
		mcmc % handle to mcmc fit object  % TODO: dependency injection for MCMC fit object
		sampler % handle to SamplerWrapper class % TODO: dependency injection for SAMPLER
		postPred
		parameterEstimateTable
		pdata		% experiment level data for plotting
		alldata		% cross-experiment level data for plotting
		observedData % TODO make this  in model?
	end
	
	properties (Hidden)
		% User supplied preferences
		mcmcSamples
		chains
		modelType % string (ie modelType.jags, or modelType.stan)
		data % handle to Data class (dependency is injected from outside)
		varList
		plotFuncs % structure of function handles
		initialParams
		shouldPlot
	end
	
	methods(Abstract, Access = protected)
		calcDerivedMeasures(obj)
	end
	
	methods (Access = public)
		
		function obj = Model(data, varargin)
			p = inputParser;
			p.FunctionName = mfilename;
			p.addRequired('data', @(x) isa(x,'DataClass'));
			p.addParameter('saveFolder','my_analysis', @isstr);
			p.addParameter('pointEstimateType','mode',@(x) any(strcmp(x,{'mean','median','mode'})));
			p.parse(data, varargin{:});
			
			% add p.Results fields into obj
			fields = fieldnames(p.Results);
			for n=1:numel(fields)
				obj.(fields{n}) = p.Results.(fields{n});
			end
			
			% Upon model (base-class) construction, we are going to call
			% the method to construct the observed data which will be
			% passed into the mcmc sampler.
			% This method is defined here (in the base class) but can be
			% over-ridden by model sub-classes.
			all_data_table = data.get_all_data_table();
			obj.observedData = obj.constructObservedDataForMCMC(all_data_table);
		end
		
		
		function obj = conductInference(obj, samplerType, varargin)
			% conductInference  Runs inference
			%   conductInference(samplerType, varargin)
			
			% TODO: get the observed data from the raw group data here.
			samplerType     = lower(samplerType);
			
			obj.modelFile = makeProbModelsPath(obj.modelType, samplerType);
			
			p = inputParser;
			p.FunctionName = mfilename;
			p.addRequired('samplerType',@ischar);
			% additional user-supplied preferences
			p.addParameter('mcmcSamples',[], @isscalar)
			p.addParameter('chains',[], @isscalar)
			p.addParameter('shouldPlot','no',@(x) any(strcmp(x,{'yes','no'})));
			p.parse(samplerType, varargin{:});
			
			% add p.Results fields into obj
			fields = fieldnames(p.Results);
			for n=1:numel(fields)
				obj.(fields{n}) = p.Results.(fields{n});
			end
			
			%% Create sampler object --------------------------------------
			% Use of external function "samplerFactory" means this class is
			% closed for modification, but open to extension.
			% We can just add new concerete sampler wrappers to the
			% "samplerFactory" function.
			% If we passed in "samplerFactory" as a function then we could
			% make it easier to completely swap out types of samplers.
			obj.sampler = samplerFactory(p.Results.samplerType, obj.modelFile);
			
			% update with user-provided params
			if ~isempty(p.Results.mcmcSamples)
				obj.sampler.mcmcparams.nsamples = p.Results.mcmcSamples;
			end
			if ~isempty(p.Results.chains)
				obj.sampler.mcmcparams.nchains = p.Results.chains;
			end
			
			
			%% Ask the Sampler to do MCMC sampling, return an mcmcObject ~~~~~~~~~~~~~~~~~
			obj.mcmc = obj.sampler.conductInference( obj );
			%obj.mcmc = mcmcObject;
			% fix/check ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			
			%% Post-sampling activities (unique to a given model sub-class)
			% If a model has additional measures that need to be calculated
			% from the MCMC samples, then we can do by overriding this
			% method in the model sub-classes
			obj = obj.calcDerivedMeasures();
			
			%% Post-sampling activities (common to all models)
			obj.postPred = calcPosteriorPredictive( obj );
			%try
			obj.mcmc.convergenceSummary(obj.saveFolder, obj.data.IDname)
			%catch
			%	beep
			%	warning('**** convergenceSummary FAILED ****.\nProbably because things are not finished for STAN.')
			%end
			%try
			obj.exportParameterEstimates();
			%catch
			%	warning('*** exportParameterEstimates() FAILED ***')
			%	beep
			%end
			
			obj = obj.packageUpDataForPlotting();
			
			if ~strcmp(obj.shouldPlot,'no')
				obj.plot()
			end
			
			obj.tellUserAboutPublicMethods()
		end
		
		
		function finalTable = exportParameterEstimates(obj, varargin)
			%% Create table of parameter estimates
			paramEstimateTable = obj.mcmc.exportParameterEstimates(...
				obj.varList.participantLevel,... %obj.varList.groupLevel,...
				obj.data.IDname,...
				obj.saveFolder,...
				obj.pointEstimateType,...
				varargin{:});
			%% Create table of posterior prediction measures
			% Add mean score (log ratio of model vs control)
			ppScore = [obj.postPred(:).score]';
			% Calculate point estimates of perceptPredicted. use the point
			% estimate type that the user specified
			pointEstFunc = str2func(obj.pointEstimateType);
			percentPredicted = cellfun(pointEstFunc, {obj.postPred.percentPredictedDistribution})';
			
			% Check if HDI of percentPredicted overlaps with 0.5
			hdiFunc = @(x) mcmc.HDIofSamples(x, 0.95); % Using mcmc-utils-matlab package
			warningFunc = @(x) x(1) < 0.5;
			warnOnHDI = @(x) warningFunc( hdiFunc(x) );
			warning_percent_predicted = cellfun( warnOnHDI, {obj.postPred.percentPredictedDistribution})';
			
			% make table
			postPredTable = table(ppScore,...
				percentPredicted,...
				warning_percent_predicted,...
				'RowNames',obj.data.IDname(1:end-1)); %<---- TODO replace with get method
			% add extra row of NaN's on the bottom for the unobserved
			% participant
			unobserved = table(NaN, NaN, NaN,...
				'RowNames',obj.data.IDname(end),...
				'VariableNames', postPredTable.Properties.VariableNames)
			postPredTable = [postPredTable; unobserved];
			
			%% Combine the tables
			finalTable = join(paramEstimateTable, postPredTable,...
				'Keys','RowNames');
			display(finalTable)
			
			%% Export table to textfile
			fname = ['parameterEstimates_Posterior_' obj.pointEstimateType '.csv'];
			savePath = fullfile('figs',obj.saveFolder,fname);
			exportTable(finalTable, savePath);
			
			%% Store the table
			obj.parameterEstimateTable = finalTable;
			
		end
		
		function obj = packageUpDataForPlotting(obj)
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			% Package up all information into data structures to be sent
			% off to plotting functions.
			% The idea being we can just pass pdata(n) to a plot function
			% and it has all the information it needs
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			for p = 1:obj.data.nParticipants
				% gather data from this experiment
				obj.pdata(p).data.totalTrials				= obj.data.totalTrials;
				obj.pdata(p).IDname							= obj.data.IDname{p};
				obj.pdata(p).data.trialsForThisParticant	= obj.data.participantLevel(p).trialsForThisParticant;
				obj.pdata(p).data.rawdata					= obj.data.participantLevel(p).table;
				% gather posterior prediction info
				obj.pdata(p).postPred						= obj.postPred(p);
				% gather mcmc samples
				obj.pdata(p).samples.posterior	= obj.mcmc.getSamplesAtIndex(p, obj.varList.participantLevel);
				%obj.pdata(p).samples.prior		= obj.mcmc.getSamples(obj.varList.participantLevelPriors);
				% other misc info
				obj.pdata(p).pointEstimateType	= obj.pointEstimateType;
				obj.pdata(p).discountFuncType	= obj.discountFuncType;
				obj.pdata(p).saveFolder			= obj.saveFolder;
				obj.pdata(p).modelType			= obj.modelType;
			end
			% add info for unobserved participant ~~~~~
			p = obj.data.nParticipants + 1;
			obj.pdata(p).data.totalTrials = [];
			obj.pdata(p).IDname				= obj.data.IDname{p};
			obj.pdata(p).data.trialsForThisParticant = [];
			obj.pdata(p).data.rawdata		= [];
			obj.pdata(p).postPred			= [];
			obj.pdata(p).samples.posterior	= obj.mcmc.getSamplesAtIndex(p, obj.varList.participantLevel);
			obj.pdata(p).pointEstimateType	= obj.pointEstimateType;
			obj.pdata(p).discountFuncType	= obj.discountFuncType;
			obj.pdata(p).saveFolder			= obj.saveFolder;
			obj.pdata(p).modelType			= obj.modelType;
			
			% gather cross-experiment data for univariate stats
			obj.alldata.variables	= obj.varList.participantLevel;
			obj.alldata.IDnames		= obj.data.IDname;
			obj.alldata.saveFolder	= obj.saveFolder;
			obj.alldata.modelType	= obj.modelType;
			for var = obj.alldata.variables
				obj.alldata.(var{:}).hdi =...
					[obj.mcmc.getStats('hdi_low',var{:}),...
					obj.mcmc.getStats('hdi_high',var{:})];
				obj.alldata.(var{:}).pointEstVal =...
					obj.mcmc.getStats(obj.pointEstimateType, var{:});
			end
		end
		
		function obj = conditionalDiscountRates(obj, reward, plotFlag)
			% Extract and plot P( log(k) | reward)
			warning('THIS METHOD IS A TOTAL MESS - PLAN THIS AGAIN FROM SCRATCH')
			obj.conditionalDiscountRates_ParticipantLevel(reward, plotFlag)
			
			if plotFlag
				removeYaxis
				title(sprintf('$P(\\log(k)|$reward=$\\pounds$%d$)$', reward),'Interpreter','latex')
				xlabel('$\log(k)$','Interpreter','latex')
				axis square
			end
		end
		
		% MIDDLE-MAN METHODS ================================================
		
		function obj = plotMCMCchains(obj,vars)
			obj.mcmc.plotMCMCchains(vars);
		end
		
	end
	
	
	methods (Access = private)
		
		function varNames = extractLevelNVarNames(obj, N)
			error('is this dead code?')
			varNames={};
			for var = each(fieldnames(obj.variables))
				if obj.variables.(var).analysisFlag == N
					varNames{end+1} = var;
				end
			end
		end
		
		function bool = isGroupLevelModel(obj)
			error('is this dead code?')
			% we determine if the model has group level parameters by checking if
			% we have a 'groupLevel' subfield in the varList.
			if isfield(obj.varList,'groupLevel')
				bool = ~isempty(obj.varList.groupLevel);
			end
		end
		
		function tellUserAboutPublicMethods(obj)
			methods(obj)
		end
		
		function conditionalDiscountRates_ParticipantLevel(obj, reward, plotFlag)
			nParticipants = obj.data.nParticipants;
			%count=1;
			for p = 1:nParticipants
				params(:,1) = obj.mcmc.getSamplesFromParticipantAsMatrix(p, {'m'});
				params(:,2) = obj.mcmc.getSamplesFromParticipantAsMatrix(p, {'c'});
				% ==============================================
				[posteriorMean(p), lh(p)] =...
					calculateLogK_ConditionOnReward(reward, params, plotFlag);
				%lh(count).DisplayName=sprintf('participant %d', p);
				%row(count) = {sprintf('participant %d', p)};
				% ==============================================
				%count=count+1;
			end
			warning('GET THESE NUMBERS PRINTED TO SCREEN')
			% 			logkCondition = array2table([posteriorMode'],...
			% 				'VariableNames',{'logK_posteriorMode'},...)
			% 				'RowNames', num2cell([1:nParticipants]) )
		end
		
	end
	
	
	methods (Static)
		
		function observedData = constructObservedDataForMCMC(all_data)
			% construct a structure of ObservedData which will provide input to
			% the MCMC process.
			assert(istable(all_data), 'all_data must be a table')
			% TODO: can this become a static method?
			
			%% Convert each column of table in to a field of a structure
			% As wanted by JAGS/STAN
			variables = all_data.Properties.VariableNames;
			for varname = variables
				observedData.(varname{:}) = all_data.(varname{:});
			end

			% add on an unobserved participant
			observedData.participantIndexList = [unique(all_data.ID) ; max(unique(all_data.ID))+1];
			
			% **** Observed variables below are for the Gaussian Random Walk model ****
			observedData.uniqueDelays = sort(unique(observedData.DB))';
			observedData.delayLookUp = calcDelayLookup();
			
			function delayLookUp = calcDelayLookup()
				delayLookUp = observedData.DB;
				for n=1: numel(observedData.uniqueDelays)
					delay = observedData.uniqueDelays(n);
					delayLookUp(observedData.DB==delay) = n;
				end
			end
		end
		
		% 			% **** Observed variables below are for the Gaussian Random
		% 			% Walk model ****
		% 			%
		% 			% Create a lookup table, for a given [participant,trial], this
		% 			% is the index of DB.
		%
		% 			% If we insert additional delays into this vector
		% 			% (uniqueDelays), then the model will interpolate between the
		% 			% delays that we have data for.
		% 			% If you do not want to interpolate any delays, then set :
		% 			%  interpolation_delays = []
		%
		% % 			unique_delays_from_data = sort(unique(obj.observedData.DB))';
		% % 			% optionally add interpolated delays ~~~~~~~~~~~~~~~~~~~~~~~~~~~
		% % 			add_interpolated_delays = true;
		% % 			if add_interpolated_delays
		% % 				interpolation_delays =  [ [7:7:365-7] ...
		% % 					[7*52:7:7*80]]; % <--- future
		% % 				combined = [unique_delays_from_data interpolation_delays];
		% % 				obj.observedData.uniqueDelays = sort(unique(combined));
		% % 			else
		% % 				obj.observedData.uniqueDelays = [0.01 unique_delays_from_data];
		% % 			end
		% % 			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		% %
		% % 			% Now we create a lookup table [participants,tials] full of
		% % 			% integers which point to the index of the delay value in
		% % 			% uniqueDelays
		% % 			temp = obj.observedData.DB;
		% % 			for n=1: numel(obj.observedData.uniqueDelays)
		% % 				delay = obj.observedData.uniqueDelays(n);
		% % 				temp(obj.observedData.DB==delay) = n;
		% % 			end
		% % 			obj.observedData.delayLookUp = temp;
		% 		end
		
	end
	
	% **********************************************************************
	% PLOTTING *************************************************************
	% **********************************************************************
	
	methods (Access = public)
		
		function plot(obj)
			arrayfun(obj.plotFuncs.participantFigFunc, obj.pdata) % multi-panel fig
			arrayfun(@plotTriPlotWrapper, obj.pdata) % corner plot of posterior
			arrayfun(@figPosteriorPrediction, obj.pdata) % posterior prediction plot
			
			%% Plot functions that use data from all participants
			figUnivariateSummary( obj.alldata )
			
			% TODO: pass in obj.alldata or obj.pdata rather than all these args
			obj.plotFuncs.clusterPlotFunc(...
				obj.mcmc,...
				obj.data,...
				[1 0 0],...
				obj.pointEstimateType,...
				obj.saveFolder,...
				obj.modelType)
		end
		
	end
	
end
