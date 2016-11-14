classdef (Abstract) Hyperbolic1 < Parametric
	%Hyperbolic1  Hyperbolic1 is a subclass of Model for examining the 1-parameter hyperbolic discounting function.
	
	properties (Access = private)
		getDiscountRate % function handle
	end
	
	methods (Access = public)
		
		function obj = Hyperbolic1(data, varargin)
			obj = obj@Parametric(data, varargin{:});
			
			obj.dfClass = @DF_Hyperbolic1;
			
			% Create variables
			obj.varList.participantLevel = {'logk','alpha','epsilon'};
			obj.varList.monitored = {'logk','alpha','epsilon', 'Rpostpred', 'P', 'VA', 'VB'};
			
			%% Plotting
			obj.plotFuncs.clusterPlotFunc	= @plotLOGKclusters;
			
		end
		
		function conditionalDiscountRates(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end
		
		function conditionalDiscountRates_GroupLevel(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end
		
		
		
		
		function experimentPlot(obj)
			
			names = obj.data.getIDnames('all');
			
			for ind = 1:numel(names)
				fh = figure('Name', ['participant: ' names{ind}]);
				latex_fig(12, 10, 3)

				%%  Set up psychometric function
				samples = obj.coda.getSamplesAtIndex(ind,{'alpha','epsilon'});
				psycho = PsychometricFunction('samples', samples);
				
				%% plot bivariate distribution of alpha, epsilon
				subplot(1,4,1)
				
				% TODO: replace with new class
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
				psycho.plot()
				
				%% Set up log k discount function
				samples = obj.coda.getSamplesAtIndex(ind,{'logk'});
				discountFunction = DF_Hyperbolic1('samples', samples);
				% add data:  TODO: streamline this on object creation ~~~~~
				% NOTE: we don't have data for group-level
				data_struct = obj.data.getExperimentData(ind);
				data_object = DataFile(data_struct);
				discountFunction.data = data_object;
				% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				
				%% plot log(k) distribution
				subplot(1,4,3)
				discountFunction.plotParameters()
				
				%% plot discount function
				subplot(1,4,4)
				discountFunction.plot()
				
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
