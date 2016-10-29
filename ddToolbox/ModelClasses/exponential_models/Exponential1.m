classdef (Abstract) Exponential1 < Model
	%Exponential1  This is a subclass of Model for examining the 1-parameter exponential discounting function.

	properties (Access = private)
		getDiscountRate % function handle
	end

	methods (Access = public)

		function obj = Exponential1(data, varargin)
			obj = obj@Model(data, varargin{:});
            
            obj.dfClass = @DF_Exponential1;

			% Create variables
			obj.varList.participantLevel = {'k','alpha','epsilon'};
			obj.varList.monitored = {'k','alpha','epsilon', 'Rpostpred', 'P'};

			% %% Plotting
			% obj.plotFuncs.clusterPlotFunc	= @plotExpclusters;

		end

		function conditionalDiscountRates(obj, reward, plotFlag)
			error('Not applicable to this model')
		end

		function conditionalDiscountRates_GroupLevel(obj, reward, plotFlag)
			error('Not applicable to this model')
		end
        
		function experimentPlot(obj)
			
			names = obj.data.getIDnames('all');
			
			for ind = 1:numel(names)
				fh = figure('Name', ['participant: ' names{ind}]);
				latex_fig(12, 10, 3)

				%%  Set up psychometric function
				
				% TODO: easier object construction by passing in structure of
				% params
				psycho = PsychometricFunction();
				samples = obj.coda.getSamplesAtIndex(ind,{'alpha','epsilon'});
				psycho.addSamples('alpha', samples.alpha )
				psycho.addSamples('epsilon', samples.epsilon )
				
				%% plot bivariate distribution of alpha, epsilon
				subplot(1,4,1)
				
				%% Plot the psychometric function
				subplot(1,4,2)
				psycho.plot()
				
				%% Set up discount function
				discountFunction = DF_Exponential1();
				samples = obj.coda.getSamplesAtIndex(ind,{'k'});
				discountFunction.addSamples('k', samples.k )
				
				%% plot distribution of k
				subplot(1,4,3)
				discountFunction.plotParameters()
				
				%% plot discount function
				subplot(1,4,4)
				discountFunction.plot()
				
				
				if obj.shouldExportPlots
					myExport(obj.savePath, 'expt',...
						'prefix', names{ind},...
						'suffix', obj.modelFilename);
				end
				
				close(fh)
			end
		end
		
	end

	
	methods (Abstract)
		initialiseChainValues
    end

end
