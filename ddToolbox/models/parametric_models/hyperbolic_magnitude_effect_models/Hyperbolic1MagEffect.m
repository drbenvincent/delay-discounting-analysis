classdef (Abstract) Hyperbolic1MagEffect < Parametric
	%Hyperbolic1MagEffect  Hyperbolic1MagEffect is a subclass of Model for examining the 1-parameter hyperbolic discounting function.
	
	properties (Access = private)
		getDiscountRate % function handle
	end
	
	methods (Access = public)
		
		function obj = Hyperbolic1MagEffect(data, varargin)
			obj = obj@Parametric(data, varargin{:});
			
			obj.dfClass = @DF_HyperbolicMagnitudeEffect;
			
			% Create variables
			obj.varList.participantLevel = {'m', 'c','alpha','epsilon'};
			obj.varList.monitored = {'m', 'c','alpha','epsilon', 'Rpostpred', 'P', 'VA', 'VB'};
			
			%% Plotting stuff
			obj.plotFuncs.clusterPlotFunc	= @plotMCclusters;
			
		end
		
		
		function experimentPlot(obj)
			
			names = obj.data.getIDnames('all');
			
			for ind = 1:numel(names)
				fh = figure('Name', ['participant: ' names{ind}]);
				latex_fig(12, 18, 3)
				
				cols = 6;
				
				%%  Set up psychometric function
				samples = obj.coda.getSamplesAtIndex(ind,{'alpha','epsilon'});
				psycho = PsychometricFunction('samples', samples);
				
				%% plot bivariate distribution of alpha, epsilon
				subplot(1,cols,1)
				mcmc.BivariateDistribution(...
					samples.epsilon(:),...
					samples.alpha(:),...
					'xLabel','error rate, $\epsilon$',...
					'ylabel','comparison accuity, $\alpha$',...
					'pointEstimateType',obj.pointEstimateType,...
					'plotStyle', 'hist',...
					'axisSquare', true);
				
				%% Plot the psychometric function
				subplot(1,cols,2)
				psycho.plot(obj.pointEstimateType)
				
				%% Set up magnitude effect function
				samples = obj.coda.getSamplesAtIndex(ind,{'m','c'});
				me = MagnitudeEffectFunction('samples', samples);
				
				
				%% plot (m,c) distribution
				subplot(1,cols,3)
				% TODO: replace with new bivariate class
				mcmc.BivariateDistribution(...
					samples.m(:),...
					samples.c(:),...
					'xLabel','slope, $m$',...
					'ylabel','intercept, $c$',...
					'pointEstimateType',obj.pointEstimateType,...
					'plotStyle', 'hist',...
					'axisSquare', true);
				
				%% Magnitude effect stuff
				% a list of reward values we are interested in
				rewards = [10, 100, 1000]; % <----  TODO: inject this
				
				%% plot magnitude effect
				subplot(1,cols,4)
				me.plot()
				
				% Add horizontal lines to the
				hold on
				for n=1:numel(rewards)
					vline(rewards(n));
				end
				
				%% TODO: Add P(log(k) | reward) here
				subplot(1,cols,5)
				%title('P(log(k) | reward)')
				obj.getLogDiscountRate([10, 100, 1000], ind ,...
					'plot', true,...
					'plot_mode', 'conditional_only');
				
				
				%% Set up and plot discount surface
				samples = obj.coda.getSamplesAtIndex(ind,{'m','c'});
				discountFunction = DF_HyperbolicMagnitudeEffect('samples', samples );
				% add data:  TODO: streamline this on object creation ~~~~~
				% NOTE: we don't have data for group-level
				data_struct = obj.data.getExperimentData(ind);
				data_object = DataFile(data_struct);
				discountFunction.data = data_object;
				% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				
				subplot(1,cols,6)
				dataPlotType = '3D';
				discountFunction.plot(obj.pointEstimateType,...
					dataPlotType,...
					obj.timeUnits)
				
				if obj.shouldExportPlots
					myExport(obj.savePath, 'expt',...
						'prefix', names{ind},...
						'suffix', obj.modelFilename,...
                        'formats', {'png'});
				end
				
				close(fh)
			end
		end
		
		
		
		
		
		
		
		% TODO: SHOULD THIS BE THE RESPONSIBILIY OF
		% DF_HyperbolicMagnitudeEffect ??
		
		function logk = getLogDiscountRate(obj, reward, index, varargin)
			% for models with magnitude effect, we might want to ask for
			% what the log(k) values are for given reward values
			p = inputParser;
			p.FunctionName = mfilename;
			p.addRequired('reward', @isnumeric);
			p.addRequired('index', @isscalar);
			p.addParameter('plot','true',@islogical)
			p.addParameter('plot_mode','row',...
				@(x)any(strcmp(x,{'row','compact','conditional_only'})))
			p.parse(reward, index, varargin{:});
			
			
			% create a magnitide effect object
			samples = obj.coda.getSamplesAtIndex(index,{'m','c'});
			magEffect = DF_HyperbolicMagnitudeEffect('samples', samples );
			
			% Create an array of Stochastic objects to pass back
			for n=1:numel(reward)
				logk(n) = Stochastic('logk');
				logk_samples = magEffect.eval(reward(n));
				logk(n).addSamples(logk_samples);
			end
			
			% Plot logic
			if p.Results.plot
				% create a vector of subplot handles
				switch p.Results.plot_mode
					case{'row'}
						figure
						latex_fig(16, 15, 4)
						N = numel(reward) + 1;
						subplot_handles = create_subplots(N, 'row');
						plot_mag_effect(subplot_handles(1))
						plot_condition_logk(subplot_handles([2:end]))
						
						% TODO: exporting
% 						if p.Results.shouldExport
% 							myExport(obj.savePath, 'expt',...
% 								'prefix', names{ind},...
% 								'suffix', obj.modelFilename);
% 						end
			
					case{'compact'}
						figure
						latex_fig(16, 8,4)
						N = 2;
						subplot_handles = create_subplots(N, 'row');
						subplot_handles([2:numel(reward)+1]) = subplot_handles(2);
						
						plot_mag_effect(subplot_handles(1))
						plot_condition_logk(subplot_handles([2:end]))
						% TODO: exporting
% 						if p.Results.shouldExport
% 							myExport(obj.savePath, 'expt',...
% 								'prefix', names{ind},...
% 								'suffix', obj.modelFilename);
% 						end
						
					case{'conditional_only'}
						% plot in current axis handle
						subplot_handles = [];
						for n=1:numel(reward)
							subplot_handles = [subplot_handles gca];
						end
						plot_condition_logk(subplot_handles)
				end

			end
			

				
			
			function plot_mag_effect(subplot_handle)
				% PLOT MAGNITUDE EFFECT -----------------------------------
				subplot(subplot_handle)
				% TODO: once DF_HyperbolicMagnitudeEffect owns a
				% MagnitudeEffectFunction object, then we can call it
				% directly?
				samples = obj.coda.getSamplesAtIndex(index,{'m','c'});
				me = MagnitudeEffectFunction('samples',samples);
				me.plot()
			end
			
			function plot_condition_logk(subplot_handles)
				% PROCESS REWARD VALUES REQUESTED -------------------------
				% Loop through rewards requested, plotting to the
				% appropriate subplot
				for n = 1:numel(reward)
					hold on
					% 					% plot vertical line on magnitude effect graph --------
					% 					subplot(subplot_handles(1))
					% 					vline(reward(n));
					
					% plot log(k) distribution ----------------------------
					subplot(subplot_handles(n))
					logk(n).plot();
					% TODO: fix equation... it's not showing properly
					switch p.Results.plot_mode
						case{'row'}
							title( sprintf('P(log(k) | reward = %d)',reward(n)) )
					end
				end
			end
		end
		
		
	end
	
	
	methods (Abstract)
		initialiseChainValues
	end
	
	
	
end
