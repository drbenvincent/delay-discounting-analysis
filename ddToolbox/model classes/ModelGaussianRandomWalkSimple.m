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
					modelPath = '/models/mixedGRWsimple.txt';
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
 			obj.varList.monitored = {'discountFraction'};
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
				
 				ribbon_plot(delays, dfSamples, [50 95])
				
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
				
				Z = calculateAUC(delays,dfSamples, false);
				auc_str = sprintf('mean AUC: %1.2f',mean(Z));
				addTextToFigure('BR',auc_str, 15, 'latex')
				
				% Store samples of AUC in a participant structure
				AUC_DATA(p).name = obj.data.participantFilenames{p};
				AUC_DATA(p).Z = Z;
				
				
				% plot interpolated
				figure(1)
				
				
% 				%% plot interp
% 				delays = obj.data.observedData.dInterp;
% 				[chains, samples, participants, nDelays] = size(obj.mcmc.samples.dfInterp);
% 				personSamples = squeeze(obj.mcmc.samples.dfInterp(:,:,p,:));
% 				% collapse over chains
% 				for d=1:numel(delays)
% 					dfSamples(:,d) = vec(personSamples(:,:,d));
% 				end
% 				subplot(1,obj.data.nParticipants,p)
% 				ribbon_plot(delays, dfSamples, [0.9 0.9 0.9])
			end
			
			
			
			
			
			
			
			% PLOT AUC HERE
			% We have a structure with fields name, Z.
			% The names are suffixed with 'gain' or 'loss', so go through
			% and match up the people.
			all_names = {};
			for p=1:obj.data.nParticipants
				% split name into name + condition
				name = AUC_DATA(p).name;
				parts = strsplit(name,'-');
				name_of_this_person = parts{1};
				condition = parts{2};
				% append name to list if it's the first one, or if it's not
				% already on the list
				if isempty(all_names)
					all_names{1} = name_of_this_person;
				else
					all_names{numel(all_names)+1} = name_of_this_person;
				end
			end
			all_names = unique(all_names);
			% Now loop over people and extract summary info
			n_unique_people = length(all_names);
			for p=1:n_unique_people
				initials = all_names{p};
				
				% cycle through all people to find their gain
				search_for = strjoin({initials,'gains'},'-');
				for I=1:obj.data.nParticipants
					parts = strsplit(AUC_DATA(I).name,'-');
					first2parts = strjoin({parts{1:2}},'-');
					if strncmp(search_for,first2parts,numel(search_for)-1)
						summary(p).gain_mean = mean(   AUC_DATA(I).Z    );
						UL = prctile(AUC_DATA(I).Z ,[25, 75]);
						summary(p).gain_lower = UL(1);
						summary(p).gain_upper = UL(2);
					end
				end

				% cycle through all people to find their loss
				search_for = strjoin({initials,'loss'},'-');
				for I=1:obj.data.nParticipants
					parts = strsplit(AUC_DATA(I).name,'-');
					first2parts = strjoin({parts{1:2}},'-');
					if strncmp(search_for,first2parts,numel(search_for)-1)
						summary(p).loss_mean = mean(   AUC_DATA(I).Z    );
						UL = prctile(AUC_DATA(I).Z ,[25, 75]);
						summary(p).loss_lower = UL(1);
						summary(p).loss_upper = UL(2);
					end
				end
			end

			summary
			
			% FINALLY! Plot in losses space
			figure(3), clf
			for n=1:n_unique_people
				hold on
				% point estimate
				%plot( summary(n).loss_mean, summary(n).gain_mean, 'ko')
				% error bar for losses
				plot( [summary(n).loss_lower summary(n).loss_upper], ...
					[summary(n).gain_mean summary(n).gain_mean],'k-')
				% error bar for gains
				plot( [summary(n).loss_mean summary(n).loss_mean], ...
					[summary(n).gain_lower summary(n).gain_upper],'k-')
			end
			xlabel('AUC for losses','Interpreter','latex')
			ylabel('AUC for gains','Interpreter','latex')
			axis([0 3 0 3])
			axis square
			grid on
			
			hline(1)
			vline(1)
			
			%set(gca,'XAxisLocation','origin')
			%set(gca,'YAxisLocation','origin')
			
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
