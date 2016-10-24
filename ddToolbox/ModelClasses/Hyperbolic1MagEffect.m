classdef (Abstract) Hyperbolic1MagEffect < Model
	%Hyperbolic1MagEffect  Hyperbolic1MagEffect is a subclass of Model for examining the 1-parameter hyperbolic discounting function.

    properties (Access = private)
		getDiscountRate % function handle
	end

	methods (Access = public)

		function obj = Hyperbolic1MagEffect(data, varargin)
			obj = obj@Model(data, varargin{:});

			obj.discountFuncType = 'me';
			obj.getDiscountRate = @getLogDiscountRate; % <-------------------------------------- FINISH

            % Create variables
			obj.varList.participantLevel = {'m', 'c','alpha','epsilon'};
			obj.varList.monitored = {'m', 'c','alpha','epsilon', 'Rpostpred', 'P'};
			% obj = obj.addUnobservedParticipant('GROUP');

            %% Plotting stuff
			obj.experimentFigPlotFuncs		= make_experimentFigPlotFuncs_ME();
			obj.plotFuncs.clusterPlotFunc	= @plotMCclusters;

		end

        %% TODO ******** CHECK THESE WORK ACROSS HIERARCHICAL / MIXED / SEPARATE MODELS *************
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
            GROUP = obj.data.getNExperimentFiles(); % last participant is our unobserved
            params = obj.mcmc.getSamplesFromExperimentAsMatrix(GROUP, {'m','c'});
            [posteriorMean, lh] = calculateLogK_ConditionOnReward(reward, params, plotFlag);
            lh.LineWidth = 3;
            lh.Color= 'k';
        end

	end

	
	methods (Abstract)
		initialiseChainValues
    end

end
