classdef ModelHierarchicalME < Model
	%ModelHierarchicalME A model to estimate the magnitide effect
	%   Detailed explanation goes here
	
	properties (Access = public) % TODO: set access not public
		getLogDiscountRate % function handle
	end
	
	methods (Access = public)
		
		function obj = ModelHierarchicalME(data, varargin)
			obj = obj@Model(data, varargin{:});
			
			obj.modelType			= 'hierarchicalME';
			obj.discountFuncType	= 'me';
			
			obj.getLogDiscountRate = @(reward) getLogDiscountRate(obj, reward); % <-------------------------------------- FINISH
			
			% Create variables
			obj.varList.participantLevel = {'m', 'c', 'alpha', 'epsilon'};
			obj.varList.monitored = {'m', 'c', 'alpha', 'epsilon', 'Rpostpred', 'P', 'm_prior'};
			
			obj = obj.addUnobservedParticipant('GROUP');
			
			%% Plotting stuff
			obj.experimentFigPlotFuncs		= make_experimentFigPlotFuncs_ME();
			obj.plotFuncs.clusterPlotFunc	= @plotMCclusters;
			
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
			% Generate initial values of the leaf nodes
			for chain = 1:nchains
				initialParams(chain).groupMmu		= normrnd(-0.243,10);
				initialParams(chain).groupMsigma	= rand*10;
				initialParams(chain).groupCmu		= normrnd(0,30);
				initialParams(chain).groupCsigma	= rand*10;
				initialParams(chain).groupW			= rand;
				initialParams(chain).groupALPHAmu	= rand*10;
				initialParams(chain).groupALPHAsigma= rand*10;
			end
		end
		
	end
	
end
