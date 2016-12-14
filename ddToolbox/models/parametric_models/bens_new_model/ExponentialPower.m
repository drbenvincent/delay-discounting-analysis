classdef (Abstract) ExponentialPower < Parametric

	properties (Access = private)
		getDiscountRate % function handle
	end

	methods (Access = public)

		function obj = ExponentialPower(data, varargin)
			obj = obj@Parametric(data, varargin{:});
            
            obj.dfClass = @DF_ExponentialPower; % TODO: THIS IS NOT ACTUALLY USED?

			% Create variables
			obj.varList.participantLevel = {'k','tau','alpha','epsilon'};
			obj.varList.monitored = {'k','tau','alpha','epsilon', 'Rpostpred', 'P', 'VA', 'VB'};
            obj.varList.discountFunctionParams(1).name = 'k';
            obj.varList.discountFunctionParams(1).label = 'discount rate, $k$';
            obj.varList.discountFunctionParams(2).name = 'tau';
            obj.varList.discountFunctionParams(2).label = 'tau';
            
			
			% %% Plotting
			% % TODO: Does this need to be made into a partial function?
			% obj.plotFuncs.clusterPlotFunc	= @() plot2Dclusters(...
			% 	obj.coda,...
			% 	obj.data,...
			% 	[1 0 0],...
			% 	obj.modelFilename,...
			% 	obj.plotOptions,...
			% 	{'k','tau'});

		end

		function conditionalDiscountRates(obj, reward, plotFlag)
			error('Not applicable to this model')
		end

		function conditionalDiscountRates_GroupLevel(obj, reward, plotFlag)
			error('Not applicable to this model')
		end
        
		function experimentPlot(obj)
			
            % create cell array
            discountFunctionVariables = {obj.varList.discountFunctionParams.name};
            
			names = obj.data.getIDnames('all');
			
			for ind = 1:numel(names)
				fh = figure('Name', ['participant: ' names{ind}]);
				latex_fig(12, 10, 3)

				%%  Set up psychometric function
				psycho = PsychometricFunction('samples', obj.coda.getSamplesAtIndex(ind,{'alpha','epsilon'}));
				
				%% plot bivariate distribution of alpha, epsilon
				subplot(1,4,1)
				samples = obj.coda.getSamplesAtIndex(ind,{'alpha','epsilon'});
				mcmc.BivariateDistribution(...
					samples.epsilon(:),...
					samples.alpha(:),...
					'xLabel','error rate, $\epsilon$',...
					'ylabel','comparison accuity, $\alpha$',...
					'pointEstimateType',obj.pointEstimateType,...
					'plotStyle', 'hist',...
					'axisSquare', true);
				
				%% Plot the psychometric function
				subplot(1,4,2)
				psycho.plot(obj.pointEstimateType)
				
				%% Set up discount function
				ksamples = obj.coda.getSamplesAtIndex(ind, discountFunctionVariables);  % <-------------- inject discount function params
				% don't plot if we don't have any samples. This is expected
				% to happen if we are currently looking at the group-level
				% unobserved participant and we are analysing a model
				% without group level inferences (ie the mixed or separate
				% models)
				discountFunction = DF_ExponentialPower('samples', ksamples ); % <-------------- inject this function name
				% add data:  TODO: streamline this on object creation ~~~~~
				% NOTE: we don't have data for group-level
				data_struct = obj.data.getExperimentData(ind);
				data_object = DataFile(data_struct);
				discountFunction.data = data_object;
				% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				
				% TODO: this checking needs to be implemented in a
				% smoother, more robust way
				if ~isempty(ksamples) || ~any(isnan(ksamples))
					%% plot distribution of (k, tau)
					subplot(1,4,3)
					%discountFunction.plotParameters()
                    samples = obj.coda.getSamplesAtIndex(ind, discountFunctionVariables);  
    				mcmc.BivariateDistribution(...
    					samples.(discountFunctionVariables{1})(:),...
    					samples.(discountFunctionVariables{2})(:),... 
    					'xLabel',obj.varList.discountFunctionParams(1).label,... 
    					'ylabel',obj.varList.discountFunctionParams(2).label,...
    					'pointEstimateType',obj.pointEstimateType,...
    					'plotStyle', 'hist',...
    					'axisSquare', true);
                        
					%% plot discount function
					subplot(1,4,4)
					dataPlotType = '2D';
					discountFunction.plot(obj.pointEstimateType,...
						dataPlotType,...
						obj.timeUnits)
				end
				
				
				if obj.shouldExportPlots
					myExport(obj.savePath, 'expt',...
						'prefix', names{ind},...
						'suffix', obj.modelFilename,...
                        'formats', {'png'});
				end
				
				close(fh)
			end
		end
		
	end

	
	methods (Abstract)
		initialiseChainValues
    end

end
