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
		participantFigPlotFuncs
	end

	properties (Hidden)
		% User supplied preferences
		mcmcSamples, chains, burnin % mcmcparams
		modelType % string (ie modelType.jags, or modelType.stan)
		data % handle to Data class (dependency is injected from outside)
		varList
		plotFuncs % structure of function handles
		shouldPlot
		unobservedParticipantExist
		observedData % TODO make this  in model?
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

            % This flag is over-ridden by model sub-classes that do hierarchical inference.
			obj.unobservedParticipantExist = false;

			obj.observedData = obj.constructObservedDataForMCMC( obj.data.get_all_data_table() );
		end


		function obj = conductInference(obj, varargin)
			% conductInference  Runs inference
			%   conductInference(samplerType, varargin)

			p = inputParser;
			p.FunctionName = mfilename;
			p.addParameter('samplerType', 'jags', @(x) any(strcmp(x,{'jags','stan'})));
			p.addParameter('mcmcSamples', [], @isscalar)
			p.addParameter('chains', [], @isscalar)
			p.addParameter('burnin', [], @isscalar)
			p.addParameter('shouldPlot', 'no', @(x) any(strcmp(x,{'yes','no'})));
			p.parse(varargin{:});

			obj.modelFile = makeProbModelsPath(obj.modelType, lower(p.Results.samplerType));

			% add p.Results fields into obj
			% but not sampler
			fields = fieldnames(p.Results);
			for n = 1:numel(fields)
				%if strcmp(fields,'sampler'), continue, end % skip this field
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
			if ~isempty(p.Results.chains) % TODO: THIS IS NOT WORKING
				obj.sampler.mcmcparams.nchains = p.Results.chains;
				if obj.sampler.mcmcparams.nchains <= 0
					obj.sampler.mcmcparams.nchains = 2;
				end
			end
			if ~isempty(p.Results.burnin)
				obj.sampler.mcmcparams.burnin = p.Results.burnin;
			end

			%% Do MCMC sampling, return an mcmcObject ---------------------
			obj.mcmc = obj.sampler.conductInference( obj );

			%% Post-sampling activities (for model sub-classes) -----------
			% If a model has additional measures that need to be calculated
			% from the MCMC samples, then we can do by overriding this
			% method in the model sub-classes
			obj = obj.calcDerivedMeasures();

			%% Post-sampling activities (common to all models) ------------
			obj.postPred = calcPosteriorPredictive( obj );

			try
				obj.mcmc.convergenceSummary(obj.saveFolder, obj.data.IDname)
			catch
				warning('mcmc.convergenceSummary() FAILED')
			end

			try
				obj.parameterEstimateTable = obj.exportParameterEstimates();
			catch
				warning('exportParameterEstimates() FAILED')
			end

			[obj.pdata, obj.alldata] = obj.packageUpDataForPlotting();
			if ~strcmp(obj.shouldPlot,'no')
				obj.plot()
			end

			obj.tellUserAboutPublicMethods()
		end


		function finalTable = exportParameterEstimates(obj, varargin)
			%% Make tables
			paramEstimateTable = obj.mcmc.exportParameterEstimates(...
				obj.varList.participantLevel,... %obj.varList.groupLevel,...
				obj.data.IDname,...
				obj.saveFolder,...
				obj.pointEstimateType,...
				varargin{:});

			postPredTable = makePostPredTable();

			%% Horizontally join the tables
			finalTable = join(paramEstimateTable, postPredTable,...
				'Keys','RowNames');
			display(finalTable)

			%% Export to textfile
			savePath = fullfile('figs',...
				obj.saveFolder,...
				['parameterEstimates_Posterior_' obj.pointEstimateType '.csv']);
			exportTable(finalTable, savePath);

			function postPredTable = makePostPredTable()
				% Create table of posterior prediction measures
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
					'RowNames', obj.data.IDname([1:obj.data.nParticipants])');
				if obj.unobservedParticipantExist
					% add extra row of NaN's on the bottom for the unobserved participant
					unobserved = table(NaN, NaN, NaN,...
						'RowNames', obj.data.IDname(end),...
						'VariableNames', postPredTable.Properties.VariableNames);
					postPredTable = [postPredTable; unobserved];
				end

			end
		end

		function [pdata, alldata] = packageUpDataForPlotting(obj)
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			% Package up all information into data structures to be sent
			% off to plotting functions.
			% The idea being we can just pass pdata(n) to a plot function
			% and it has all the information it needs
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			for p = 1:obj.data.nParticipants
				% gather data from this experiment
				pdata(p).data.totalTrials				= obj.data.totalTrials;
				pdata(p).IDname							= obj.data.IDname{p};
				pdata(p).data.trialsForThisParticant	= obj.data.participantLevel(p).trialsForThisParticant;
				pdata(p).data.rawdata					= obj.data.participantLevel(p).table;
				% gather posterior prediction info
				pdata(p).postPred						= obj.postPred(p);
				% gather mcmc samples
				pdata(p).samples.posterior	= obj.mcmc.getSamplesAtIndex(p, obj.varList.participantLevel);
				%obj.pdata(p).samples.prior		= obj.mcmc.getSamples(obj.varList.participantLevelPriors);
				% other misc info
				pdata(p).pointEstimateType	= obj.pointEstimateType;
				pdata(p).discountFuncType	= obj.discountFuncType;
				pdata(p).saveFolder			= obj.saveFolder;
				pdata(p).modelType			= obj.modelType;
			end
			if obj.unobservedParticipantExist
				% add info for unobserved participant ~~~~~
				p = obj.data.nParticipants + 1;
				pdata(p).data.totalTrials = [];
				pdata(p).IDname				= obj.data.IDname{p};
				pdata(p).data.trialsForThisParticant = [];
				pdata(p).data.rawdata		= [];
				pdata(p).postPred			= [];
				pdata(p).samples.posterior	= obj.mcmc.getSamplesAtIndex(p, obj.varList.participantLevel);
				pdata(p).pointEstimateType	= obj.pointEstimateType;
				pdata(p).discountFuncType	= obj.discountFuncType;
				pdata(p).saveFolder			= obj.saveFolder;
				pdata(p).modelType			= obj.modelType;
			end

			% gather cross-experiment data for univariate stats
			alldata.variables	= obj.varList.participantLevel;
			alldata.IDnames		= obj.data.IDname;
			alldata.saveFolder	= obj.saveFolder;
			alldata.modelType	= obj.modelType;
			for v = alldata.variables
				alldata.(v{:}).hdi =...
					[obj.mcmc.getStats('hdi_low',v{:}),... % TODO: ERROR - expecting a vector to be returned
					obj.mcmc.getStats('hdi_high',v{:})]; % TODO: ERROR - expecting a vector to be returned
				alldata.(v{:}).pointEstVal =...
					obj.mcmc.getStats(obj.pointEstimateType, v{:});
			end
		end

		function plot(obj)

			%arrayfun(@figParticipant, obj.pdata, obj.participantFigPlotFuncs) % multi-panel fig
			% TODO: replace this loop with use of partials
% 			partial = @(x) figParticipant(x, obj.participantFigPlotFuncs);
% 			arrayfun(partial, obj.pdata)
			for p=1:numel(obj.pdata)
				figParticipant(obj.participantFigPlotFuncs, obj.pdata(p));
			end

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
			if obj.unobservedParticipantExist
				observedData.participantIndexList = [unique(all_data.ID) ; max(unique(all_data.ID))+1];
			else
				observedData.participantIndexList = unique(all_data.ID);
			end

			% protected method which can be over-ridden by model sub-classes
			%observedData = obj.addititionalObservedData();

		end

		% MIDDLE-MAN METHODS ================================================

		function obj = plotMCMCchains(obj,vars)
			obj.mcmc.plotMCMCchains(vars);
		end

	end


	methods (Access = private)

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

	methods (Access = protected)
		function obj = addUnobservedParticipant(obj, str)
			% Ask data class to add an unobserved participant
			obj.data = obj.data.add_unobserved_participant(str);
			obj.unobservedParticipantExist = true;
			obj.observedData.participantIndexList(end+1) = ...
				max(obj.observedData.participantIndexList) + 1;
		end
	end

% 	methods (Static, Access = protected)
% 		function observedData = addititionalObservedData(observedData)
% 			% This is meant to be over-ridden by model sub-classes
% 		end
% 	end

end
