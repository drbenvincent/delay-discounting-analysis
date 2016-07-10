%KIRBY DATA IS NOT APPROPRIATE FOR THIS MODEL
% We need experimental paradigms that try to pinpoint the indifference
% point for a set number of delays.

classdef ModelGaussianRandomWalkSimple < Model
	%ModelGaussianRandomWalkSimple

	properties
		AUC_DATA
	end


	methods (Access = public)

    		function obj = ModelGaussianRandomWalkSimple(samplerType, data, saveFolder, varargin)

            samplerType = lower(samplerType);
			modelType		= 'mixedGRWsimple';
			modelPath = makeProbModelsPath(modelType, samplerType);

            obj = obj@Model(data, saveFolder, samplerType, modelPath, varargin{:});

			obj.discountFuncType = 'nonparametric';

			% 'Decorate' the object with appropriate plot functions
			obj.plotFuncs.participantFigFunc = @figParticipantLOGK;
			obj.plotFuncs.plotGroupLevel = @plotGroupLevelStuff;

			% TODO: remove varList as a property of Model base class.
 			obj.varList.monitored = {'discountFraction',...
				'alpha','epsilon', 'varInc',...
				'alpha_prior', 'epsilon_prior', 'varInc_prior',...
                'Rpostpred', 'P'};

		end

		% Generate initial values of the leaf nodes
		function setInitialParamValues(obj)

			%nTrials = size(obj.data.observedData.A,2);
			nParticipants = obj.data.nParticipants;
			nUniqueDelays = numel(obj.data.observedData.uniqueDelays);

			for chain = 1:obj.sampler.mcmcparams.nchains
				obj.initialParams(chain).discountFraction = normrnd(1, 0.1, [nParticipants,nUniqueDelays]);
			end
			% TODO: have a function called discountFraction and pass it
			% into this initialParam maker loop
		end



		function conditionalDiscountRates(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end

		function conditionalDiscountRates_GroupLevel(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end





		function plot(obj) % overriding from Model base class
			close all

			%% Corner plot of group-level params
			posteriorSamples = obj.mcmc.getSamplesAsMatrix({'varInc','alpha','epsilon'});
			priorSamples = obj.mcmc.getSamplesAsMatrix({'varInc_prior','alpha_prior','epsilon_prior'});
			varLabals = {'varInc','alpha','epsilon'};

			figure(87)
			import mcmc.*
			TriPlotSamples(posteriorSamples,...
				varLabals,...
				'PRIOR', priorSamples,...
				'pointEstimateType','mean');
			drawnow
			myExport('triplot',...
				'saveFolder', obj.saveFolder,...
				'prefix', 'group')


			%% Plot indifference functions for each participant
			obj.calcAUCscores()
			for p=1:obj.data.nParticipants
				% Extract info about a person for plotting purposes
				personInfo = obj.getParticipantData(p);

				% Plotting
				figure(1), clf

                subplot(1,2,1)
				intervals = [50 95];
				plotDiscountFunctionGRW(personInfo, intervals)
				latex_fig(16, 14, 4)
				%set(gca,'XScale','log')
				%axis tight
				%axis square

                subplot(1,2,2)
                uni = mcmc.UnivariateDistribution(obj.AUC_DATA(p).AUCsamples,...
                  'xLabel', 'AUC');

				myExport('discountfunction',...
				'saveFolder', obj.saveFolder,...
				'prefix', personInfo.participantName)
			end
		end


		function calcAUCscores(obj)
			%% Analyse AUC scores
			% TODO: Put this is a "generated quantities" function which is
			% auto-called after JAGS?
			delays = obj.data.observedData.uniqueDelays;
			for p=1:obj.data.nParticipants
				dfSamples = obj.extractDiscountFunctionSamples(p);

				obj.AUC_DATA(p).AUCsamples = calculateAUC(delays,dfSamples, false);

				obj.AUC_DATA(p).name  = obj.data.participantFilenames{p};
				%obj.AUC_DATA(p).name = participantName;
			end
		end


		function personStruct = getParticipantData(obj, p)
			% Create a structure with all the useful info about a person
			% p = person number
			participantName = obj.data.IDname{p};
			try
				parts = strsplit(participantName,'-');
				personStruct.participantName = strjoin(parts(1:2),'-');
			catch
				personStruct.participantName = participantName;
			end
			personStruct.delays = obj.data.observedData.uniqueDelays;
			personStruct.dfSamples = obj.extractDiscountFunctionSamples(p);
			personStruct.data = obj.data.getParticipantData(p);
			personStruct.AUCsamples = obj.AUC_DATA(p).AUCsamples;
		end


		function dfSamples = extractDiscountFunctionSamples(obj, personNumber)
			[chains, samples, participants, nDelays] = size(obj.mcmc.samples.discountFraction);
			personSamples = squeeze(obj.mcmc.samples.discountFraction(:,:,personNumber,:));
			% collapse over chains
			for d=1:nDelays
				dfSamples(:,d) = vec(personSamples(:,:,d));
			end
		end


	end


end
