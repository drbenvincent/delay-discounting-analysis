classdef ModelGaussianRandomWalkComplex < Model
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)
		% =================================================================
		function obj = ModelGaussianRandomWalkComplex(toolboxPath, samplerType, data, saveFolder, varargin)

            samplerType = lower(samplerType);
			modelType		= 'mixedGRWsimple';
			modelPath		= [toolboxPath '/models/' modelType '.' samplerType];

            obj = obj@Model(data, saveFolder, samplerType, modelPath, varargin{:});

			obj.discountFuncType = 'logk';
            
			% 'Decorate' the object with appropriate plot functions
			obj.plotFuncs.participantFigFunc = @figParticipantLOGK;
			obj.plotFuncs.plotGroupLevel = @plotGroupLevelStuff;

			%% Create variables
			obj.varList.participantLevel = {'discountFraction','epsilon'};
      obj.varList.participantLevelPriors = {'epsilon_group_prior'};
			obj.varList.groupLevel = {'epsilon_group'};

			obj.varList.monitored = {'discountFraction','epsilon',...
				'epsilon_group',...
				'epsilon_group_prior',...
				'groupW','groupK',...
				'groupW_prior','groupK_prior',...
				'Rpostpred', 'P'};
		end
		% =================================================================

		function conditionalDiscountRates(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end

		function conditionalDiscountRates_GroupLevel(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end





		function plot(obj) % overriding from Model base class

			clf
			% plot the GAUSSIAN RANDOM WALK STUFF
			for p=1:obj.data.nParticipants

				dfSamples = squeeze(obj.mcmc.samples.discountFraction(:,:,p,:));

				dfSamples = reshape(dfSamples,...
					[size(dfSamples,1)*size(dfSamples,2), size(dfSamples,3)])';

				subplot(1,obj.data.nParticipants,p)


				%plot(obj.data.observedData.uniqueDelays, dfSamples(:,[1:1000]))

				ribbon_plot(obj.data.observedData.uniqueDelays, dfSamples)

				hold on
				data = obj.data.getParticipantData(p);
				plotDiscountingData(data)

				%title(['participant: ' num2str(p)])
				title(obj.data.IDname{p})
				%hline(1)
				%set(gca,'XScale','log')


				xlabel('delay')
				%axis square
				axis tight
				drawnow
			end

			beep

		end




	end

end
