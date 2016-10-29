classdef (Abstract) Hyperbolic1MagEffect < Model
	%Hyperbolic1MagEffect  Hyperbolic1MagEffect is a subclass of Model for examining the 1-parameter hyperbolic discounting function.

    properties (Access = private)
		getDiscountRate % function handle
	end

	methods (Access = public)

		function obj = Hyperbolic1MagEffect(data, varargin)
			obj = obj@Model(data, varargin{:});

            obj.dfClass = @DF_HyperbolicMagnitudeEffect;
            
            % Create variables
			obj.varList.participantLevel = {'m', 'c','alpha','epsilon'};
			obj.varList.monitored = {'m', 'c','alpha','epsilon', 'Rpostpred', 'P'};

            % %% Plotting stuff
			% obj.plotFuncs.clusterPlotFunc	= @plotMCclusters;

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
				subplot(1,5,1)
				mcmc.BivariateDistribution(...
					samples.epsilon(:),...
					samples.alpha(:),...
					'xLabel','error rate, $\epsilon$',...
					'ylabel','comparison accuity, $\alpha$',...
					'pointEstimateType',obj.pointEstimateType,...
					'plotStyle', 'hist',...
					'axisSquare', true);
				
				%% Plot the psychometric function
				subplot(1,5,2)
				psycho.plot()
				
				%% Set up magnitude effect function
				samples = obj.coda.getSamplesAtIndex(ind,{'m','c'});
				me = MagnitudeEffectFunction('samples', samples);

				%% plot (m,c) distribution
				subplot(1,5,3)
				% TODO: replace with new bivariate class
				mcmc.BivariateDistribution(...
					samples.m(:),...
					samples.c(:),...
					'xLabel','slope, $m$',...
					'ylabel','intercept, $c$',...
					'pointEstimateType',obj.pointEstimateType,...
					'plotStyle', 'hist',...
					'axisSquare', true);
				
				%% plot magnitude effect
				subplot(1,5,4)
				me.plot()
				
				%% Set up and plot discount surface
				samples = obj.coda.getSamplesAtIndex(ind,{'m','c'});
				discountFunction = DF_HyperbolicMagnitudeEffect('samples', samples );
				
				subplot(1,5,5)
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
