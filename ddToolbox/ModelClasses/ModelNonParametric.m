%KIRBY DATA IS NOT APPROPRIATE FOR THIS MODEL
% We need experimental paradigms that try to pinpoint the indifference
% point for a set number of delays.

classdef ModelNonParametric < Model
	%ModelGRW
	
	properties
		AUC_DATA
	end
	
	
	methods (Access = public)
		
		function obj = ModelNonParametric(data, varargin)
			obj = obj@Model(data, varargin{:});
			
			obj.modelType		= 'separateNonParametric';
			obj.discountFuncType = 'nonparametric';
			
			obj.varList.participantLevel = {'discountFraction'};
			% TODO: remove varList as a property of Model base class.
			obj.varList.monitored = {'discountFraction', 'alpha', 'epsilon', 'Rpostpred', 'P'};
			
			%obj.observedData = obj.addititionalObservedData( obj.observedData );
			
			% Define plotting functions for the participant mult-panel figure
			obj.experimentFigPlotFuncs{1} = @(plotdata) mcmc.BivariateDistribution(...
				plotdata.samples.posterior.epsilon,...
				plotdata.samples.posterior.alpha,...
				'xLabel','error rate, $\epsilon$',...
				'ylabel','comparison accuity, $\alpha$',...
				'pointEstimateType', plotdata.pointEstimateType,...
				'plotStyle', 'hist');
			
			obj.experimentFigPlotFuncs{2} = @(plotdata) plotPsychometricFunc(plotdata.samples, plotdata.pointEstimateType);
			
			% TODO: FIX THIS
			%obj.experimentFigPlotFuncs{3} = @(personInfo) plotDiscountFunctionGRW(personInfo,  [50 95]);
			
			% Decorate the object with appropriate plot functions
			obj.plotFuncs.clusterPlotFunc = @() []; % null func
			
			% MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
			obj = obj.conductInference();
		end
		
		
		function initialParams = setInitialParamValues(obj, nchains)
			% Generate initial values of the leaf nodes
			%nTrials = size(obj.data.observedData.A,2);
			nExperimentFiles = obj.data.nExperimentFiles;
			nUniqueDelays = numel(obj.observedData.uniqueDelays);
			
			for chain = 1:nchains
				initialParams(chain).discountFraction = normrnd(1, 0.1, [nExperimentFiles, nUniqueDelays]);
			end
			% TODO: have a function called discountFraction and pass it
			% into this initialParam maker loop
		end
		
		
		function conditionalDiscountRates(obj, reward, plotFlag)
			error('Not applicable to this model')
		end
		
		
		function conditionalDiscountRates_GroupLevel(obj, reward, plotFlag)
			error('Not applicable to this model')
		end
		
	end
	
	
	methods (Access = protected)
		
		function obj = calcDerivedMeasures(obj)
			obj = obj.calcAUCscores();
		end
		
		function obj = calcAUCscores(obj)
			% TODO: TOTAL FUDGE. THIS SHOULD BE DONE ELSEWHERE
			%obj.observedData = obj.constructObservedDataForMCMC( obj.data.get_all_data_table() ); % TODO: do this in base-class
			delays = obj.observedData.uniqueDelays;
			for p=1:obj.data.nExperimentFiles
				dfSamples = obj.extractDiscountFunctionSamples(p);
				obj.AUC_DATA(p).AUCsamples = calculateAUC(delays,dfSamples, false);
				obj.AUC_DATA(p).name  = obj.data.getIDnames(p);
			end
		end
		
	end
	
	
	methods (Static, Access = protected)
		function observedData = addititional_model_specific_ObservedData(observedData)
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
	end
	
	
	
	
	
	
	
	
	
	
	methods (Access = public)
		
		function plot(obj, varargin) % overriding from Model base class
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
			
			close all
			warning('SORT THIS PLOT FUNCTION OUT!')
			
			
			%% WORKS
			arrayfun(@figPosteriorPrediction, obj.pdata) % posterior prediction plot
			
			
			% Plot indifference functions for each participant
			obj.calcAUCscores()
			for p=1:obj.data.nExperimentFiles
				% Extract info about a person for plotting purposes
				personInfo = obj.getExperimentData(p);
				
				% Plotting
				figure(1), clf
				
				subplot(1,2,1) % TODO: PUT THIS PLOT IN THE PARTICIPANT PLOT FUNCTIONS
				intervals = [50 95];
				plotDiscountFunctionGRW(personInfo)
				latex_fig(16, 14, 4)
				%set(gca,'XScale','log')
				%axis tight
				%axis square
				
				subplot(1,2,2)
				uni = mcmc.UnivariateDistribution(obj.AUC_DATA(p).AUCsamples,...
					'xLabel', 'AUC');
				drawnow
				
				if obj.shouldExportPlots
					myExport(obj.savePath,...
						'discountfunction',...
						'suffix', obj.modelType,...
						'prefix', num2str(p))
				end

				% 				myExport('discountfunction',...
				% 					'savePath', obj.savePath,...
				% 					'prefix', personInfo.participantName)
			end
			
			
			%% DOES NOT WORK
			
			% 			for p=1:obj.data.nExperimentFiles
			% 				personInfo = obj.getExperimentData(p);
			% 				plotDiscountFunctionGRW(personInfo)
			% 			end
			%
			%
			% 			%% Plot functions that use data from all participants
			% 			%figUnivariateSummary( obj.alldata )
			%
			%
			% 			%% Plots, one per participant
			% 			%arrayfun(@figExperiment, obj.pdata, obj.experimentFigPlotFuncs) % multi-panel fig
			% 			% TODO: replace this loop with use of partials
			% 			% 			partial = @(x) figExperiment(x, obj.experimentFigPlotFuncs);
			% 			% 			arrayfun(partial, obj.pdata)
			% 			for p=1:numel(obj.pdata)
			% 				figExperiment(obj.experimentFigPlotFuncs, obj.pdata(p));
			% 			end
			%
			% 			arrayfun(@plotTriPlotWrapper, obj.pdata) % corner plot of posterior
			%
			%
			% 		end
			%
			%
			
		end
		
		
		
		
		function personStruct = getExperimentData(obj, p)
			
			obj = calcAUCscores(obj); % TODO: This is put here as a quick fix.
			
			% Create a structure with all the useful info about a person
			% p = person number
			participantName = obj.data.getIDnames(p);
			try
				parts = strsplit(participantName,'-');
				personStruct.participantName = strjoin(parts(1:2),'-');
			catch
				personStruct.participantName = participantName;
			end
			personStruct.delays = obj.observedData.uniqueDelays;
			personStruct.dfSamples = obj.extractDiscountFunctionSamples(p);
			personStruct.data = obj.data.getExperimentData(p);
			personStruct.AUCsamples = obj.AUC_DATA(p).AUCsamples;
		end
		
		
		
		function dfSamples = extractDiscountFunctionSamples(obj, personNumber)
			samples = obj.coda.getSamples({'discountFraction'});
			[chains, nSamples, participants, nDelays] = size(samples.discountFraction);
			personSamples = squeeze(samples.discountFraction(:,:,personNumber,:));
			% collapse over chains
			for d=1:nDelays
				dfSamples(:,d) = vec(personSamples(:,:,d));
			end
		end
		
		
		% 		function observedData = constructObservedDataForMCMC(obj, all_data)
		% 			%% Call superclass method to prepare the core data
		% 			observedData = constructObservedDataForMCMC@Model(obj, all_data);
		%
		% 			%% Now add model specific observed data
		% 			observedData.uniqueDelays = sort(unique(observedData.DB))';
		% 			observedData.delayLookUp = calcDelayLookup();
		%
		% 			function delayLookUp = calcDelayLookup()
		% 				delayLookUp = observedData.DB;
		% 				for n=1: numel(observedData.uniqueDelays)
		% 					delay = observedData.uniqueDelays(n);
		% 					delayLookUp(observedData.DB==delay) = n;
		% 				end
		% 			end
		% 		end
		
	end
	
	
	methods (Static)
		
		%% FYI
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
	
end
