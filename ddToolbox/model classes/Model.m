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
			
			%% Create sampler object
			% TODO: This can happen on the fly, when we call model.conduct_inference()
			switch obj.samplerType
				case{'jags'}
					% Create sampler object
					obj.sampler = MatjagsWrapper(obj.modelFile);
					
					% override any user-defined prefs
					if ~isempty( p.Results.mcmcSamples )
						obj.sampler.mcmcparams.nsamples = p.Results.mcmcSamples;
					end
					if ~isempty( p.Results.chains )
						obj.sampler.mcmcparams.chains = p.Results.chains;
					end
					
				case{'stan'}
					obj.sampler = MatlabStanWrapper(obj.modelFile);
					%obj.sampler.setStanHome('~/cmdstan-2.9.0') % TODO: sort this out
					
					% override any user-defined prefs
					if ~isempty( p.Results.mcmcSamples )
						obj.sampler.mcmcparams.iter = p.Results.mcmcSamples;
					end
					if ~isempty( p.Results.chains )
						obj.sampler.mcmcparams.chains = p.Results.chains;
					end
					
			end
			
			%% Ask the Sampler to do MCMC sampling, return an mcmcObject ~~~~~~~~~~~~~~~~~
			%obj.mcmc = obj.sampler.conductInference( obj , obj.data );
			obj.mcmc = obj.sampler.conductInference( obj , obj.data );
			%obj.mcmc = mcmcObject;
			% fix/check ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
			
			%% Post-sampling activities (unique to a given model sub-class)
			% If a model has additional measures that need to be calculated
			% from the MCMC samples, then we can do by overriding this
			% method in the model sub-classes
			obj = obj.calcDerivedMeasures();
			
			%% Post-sampling activities (common to all models)
			obj.postPred = calcPosteriorPredictive( obj );
			try
				obj.mcmc.convergenceSummary(obj.saveFolder, obj.data.IDname)
			catch
				beep
				warning('**** convergenceSummary FAILED ****.\nProbably because things are not finished for STAN.')
			end
			try
				obj.exportParameterEstimates();
			catch
				warning('*** exportParameterEstimates() FAILED ***')
				beep
			end
			
			obj = obj.packageUpDataForPlotting();
			
			% Deal with plotting options
			if ~strcmp(obj.shouldPlot,'no')
				obj.plot()
			end
			
			obj.tellUserAboutPublicMethods()
		end
		
		
		function finalTable = exportParameterEstimates(obj, varargin)
			%% Create table of parameter estimates
			paramEstimateTable = obj.mcmc.exportParameterEstimates(...
				obj.varList.participantLevel,...
				obj.varList.groupLevel,...
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
			for p=1:obj.data.nParticipants
				percentPredicted(p,1) = pointEstFunc( obj.postPred(p).percentPredictedDistribution );
			end
			% Check if HDI of percentPredicted overlaps with 0.5
			% Using mcmc-utils-matlab package
			for p=1:obj.data.nParticipants
				[HDI] = mcmc.HDIofSamples(...
					obj.postPred(p).percentPredictedDistribution,...
					0.95);
				if HDI(1)<0.5
					warning_percent_predicted(p,1) = true;
				else
					warning_percent_predicted(p,1) = false;
				end
			end
			% make table
			postPredTable = table(ppScore,...
				percentPredicted,...
				warning_percent_predicted,...
				'RowNames',obj.data.IDname);
			
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
				obj.pdata(p).samples.prior		= obj.mcmc.getSamples(obj.varList.participantLevelPriors);
				% other misc info
				obj.pdata(p).pointEstimateType	= obj.pointEstimateType;
				obj.pdata(p).discountFuncType	= obj.discountFuncType;
				obj.pdata(p).saveFolder			= obj.saveFolder;
				obj.pdata(p).modelType			= obj.modelType;
			end
			% gather cross-experiment data for univariate stats
			obj.alldata.variables	= obj.varList.participantLevel;
			obj.alldata.IDnames		= obj.data.IDname;
			obj.alldata.saveFolder	= obj.saveFolder;
			obj.alldata.modelType	= obj.modelType;
			for var = obj.alldata.variables
				templow		= obj.mcmc.getStats('hdi_low',var{:});
				temphigh	= obj.mcmc.getStats('hdi_high',var{:});
				tempPE		= obj.mcmc.getStats(obj.pointEstimateType, var{:});
				obj.alldata.(var{:}).hdi			= [templow, temphigh];
				obj.alldata.(var{:}).pointEstVal	= tempPE;
			end
			% TODO: Do we have group info in obj.alldata?
			
			% CREATE GROUP LEVEL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if ~isempty (obj.varList.groupLevel)
				p=numel(obj.pdata)+1;
				
				group_level_prior_variables = cellfun(...
					@getPriorOfVariable,...
					obj.varList.groupLevel,...
					'UniformOutput',false );
				
				% strip the '_group' off of variablenames
				for n=1:numel(obj.varList.groupLevel)
					temp=regexp(obj.varList.groupLevel{n},'_','split');
					groupLevelVarName{n} = temp{1};
				end
				[pSamples] = obj.mcmc.getSamples(obj.varList.groupLevel);
				% flatten
				for n=1:numel(obj.varList.groupLevel)
					pSamples.(obj.varList.groupLevel{n}) = vec(pSamples.(obj.varList.groupLevel{n}));
				end
				% rename
				pSamples = renameFields(...
					pSamples,...
					obj.varList.groupLevel,...
					groupLevelVarName);
				
				% gather data from this experiment
				obj.pdata(p).data.totalTrials = obj.data.totalTrials;
				obj.pdata(p).IDname = 'GROUP';
				obj.pdata(p).data.trialsForThisParticant = 0;
				obj.pdata(p).data.rawdata = [];
				% gather posterior prediction info
				obj.pdata(p).postPred = [];
				% gather mcmc samples
				obj.pdata(p).samples.posterior	= pSamples;
				obj.pdata(p).samples.prior		= obj.mcmc.getSamples(obj.varList.participantLevelPriors);
				% other misc info
				obj.pdata(p).pointEstimateType = obj.pointEstimateType;
				obj.pdata(p).discountFuncType = obj.discountFuncType;
				obj.pdata(p).saveFolder = obj.saveFolder;
				obj.pdata(p).modelType = obj.modelType;
			end
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
			varNames={};
			for var = each(fieldnames(obj.variables))
				if obj.variables.(var).analysisFlag == N
					varNames{end+1} = var;
				end
			end
		end
		
		function bool = isGroupLevelModel(obj)
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
	
	
	% **********************************************************************
	% **********************************************************************
	% PLOTTING *************************************************************
	% **********************************************************************
	% **********************************************************************
	
	methods (Access = public)
		
		function plot(obj)
			% plot
			% Plot experiment-level + group-level (if applicable) figures.
			for n = 1:numel(obj.pdata)
				% multi-panel fig
				obj.plotFuncs.participantFigFunc( obj.pdata(n) );
				
				% corner plot of posterior
				plotTriPlotWrapper( obj.pdata(n) )
				
				% posterior prediction plot
				figPosteriorPrediction( obj.pdata(n) )
			end
			
			% Plot functions that use data from all participants
			figUnivariateSummary( obj.alldata )
			
		end
		
	end
	
	methods (Access = private)
		
		% +++++++++++++++++++++++++++++++++++++++++++
		% TODO: IS THIS BEING CALLED?
		% +++++++++++++++++++++++++++++++++++++++++++
		
		
		function summary_plot(obj)
			%% SUMMARY PLOTS
			switch obj.discountFuncType
				case{'me'} % code smell
					% MC cluster plot
					probMass = 0.5; % <-- 50% prob mass to avoid too much clutter on graph
					% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
					figure(12)
					plotMCclusters(obj.mcmc,...
						obj.data, [1 0 0],...
						probMass,...
						obj.pointEstimateType)
					% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
					myExport('MC_summary',...
						'saveFolder', obj.saveFolder,...
						'prefix', obj.modelType)
					
				case{'logk'}
					% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
					figure(12)
					plotLOGKclusters(obj.mcmc, obj.data, [1 0 0], obj.pointEstimateType)
					% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
					myExport('LOGK_summary',...
						'saveFolder', obj.saveFolder,...
						'prefix', obj.modelType)
			end
		end
		
	end
	
end
