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
            obj.varList.discountFunctionParams(1).name = 'm';
            obj.varList.discountFunctionParams(1).label = 'slope, $m$';
            obj.varList.discountFunctionParams(2).name = 'c';
            obj.varList.discountFunctionParams(2).label = 'intercept, $c$';

			obj.dataPlotType = '3D';
		end

		% OVERRIDDING THIS METHOD FROM A SUPERCLASS
		function experimentMultiPanelFigure(obj, ind)
            % create cell array
            discountFunctionVariables = {obj.varList.discountFunctionParams.name};
            responseErrorVariables = {obj.varList.responseErrorParams.name};
            
			% a list of reward values we are interested in
			rewards = [10, 100, 500]; % <----  TODO: inject this

			%%  Set up psychometric function
			respErrSamples = obj.coda.getSamplesAtIndex(ind, responseErrorVariables);
			psycho = PsychometricFunction('samples', respErrSamples);

			%% plot bivariate distribution of alpha, epsilon ---------------
			subplot(1,6,1)
			% TODO: replace with new class
			mcmc.BivariateDistribution(...
				respErrSamples.epsilon(:),...
				respErrSamples.alpha(:),...
				'xLabel', obj.varList.responseErrorParams(1).label,...
				'ylabel', obj.varList.responseErrorParams(2).label,...
				'pointEstimateType',obj.pointEstimateType,...
				'plotStyle', 'hist',...
				'axisSquare', true);

			%% Plot the psychometric function ------------------------------
			subplot(1,6,2)
			psycho.plot(obj.pointEstimateType)

			%% Set up discount function
			dfSamples = obj.coda.getSamplesAtIndex(ind, discountFunctionVariables);

			discountFunction = obj.dfClass('samples', dfSamples);
            % inject a DataFile object into the discount function
            discountFunction.data = obj.data.getExperimentObject(ind);

			% TODO: this checking needs to be implemented in a
			% smoother, more robust way
			if ~isempty(dfSamples) || ~any(isnan(dfSamples))
				subplot(1,6,3) % -------------------------------------------
				discountFunction.plotParameters(obj.pointEstimateType)

				subplot(1,6,6) % -------------------------------------------
				discountFunction.plot(obj.pointEstimateType,...
					obj.dataPlotType,...
					obj.timeUnits)
			end

			
			%% Set up magnitude effect function -----------------------
			me = MagnitudeEffectFunction('samples', dfSamples);

			% plot magnitude effect
			subplot(1,6,4) % -----------------------------------------------
			me.plot()
			% Add horizontal lines to the
			hold on
			for n=1:numel(rewards)
				vline(rewards(n));
			end

			subplot(1,6,5) % -----------------------------------------------
			%title('P(log(k) | reward)')
			discountFunction.getLogDiscountRate(rewards, ind ,...
				'plot', true,...
				'plot_mode', 'conditional_only');

		end

	end


	methods (Abstract)
		initialiseChainValues
	end

end
