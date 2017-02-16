classdef (Abstract) NonParametric < Model
	%NonParametric  NonParametric is a subclass of Model for examining models that do NOT make parametric assumptions about the discount function.

    properties (Access = private)
        AUC_DATA
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

    
    methods (Access = protected)

        function obj = calcDerivedMeasures(obj)
        end

    end
    
    
    
    methods (Access = public)

		function plot(obj, varargin) % overriding from Model base class
			close all
			
			% parse inputs
			p = inputParser;
			p.FunctionName = mfilename;
			p.addParameter('shouldExportPlots', true, @islogical);
			p.parse(varargin{:});

			obj.plot_discount_functions_in_grid();
            % Export
            if obj.plotOptions.shouldExportPlots
                myExport(obj.plotOptions.savePath,...
                    'grid_discount_functions',...
                    'suffix', obj.modelFilename,...
                    'formats', obj.plotOptions.exportFormats);
            end
			
			% EXPERIMENT PLOT ==================================================
            obj.psychometric_plots();
			obj.plotAllExperimentFigures();
			
            % Posterior prediction plot
            obj.postPred.plot(obj.plotOptions, obj.modelFilename)
			

			%% TODO...
            % FOREST PLOT OF AUC VALUES ========================================
            % TODO: Think about plotting this with GRAMM
            % https://github.com/piermorel/gramm
            %
            %figUnivariateSummary(alldata)
			
		end
        
        
        function experimentMultiPanelFigure(obj, ind)
            
            latex_fig(12, 14, 3)
            h = layout([1 2 3 3]);
            
            opts.pointEstimateType	= obj.plotOptions.pointEstimateType;
            opts.timeUnits			= obj.timeUnits;
            
            responseErrorVariables    = {obj.varList.responseErrorParams.name};
            
            %%  Set up psychometric function
            psycho = PsychometricFunction('samples', obj.coda.getSamplesAtIndex_asStruct(ind,responseErrorVariables));
                
            %% PLOT: density plot of (alpha, epsilon)
            obj.coda.plot_bivariate_distribution(h(1),...
                responseErrorVariables(1),...
                responseErrorVariables(2),...
                ind,...
                opts)
                
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
            
		end
		
		
		function plot_discount_functions_in_grid(obj)
			latex_fig(12, 11,11)
			
			% TODO: extract the grid formatting stuff to be able to call
			% any plot function we want
			% USE: apply_plot_function_to_subplot_handle.m ??
			
			%fh = figure('Name', names{experimentIndex});
			names = obj.data.getIDnames('all');
			
			clf, drawnow
			
			% create grid layout
			N = numel(names);
			subplot_handles = create_subplots(N, 'square');
			
			% Iterate over files, plotting
			disp('Plotting...')
			for n = 1:numel(names)
				plot_df(n, subplot_handles(n))
			end
			drawnow
			
			function plot_df(ind, subplot_handle)
                subplot(subplot_handle)
				% Set up discount function
				personInfo = obj.getExperimentData(ind);
				discountFunction = DF_NonParametric('delays',personInfo.delays,...
					'theta', personInfo.dfSamples);
				discountFunction.data = obj.data.getExperimentObject(ind);
				
				discountFunction.plot();
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

		
        % TODO: do this by injecting new AUC values into CODA?
        % TODO: do it for Parametric models as well
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
                    samples = obj.coda.getSamplesAtIndex_asStruct(ind,{'alpha','epsilon'});
                    samples.indifference  = personStruct.dfSamples(:,d);
                    psycho = DF_SLICE_PsychometricFunction('samples', samples);
                    psycho.plot();
                    %% plot response data TODO: move this to Data ~~~~~~~~~
                    hold on
                    %pTable = obj.data.getRawDataTableForParticipant(ind);
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
    

end
