classdef (Abstract) NonParametric < Model
	%NonParametric  NonParametric is a subclass of Model for examining models that do NOT make parametric assumptions about the discount function.
	
	properties (Access = private)
		%AUC_DATA
	end
	
	methods (Access = public)
		
		function obj = NonParametric(data, varargin)
			obj = obj@Model(data, varargin{:});
			obj.dfClass = @DF_NonParametric;
			% Create variables
			obj.varList.participantLevel = {'Rstar'};
			obj.varList.monitored = {'Rstar', 'alpha', 'epsilon', 'Rpostpred', 'P'};
			
			obj.varList.discountFunctionParams(1).name = 'Rstar';
			obj.varList.discountFunctionParams(1).label = 'Rstar';
			
			obj.plotOptions.dataPlotType = '2D';
		end
		
		
		% % TODO: do this by injecting new AUC values into CODA?
		% function [auc] = getAUC(obj)
		% 	% return AUC measurements.
		% 	% This will return an object array of stocastic objects
		% 	names = obj.data.getIDnames('all');
		% 	
		% 	for ind = 1:numel(names)
		% 		personInfo = obj.getExperimentData(ind);
		% 		discountFunction = obj.dfClass('delays',personInfo.delays,...
		% 			'theta', personInfo.dfSamples);
		% 		
		% 		% append to object array
		% 		auc(ind) = discountFunction.AUC;
		% 	end
		% end
		
	end
	
    methods (Hidden = true)
        function dispModelInfo(obj)
            display('Discount function: fits indiferrence points to each delay independently')
        end
    end
	
	methods (Static, Access = protected)
		
		function observedData = additional_model_specific_ObservedData(observedData)
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
	
	methods (Access = private)
		
		% TODO: All this will be removed once refactoring of
		function personStruct = getExperimentData(obj, p)
			
			
			
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
			
			% TODO: THIS IS A BOTCH ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			% the model currently assumes all participants have been
			% tested on the same set of delays. But this is not
			% necessarily true. So here we need to exclude inferences
			% about discount fractions for delays that this person was
			% never tested on.
			
			% want to remove:
			% - columns of personStruct.dfSamples
			% - personStruct.delays
			% where this person was not tested on this delay
			
			temp = obj.data.getRawDataTableForParticipant(p);
			delays_tested = unique(temp.DB);
			
			keep = ismember(personStruct.delays, delays_tested);
			
			personStruct.delays = personStruct.delays(keep);
			personStruct.dfSamples = personStruct.dfSamples(:,keep);
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		end
		
		function dfSamples = extractDiscountFunctionSamples(obj, personNumber)
			samples = obj.coda.getSamples({'Rstar'});
			[chains, nSamples, participants, nDelays] = size(samples.Rstar);
			personSamples = squeeze(samples.Rstar(:,:,personNumber,:));
			% collapse over chains
			for d=1:nDelays
				dfSamples(:,d) = vec(personSamples(:,:,d));
			end
		end
		
	end
	
	
	
	
	
	% ==========================================================================
	% ==========================================================================
	% PLOTTING
	% ==========================================================================
	% ==========================================================================
	
	methods (Access = public)
		
		function plot(obj, varargin) % overriding from Model base class
            %plot Plots EVERYTHING
            %   PLOT(model) or model.PLOT will call all plot functions.
            %
            %   Optional input arguments
            %   [...] = model.PLOT(PARAM1,VAL1,PARAM2,VAL2,...) specifies one
            %   or more of the following name/value pairs:
            %
            %      'shouldExportPlots' Either true or false. Default is true. 
            
            close all
			
			% parse inputs
			p = inputParser;
			p.FunctionName = mfilename;
			p.addParameter('shouldExportPlots', true, @islogical);
			p.parse(varargin{:});
			
			obj.plotDiscountFunctionGrid();
			% Export
			if obj.plotOptions.shouldExportPlots
				myExport(obj.plotOptions.savePath,...
					'grid_discount_functions',...
					'suffix', obj.modelFilename,...
					'formats', obj.plotOptions.exportFormats);
			end
			
			obj.plotDiscountFunctionsOverlaid();
			% Export
			if obj.plotOptions.shouldExportPlots
				myExport(obj.plotOptions.savePath,...
					'discount_functions',...
					'suffix', obj.modelFilename,...
					'formats', obj.plotOptions.exportFormats);
			end
			
			% EXPERIMENT PLOT ==================================================
			obj.psychometric_plots();
			obj.plotAllExperimentFigures();
			
			% Posterior prediction plot
            dfPlotFunc = @(fh,n) obj.plotDiscountFunction(fh,n);
            obj.postPred.plot(obj.plotOptions, obj.modelFilename, dfPlotFunc)
			
			
			%% TODO...
			% FOREST PLOT OF AUC VALUES ========================================
			% TODO: Think about plotting this with GRAMM
			% https://github.com/piermorel/gramm
			%
			%figUnivariateSummary(alldata)
			
		end
		
		
		function plotExperimentOverviewFigure(obj, ind)
            %model.plotExperimentOverviewFigure(N) Creates a multi-panel figure
            %   model.plotExperimentOverviewFigure(N) creates a multi-panel figure
            %   corresponding to experiment N, where N is an integer.
            
			latex_fig(12, 14, 3)
			h = layout([1 2 3]);
			
			% opts.pointEstimateType	= obj.plotOptions.pointEstimateType;
			% opts.timeUnits			= obj.timeUnits;
			
			% create cell arrays of relevant variables
			discountFunctionVariables = {obj.varList.discountFunctionParams.name};
			responseErrorVariables    = {obj.varList.responseErrorParams.name};
			
            obj.plotPosteriorErrorParams(h(1), ind)
            
			%%  Set up psychometric function
			%psycho = PsychometricFunction('samples', obj.coda.getSamplesAtIndex_asStruct(ind,responseErrorVariables));
			% TODO: This doesn't do any plotting as it stands
			psycho = PsychometricFunction('samples', obj.coda.getSamplesAtIndex_asStochastic(ind,responseErrorVariables));
			
			
			%---- TEMP COMMENTED OUT WHILE I FIX THINGS ----
			%% Set up discount function
			%             discountFunction = obj.dfClass('samples', samples,...
			%                'data', obj.data.getExperimentObject(ind));
			%
			%             %% plot distribution of AUC
			%             subplot(h(2))
			%             discountFunction.AUC.plot();
			%             xlim([0 2])
			
			%% plot discount function
			obj.plotDiscountFunction(h(3), ind)
			
		end
		
	end
	
	methods (Access = protected)
		
		function psychometric_plots(obj)
			% TODO: plot data on these figures
			
			names = obj.data.getIDnames('all');
			for ind = 1:numel(names) % loop over files
				fh = figure('Name', ['participant: ' names{ind}]);
				latex_fig(12,10, 8)
				
				personStruct = getExperimentData(obj, ind);
				
				% work out a good subplot arrangement
				nSubplots = numel(personStruct.delays);
				subplot_handles = create_subplots(nSubplots, 'square');
				
				% plot a set of psychometric functions, one for each delay tested
				for d = 1:nSubplots
					subplot(subplot_handles(d))
					%% plot the psychometric function ~~~~~~~~~~~~~~~~~~~~~
					% build structure of Stochastic objects
					samples = obj.coda.getSamplesAtIndex_asStochastic(ind,{'alpha','epsilon'});
					samples.indifference = Stochastic('rstar');
					samples.indifference.addSamples(personStruct.dfSamples(:,d));
					
					psycho = DF_SLICE_PsychometricFunction('samples', samples);
					psycho.plot();
					%% plot response data TODO: move this to Data ~~~~~~~~~
					hold on
					AoverB = personStruct.data.A ./ personStruct.data.B;
					R = personStruct.data.R;
					% grab just for this delay
					getThese = personStruct.data.DB==personStruct.delays(d);
					AoverB = AoverB(getThese);
					R = R(getThese);
					plot(AoverB, R, 'k+')
					%% format
					title(['delay = ' num2str(personStruct.delays(d)) ])
				end
				drawnow
				if obj.plotOptions.shouldExportPlots
					myExport(obj.plotOptions.savePath,...
						'expt_psychometric',...
						'prefix', names{ind},...
						'suffix', obj.modelFilename,...
						'formats', obj.plotOptions.exportFormats );
				end
				close(fh)
			end
		end
		
	end
end
