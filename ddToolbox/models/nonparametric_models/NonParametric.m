classdef (Abstract) NonParametric < Model
	%NonParametric  NonParametric is a subclass of Model for examining models that do NOT make parametric assumptions about the discount function.

    properties (Access = private)
        AUC_DATA
		getDiscountRate % function handle
	end

	methods (Access = public)

		function obj = NonParametric(data, varargin)
			obj = obj@Model(data, varargin{:});
			obj.dfClass = @DF_NonParametric;
            % Create variables
			obj.varList.participantLevel = {'Rstar'};
			obj.varList.monitored = {'Rstar', 'alpha', 'epsilon', 'Rpostpred', 'P'};
		end

	end

	
	methods (Abstract)
		initialiseChainValues
    end
    
    methods (Access = protected)

        
        function obj = calcDerivedMeasures(obj)
        end

    end
    
    
    
    methods (Access = public)

		function plot(obj, varargin) % overriding from Model base class
			% parse inputs
			p = inputParser;
			p.FunctionName = mfilename;
			p.addParameter('shouldExportPlots', true, @islogical);
			p.parse(varargin{:});

            obj.pdata = obj.packageUpDataForPlotting();

			obj.shouldExportPlots = p.Results.shouldExportPlots;
			for n=1:numel(obj.pdata)
				obj.pdata(n).shouldExportPlots = p.Results.shouldExportPlots;
			end

			close all

			% EXPERIMENT PLOT ==================================================
            obj.psychometric_plots();
			obj.experimentPlot();
			
            % POSTERIOR PREDICTION PLOTS =======================================
			% temporarily commented: not needed while testing
			%arrayfun(@figPosteriorPrediction, obj.pdata); % posterior prediction plot
			
			
			
			
			%% TODO...
            % FOREST PLOT OF AUC VALUES ========================================
            % TODO: Think about plotting this with GRAMM
            % https://github.com/piermorel/gramm
            %
            %figUnivariateSummary(alldata)
			
		end
        
        
        function experimentPlot(obj)
            
            names = obj.data.getIDnames('all');
            h = layout([1 2 3 3]);
            
            for ind = 1:numel(names)
                fh = figure('Name', ['participant: ' names{ind}]);
                latex_fig(12, 10, 3)

                %%  Set up psychometric function
                psycho = PsychometricFunction('samples', obj.coda.getSamplesAtIndex_asStruct(ind,{'alpha','epsilon'}));
                
                %% plot bivariate distribution of alpha, epsilon
                subplot(h(1))
                samples = obj.coda.getSamplesAtIndex_asStruct(ind,{'alpha','epsilon'});
                mcmc.BivariateDistribution(...
                    samples.epsilon(:),...
                    samples.alpha(:),...
                    'xLabel','error rate, $\epsilon$',...
                    'ylabel','comparison accuity, $\alpha$',...
                    'pointEstimateType',obj.pointEstimateType,...
                    'plotStyle', 'hist',...
                    'axisSquare', true);
                
%                 %% Plot the psychometric function
%                 subplot(1,4,2)
%                 psycho.plot(obj.pointEstimateType)
                
                                
                %% Set up discount function
				personInfo = obj.getExperimentData(ind);
                discountFunction = DF_NonParametric('delays',personInfo.delays,...
                    'theta', personInfo.dfSamples);
                % inject a DataFile object into the discount function
                discountFunction.data = obj.data.getExperimentObject(ind);
				
                %% plot distribution of AUC
                subplot(h(2))
                discountFunction.AUC.plot();
				xlim([0 2])
                
                %% plot discount function
                subplot(h(3))
                discountFunction.plot();
                
                drawnow
                if obj.shouldExportPlots
                    myExport(obj.plotOptions.savePath, 'expt',...
                        'prefix', names{ind},...
                        'suffix', obj.modelFilename,...
                        'formats', obj.plotOptions.exportFormats);
                end
                
                close(fh)
            end
		end
		
		function psychometric_plots(obj)
            % TODO: plot data on these figures
            
			names = obj.data.getIDnames('all');
			for ind = 1:numel(names) % loop over files
				fh = figure('Name', ['participant: ' names{ind}]);
                latex_fig(12, 6, 6)
				
				personStruct = getExperimentData(obj, ind);
				
				% work out a good subplot arrangement
				nSubplots = numel(personStruct.delays);
				subplot_handles = create_subplots(nSubplots, 'square');
				
				for d = 1:nSubplots
					
					subplot(subplot_handles(d))
					%subplot(1, numel(personStruct.delays), d)
					
					% plot a set of psychometric functions, one for each delay
					% tested
					
					%
					samples = obj.coda.getSamplesAtIndex_asStruct(ind,{'alpha','epsilon'});
					samples.indifference  = personStruct.dfSamples(:,d);
					psycho = DF_SLICE_PsychometricFunction('samples', samples);
					psycho.plot();
					title(['delay = ' num2str(personStruct.delays(d)) ])
				end
				if obj.shouldExportPlots
					myExport(obj.plotOptions.savePath, 'expt_psychometric',...
						'prefix', names{ind},...
						'suffix', obj.modelFilename,...
                        'formats', obj.plotOptions.exportFormats );
				end
				close(fh)
			end
		end
		
        
        
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

		
		function [auc] = getAUC(obj)
			% return AUC measurements. 
			% This will return an object array of stocastic objects
			names = obj.data.getIDnames('all');

			for ind = 1:numel(names)
				personInfo = obj.getExperimentData(ind);
				discountFunction = DF_NonParametric('delays',personInfo.delays,...
					'theta', personInfo.dfSamples);
				
				% append to object array
				auc(ind) = discountFunction.AUC;
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
    

end
