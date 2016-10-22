classdef ModelHierarchicalME_MVNORM < Model
	%ModelHierarchicalME A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties (Access = private)
		getDiscountRate
	end

	methods (Access = public)

		function obj = ModelHierarchicalME_MVNORM(data, varargin)
			obj = obj@Model(data, varargin{:});

			obj.modelFilename			= 'hierarchicalMEmvnorm';
			obj.discountFuncType	= 'hyperbolic1_magnitude_effect';
			obj.getDiscountRate = @getLogDiscountRate; % <-------------------------------------- FINISH

			% Create variables
			obj.varList.participantLevel = {'m','c', 'r', 'alpha','epsilon'};
			obj.varList.monitored = {'r', 'm', 'c', 'mc_mu', 'mc_sigma','alpha','epsilon',  'Rpostpred', 'P'};

			warning('ModelHierarchicalME_MVNORM not working with unobserved participant')
			%obj = obj.addUnobservedParticipant('GROUP');

			%% Plotting
			obj.experimentFigPlotFuncs{1} = @(plotdata) mcmc.BivariateDistribution(plotdata.samples.posterior.epsilon(:), plotdata.samples.posterior.alpha(:),...
				'xLabel','error rate, $\epsilon$',...
				'ylabel','comparison accuity, $\alpha$',...
				'pointEstimateType',plotdata.pointEstimateType,...
				'plotStyle', 'hist');

			obj.experimentFigPlotFuncs{2} = @(plotdata) plotPsychometricFunc(plotdata.samples, plotdata.pointEstimateType);

% 			obj.experimentFigPlotFuncs{3} = @(plotdata) mcmc.UnivariateDistribution(plotdata.samples.posterior.r(:),...
% 				'xLabel', 'r');

			obj.experimentFigPlotFuncs{3} = @(plotdata) mcmc.BivariateDistribution(plotdata.samples.posterior.m(:), plotdata.samples.posterior.c(:),...
				'xLabel','slope, $m$',...
				'ylabel','intercept, $c$',...
				'pointEstimateType',plotdata.pointEstimateType,...
				'plotStyle', 'hist');

			obj.experimentFigPlotFuncs{4} = @(plotdata) plotMagnitudeEffect(plotdata.samples, plotdata.pointEstimateType);

			obj.experimentFigPlotFuncs{5} = @(plotdata) plotDiscountSurface(plotdata);

			% Decorate the object with appropriate plot functions
			obj.plotFuncs.clusterPlotFunc = @plotMCclusters;

			% MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
			obj = obj.conductInference();
		end


		%% ******** SORT OUT WHERE THESE AND OTHER FUNCTIONS SHOULD BE *************
		function obj = conditionalDiscountRates(obj, reward, plotFlag)
			% For group level and all participants, extract and plot P( log(k) | reward)
			warning('THIS METHOD IS A TOTAL MESS - PLAN THIS AGAIN FROM SCRATCH')
			obj.conditionalDiscountRates_ParticipantLevel(reward, plotFlag)
			obj.conditionalDiscountRates_GroupLevel(reward, plotFlag)
			if plotFlag % FORMATTING OF FIGURE
				mcmc.removeYaxis()
				title(sprintf('$P(\\log(k)|$reward=$\\pounds$%d$)$', reward),'Interpreter','latex')
				xlabel('$\log(k)$','Interpreter','latex')
				axis square
				%legend(lh.DisplayName)
			end
		end

		function conditionalDiscountRates_GroupLevel(obj, reward, plotFlag)
			GROUP = obj.data.nExperimentFiles; % last participant is our unobserved
			params = obj.mcmc.getSamplesFromExperimentAsMatrix(GROUP, {'m','c'});
			[posteriorMean, lh] = calculateLogK_ConditionOnReward(reward, params, plotFlag);
			lh.LineWidth = 3;
			lh.Color= 'k';
		end

	end
	

	methods (Static)
		function initialParams = setInitialParamValues(nchains)
			% Generate initial values of the root nodes
			for chain = 1:nchains
				%obj.initialParams(chain).r				= -0.2 + randn/10;
				%obj.initialParams(chain).mc_mu			= [(rand-0.5)*2 randn*5];
				initialParams(chain).groupW			= rand;
				initialParams(chain).groupALPHAmu	= rand*10;
				initialParams(chain).groupALPHAsigma= rand*10;
			end
		end
	end

end
