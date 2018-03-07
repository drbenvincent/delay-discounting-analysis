classdef (Abstract) Hyperbolic1MagEffect < Parametric
	%Hyperbolic1MagEffect  Hyperbolic1MagEffect is a subclass of Model for examining the 1-parameter hyperbolic discounting function.

	methods (Access = public)

		function obj = Hyperbolic1MagEffect(data, varargin)
			obj = obj@Parametric(data, varargin{:});

			obj.dfClass = @DF_HyperbolicMagnitudeEffect;

			% Create variables
			obj.varList.participantLevel = {'m', 'c','alpha','epsilon'};
			obj.varList.monitored = {'log_lik', 'm', 'c','alpha','epsilon', 'Rpostpred', 'P', 'VA', 'VB'};
			obj.varList.discountFunctionParams(1).name = 'm';
			obj.varList.discountFunctionParams(1).label = 'slope, $m$';
			obj.varList.discountFunctionParams(2).name = 'c';
			obj.varList.discountFunctionParams(2).label = 'intercept, $c$';

			obj.plotOptions.dataPlotType = '3D';
		end

    end

    methods (Access = private)

        % MIDDLE-MAN METHOD
        function logk = getLogDiscountRate(obj, reward, index, varargin)
            %% Set up discount function
            discountFunctionVariables = {obj.varList.discountFunctionParams.name};
            dfSamples = obj.coda.getSamplesAtIndex_asStruct(index, discountFunctionVariables);
            discountFunction = obj.dfClass('samples', dfSamples);
            %             % inject a DataFile object into the discount function
            %             discountFunction.data = obj.data.getExperimentObject(index);

            %% Do the actual call
            logk = discountFunction.getLogDiscountRate(reward, index, varargin{:});
        end

    end

    methods (Hidden = true)
        function dispModelInfo(obj)
            % TODO: Display the discount function
            %display('Discount function: V = reward * exp(-k*(delay^tau))')
        end
    end


    % ==========================================================================
    % ==========================================================================
    % PLOTTING
    % ==========================================================================
    % ==========================================================================

	methods (Access = public)

		% OVERRIDDING THIS METHOD FROM A SUPERCLASS
		function plotExperimentOverviewFigure(obj, ind)
            %model.plotExperimentOverviewFigure(N) Creates a multi-panel figure
            %   model.plotExperimentOverviewFigure(N) creates a multi-panel figure
            %   corresponding to experiment N, where N is an integer.

			latex_fig(12, 14, 3);
			h = layout([1 2 3 4 5 6]);
			opts.pointEstimateType = obj.plotOptions.pointEstimateType;

            % % create cell array
			% discountFunctionVariables = {obj.varList.discountFunctionParams.name};
			% responseErrorVariables = {obj.varList.responseErrorParams.name};


			% %% Plot 1: density plot of (alpha, epsilon)
			% obj.coda.plot_bivariate_distribution(h(1),...
			% 	responseErrorVariables(1),...
			% 	responseErrorVariables(2),...
			% 	ind,...
			% 	opts);
			obj.plotPosteriorErrorParams(ind, 'axisHandle', h(1))

			% % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			% % TODO #166 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			% %%  Set up psychometric function
			% respErrSamples = obj.coda.getSamplesAtIndex_asStochastic(ind, responseErrorVariables);
			% psycho = PsychometricFunction('samples', respErrSamples);
			% %% Plot the psychometric function ------------------------------
			% subplot(h(2))
			% psycho.plot(obj.plotOptions.pointEstimateType);
			% %% Set up discount function
			% dfSamples = obj.coda.getSamplesAtIndex_asStochastic(ind, discountFunctionVariables);
			% discountFunction = obj.dfClass('samples', dfSamples);
			% % inject a DataFile object into the discount function
			% discountFunction.data = obj.data.getExperimentObject(ind);
			% % TODO #166 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			% % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            obj.plotPsychometricFunction(ind, 'axisHandle', h(2))


			% % TODO: this checking needs to be implemented in a smoother, more robust way
			% if ~isempty(dfSamples) || ~any(isnan(dfSamples))
			% 	%% Bivariate density plot of discounting parameters
			% 	obj.coda.plot_bivariate_distribution(h(3),...
			% 		discountFunctionVariables(1),...
			% 		discountFunctionVariables(2),...
			% 		ind,...
			% 		opts);
			% end
			obj.plotPosteriorDiscountFunctionParams(ind, 'axisHandle', h(3))


			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			% TODO #166 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

            % a list of reward values we are interested in
            rewards = [10, 100, 500]; % <----  TODO: inject this
            % create colours for colour coding of conditional k plotStyle
            col = linspace(0.1, 0.9, numel(rewards));

			%% Set up magnitude effect function -----------------------
			discountFunctionVariables = obj.getDiscountFunctionVariables();
			dfSamples = obj.coda.getSamplesAtIndex_asStochastic(ind, discountFunctionVariables);

			me = MagnitudeEffectFunction('samples', dfSamples);
			me.maxRewardValue = obj.data.getMaxRewardValue(ind);
			% plot magnitude effect
			subplot(h(4)) % -----------------------------------------------
			me.plot();
			% Add horizontal lines to the
			hold on
			for n=1:numel(rewards)
				vline(rewards(n), 'Color', [col(n) col(n) col(n)], 'LineWidth', 2);
			end


			subplot(h(5)) % -----------------------------------------------
			%title('P(log(k) | reward)')
			discountFunction = obj.dfClass('samples', dfSamples);

			discountFunction.getLogDiscountRate(rewards, ind ,...
				'plot', true,...
				'plot_mode', 'conditional_only');

			% TODO: this checking needs to be implemented in a
			% smoother, more robust way
			if ~isempty(dfSamples) || ~any(isnan(dfSamples))
				subplot(h(6)) % -------------------------------------------

				plotOptions.pointEstimateType = obj.plotOptions.pointEstimateType;
				plotOptions.dataPlotType = obj.plotOptions.dataPlotType;
				plotOptions.timeUnits = obj.timeUnits;
				%plotOptions.plotMode = p.Results.plot_mode;
				plotOptions.maxRewardValue = obj.data.getMaxRewardValue(ind);
				plotOptions.maxDelayValue = obj.data.getMaxDelayValue(ind);

				discountFunction.plot(plotOptions);
			end
			% TODO #166 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


		end

	end

end
