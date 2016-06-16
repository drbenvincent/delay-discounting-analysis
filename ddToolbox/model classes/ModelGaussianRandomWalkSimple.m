%KIRBY DATA IS NOT APPROPRIATE FOR THIS MODEL
% We need experimental paradigms that try to pinpoint the indifference
% point for a set number of delays.

classdef ModelGaussianRandomWalkSimple < Model
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)
		% =================================================================
		function obj = ModelGaussianRandomWalkSimple(toolboxPath, samplerType, data, saveFolder, varargin)
			obj = obj@Model(data, saveFolder, varargin{:});

			switch samplerType
				case{'JAGS'}
					modelPath = '/models/mixedGRWalt.txt';
					obj.sampler = MatjagsWrapper([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
				case{'STAN'}
					error('model not implemented in STAN.')
% 					modelPath = '/models/hierarchicalLogK.stan';
% 					obj.sampler = MatlabStanWrapper([toolboxPath modelPath]);
% 					[~,obj.modelType,~] = fileparts(modelPath);
			end
			obj.discountFuncType = 'logk';
			% 'Decorate' the object with appropriate plot functions
			obj.plotFuncs.participantFigFunc = @figParticipantLOGK;
			obj.plotFuncs.plotGroupLevel = @plotGroupLevelStuff;

			
% 			%% Create variables
% 			obj.varList.participantLevel = {'discountFraction',};
%             obj.varList.participantLevelPriors = {};
% 			obj.varList.groupLevel = {};
 			obj.varList.monitored = {'discountFraction', 'dfInterp'};
% 
% 			%% Deal with generating initial values of leaf nodes
% 			obj.variables.discountFraction = Variable('discountFraction',...
% 				'seed', @() normrnd(1,0.1),...
% 				'single',false);
			


			
			
		end
		% =================================================================

		% Generate initial values of the leaf nodes
		function setInitialParamValues(obj)
			
			nTrials = size(obj.data.observedData.A,2);
			nParticipants = obj.data.nParticipants;
			nUniqueDelays = numel(obj.data.observedData.uniqueDelays);
			
			for chain = 1:obj.sampler.mcmcparams.nchains
				obj.initialParams(chain).discountFraction = normrnd(1, 0.1, [nParticipants,nUniqueDelays]);
			end
		end
		
		
		
		function conditionalDiscountRates(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end

		function conditionalDiscountRates_GroupLevel(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end

		
		
		
	
		function plot(obj) % overriding from Model base class			
			
			figure(1), clf
			
			
			
			% plot the GAUSSIAN RANDOM WALK STUFF
			for p=1:obj.data.nParticipants
				clear dfSamples
				
				delays = obj.data.observedData.uniqueDelays;
				
				[chains, samples, participants, nDelays] = size(obj.mcmc.samples.discountFraction);

				% extract samples for this participant
				personSamples = squeeze(obj.mcmc.samples.discountFraction(:,:,p,:));
			
				% collapse over chains
				for d=1:nDelays
					dfSamples(:,d) = vec(personSamples(:,:,d));
				end
				
				
				subplot(1,obj.data.nParticipants,p)
				
				%plot(delays, mean(dfSamples))
				
				%plot(obj.data.observedData.uniqueDelays, dfSamples(:,[1:1000]))
				
 				ribbon_plot(delays, dfSamples, [0.5, 0.5, 0.5])
				
				hold on
				data = obj.data.getParticipantData(p);
				plotDiscountingData(data)
				title(obj.data.IDname{p})
				xlabel('delay')
				%axis square
				axis tight
				hline(1)
				set(gca,'YLim',[0 2.5])
				drawnow
				
				% plot interpolated
				figure(1)
				
				
				%% plot interp
				delays = obj.data.observedData.dInterp;
				[chains, samples, participants, nDelays] = size(obj.mcmc.samples.dfInterp);
				personSamples = squeeze(obj.mcmc.samples.dfInterp(:,:,p,:));
				% collapse over chains
				for d=1:numel(delays)
					dfSamples(:,d) = vec(personSamples(:,:,d));
				end
				subplot(1,obj.data.nParticipants,p)
				ribbon_plot(delays, dfSamples, [0.9 0.9 0.9])
			end
			
% 			delays = obj.data.observedData.dInterp;
% 			figure(2)
% 			
% 			% extract samples for this participant
% 			personSamples = squeeze(obj.mcmc.samples.dfInterp(:,:,p,:));
% 			% collapse over chains
% 			for d=1:numel(delays)
% 				dfSamples(:,d) = vec(personSamples(:,:,d));
% 			end
% 			subplot(1,obj.data.nParticipants,p)
% 			ribbon_plot(delays, dfSamples, [0.9 0.9 0.9])

		end
		
		
		

	end	
	


end
