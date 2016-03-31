classdef ModelHierarchicalNOMAG < ModelBaseClass
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)
		% =================================================================
		function obj = ModelHierarchicalNOMAG(toolboxPath, sampler, data, saveFolder)
			% Because this class is a subclass of "modelME" then we use
			% this next line to create an instance
			obj = obj@ModelBaseClass(toolboxPath, sampler, data, saveFolder);

			switch sampler
				case{'JAGS'}
					modelPath = '/jagsModels/hierarchicalNOMAG.txt';
					obj.sampler = JAGSSampler([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
				case{'STAN'}
					error('NOT IMPLEMENTED YET')
			end

			% give sampler a handle back to the model
			obj.sampler.modelHandle = obj;

			%% Create variables
			% -------------------------------------------------------------------
			% Participant-level -------------------------------------------------
			logk = Variable('logk','\log(k)', [], true);
			logk.seed.func = @() normrnd(-0.243,10);
			logk.seed.single = false;

			epsilon = Variable('epsilon','\epsilon', [0 0.5], true);
			epsilon.seed.func = @() 0.1 + rand/10;
			epsilon.seed.single = false;

			alpha = Variable('alpha','\alpha', 'positive', true);
			alpha.seed.func = @() abs(normrnd(0.01,0.001));
			alpha.seed.single = false;

			% -------------------------------------------------------------------
			% group level (ie what we expect from an as yet unobserved person ---
			% TODO: This could be implemented just by having another participant
			% with no observed data? This would remove the need for all these gl*
			% variables here and in the JAGS model and make things much simpler.
			logk_group				= Variable('logk_group','logk group', [], true);
			logk_group_prior	= Variable('logk_group_prior','logk group prior', [], true);

			epsilon_group		= Variable('epsilon_group','\epsilon group', [0 0.5], true);
			epsilon_group_prior = Variable('epsilon_group_prior','\epsilon group prior', [0 0.5], true);

			alpha_group			= Variable('alpha_group','\alpha group', 'positive', true);
			alpha_group_prior	= Variable('alpha_group_prior','\alpha group prior', 'positive', true);

			% -------------------------------------------------------------------
			% group level priors ------------------------------------------------
			groupLogKmu	= Variable('groupLogKmu','groupLogKmu', [], true);
			groupLogKmuprior = Variable('groupLogKmuprior','groupLogKmuprior', [], true);

			groupLogKsigma	= Variable('groupLogKsigma','groupLogKsigma', [], true);
			groupLogKsigmaprior = Variable('groupLogKsigmaprior','groupLogKsigmaprior', [], true);
			
			groupW		= Variable('groupW','\omega', [0 1], true);
			groupWprior = Variable('groupWprior','\omega prior', [0 1], true);

			groupK		= Variable('groupK','\kappa', 'positive', true);
			groupKprior = Variable('groupKprior','\kappa prior', 'positive', true);

			groupALPHAmu = Variable('groupALPHAmu','\mu^\alpha', 'positive', true);
			groupALPHAsigma = Variable('groupALPHAsigma','\sigma^\alpha', 'positive', true);
			groupALPHAmuprior = Variable('groupALPHAmuprior','\mu^\alpha prior', 'positive', true);
			groupALPHAsigmaprior = Variable('groupALPHAsigmaprior','\sigma^\alpha prior', 'positive', true);

			% posterior predictive ----------------------------------------------
			Rpostpred = Variable('Rpostpred','Rpostpred', [0 1], true);
			Rpostpred.plotMCMCchainFlag = false;

			% define which to analyse (univariate analysis) ---------------------
			% 1 = participant level
			logk.analysisFlag = 1;
			epsilon.analysisFlag = 1;
			alpha.analysisFlag = 1;

			% 2 = group level
			logk_group.analysisFlag = 2;
			epsilon_group.analysisFlag = 2;
			alpha_group.analysisFlag = 2;


			% Create a Variable array -------------------------------------------
			obj.variables = [logk, epsilon, alpha,... % mprior, cprior, epsilonprior, alphaprior,...
				groupLogKmu, groupLogKsigma,...
				groupW, groupWprior,...
				groupK, groupKprior,...
				logk_group, alpha_group, epsilon_group,...
				logk_group_prior, alpha_group_prior, epsilon_group_prior,...
				groupALPHAmu, groupALPHAmuprior,...
				groupALPHAsigma, groupALPHAsigmaprior,...
				Rpostpred];
			
			% Variable list, used for plotting
			obj.varList.participant_level_variables = ...
				{'logk','alpha','epsilon'};
			
			obj.varList.participant_level_prior_variables = ...
				{'logk_group_prior',...
				'alpha_group_prior',...
				'epsilon_group_prior'};
			
			obj.varList.group_level_variables =...
				{'logk_group','alpha_group','epsilon_group'};
			
			obj.varList.group_level_prior_variables = ...
				{'logk_group_prior',...
				'alpha_group_prior',...
				'epsilon_group_prior'};

		end
		% =================================================================


		function plot(obj)
			close all

			obj.plotPsychometricParams()
			myExport(obj.saveFolder, obj.modelType, '-PsychometricParams')

			%% GROUP LEVEL
			% Tri plot
			obj.figGroupTriPlot(obj.varList.group_level_variables, obj.varList.group_level_prior_variables)
			myExport(obj.saveFolder, obj.modelType, ['-GROUP-triplot'])

			obj.figGroupLevel(obj.varList.group_level_variables)

			%% PARTICIPANT LEVEL

			% plot univariate summary statistics --------------------------------
			obj.figUnivariateSummary(obj.data.IDname, obj.varList.participant_level_variables)
			latex_fig(16, 5, 5)
			myExport(obj.saveFolder, obj.modelType, '-UnivariateSummary')
			% -------------------------------------------------------------------

			obj.figParticipantLevelWrapper(obj.varList.participant_level_variables,...
				obj.varList.participant_level_prior_variables)
		end


		function conditionalDiscountRates(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end

		function conditionalDiscountRates_GroupLevel(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end


		function plotPsychometricParams(obj)
			% Plot priors/posteriors for parameters related to the psychometric
			% function, ie how response 'errors' are characterised
			%
			% plotPsychometricParams(hModel.sampler.samples)

 			samples = obj.sampler.getAllSamples();

			figure(7), clf
			P=obj.data.nParticipants; 
			%====================================
			subplot(3,2,1)
			plotPriorPostHist(samples.alpha_group_prior(:), samples.alpha_group(:));
			title('Group \alpha')

			subplot(3,4,5)
			plotPriorPostHist(samples.groupALPHAmuprior(:), samples.groupALPHAmu(:));
			xlabel('\mu_\alpha')

			subplot(3,4,6)
			plotPriorPostHist(samples.groupALPHAsigmaprior(:), samples.groupALPHAsigma(:));
			xlabel('\sigma_\alpha')

			subplot(3,2,5),
			for p=1:P-1 % plot participant level alpha (alpha(:,:,p))
				%histogram(vec(samples.alpha(:,:,p)));
				[F,XI]=ksdensity(vec(samples.alpha(:,:,p)),...
					'support','positive',...
					'function','pdf');
				plot(XI, F)
				hold on
			end
			xlabel('\alpha_p')
			box off

			%====================================
			subplot(3,2,2)
			plotPriorPostHist(samples.epsilon_group_prior(:), samples.epsilon_group(:));
			title('Group \epsilon')

			subplot(3,4,7),
			plotPriorPostHist(samples.groupWprior(:), samples.groupW(:));
			xlabel('\omega (mode)')

			subplot(3,4,8),
			plotPriorPostHist(samples.groupKprior(:), samples.groupK(:));
			xlabel('\kappa (concentration)')

			subplot(3,2,6),
			for p=1:P-1 % plot participant level alpha (alpha(:,:,p))
				%histogram(vec(samples.epsilon(:,:,p)));
					[F,XI]=ksdensity(vec(samples.epsilon(:,:,p)),...
					'support','positive',...
					'function','pdf');
				plot(XI, F)
				hold on
			end
			xlabel('\epsilon_p')
			box off
		end
		
	end







	methods (Access = protected)
		
		function figUnivariateSummary(obj, participantIDlist, variables)
			% loop over variables provided, plotting univariate summary
			% statistics.
			
			% We are going to add on group level inferences to the end of the
			% participant list. This is because the group-level inferences an be
			% seen as inferences we can make about an as yet unobserved
			% participant, in the light of the participant data available thus
			% far.
			participantIDlist{end+1}='GROUP';
			
			figure
			for v = 1:numel(variables)
				subplot(numel(variables),1,v)
				hdi = [obj.sampler.getStats('hdi_low',variables{v})' obj.sampler.getStats('hdi_low',[variables{v} '_group']) ;...
					obj.sampler.getStats('hdi_high',variables{v})' obj.sampler.getStats('hdi_high',[variables{v} '_group'])];
				plotErrorBars({participantIDlist{:}},...
					[obj.sampler.getStats('mean',variables{v})' obj.sampler.getStats('mean',[variables{v} '_group'])],...
					hdi,...
					variables{v});
				a=axis; axis([0.5 a(2)+0.5 a(3) a(4)]);
			end
		end
		
		% *********************************************************************
		% *********************************************************************
		% *********************************************************************
		% *********************************************************************
		% THIS IS WHAT CHANGES WITH LOGK
		% *********************************************************************
		% *********************************************************************
		function figGroupLevel(obj, variables)
			% get group level parameters in a form ready to pass off to
			% figParticipant()

			% Get group-level data
			[pSamples] = obj.sampler.getSamples(variables);
			% rename fields
			[pSamples.('logk')] = pSamples.('logk_group'); pSamples = rmfield(pSamples,'logk_group');
			[pSamples.('epsilon')] = pSamples.('epsilon_group'); pSamples = rmfield(pSamples,'epsilon_group');
			[pSamples.('alpha')] = pSamples.('alpha_group'); pSamples = rmfield(pSamples,'alpha_group');

			pData = []; % no data for group level

			figure(99), clf
			set(gcf,'Name','GROUP LEVEL')
			
			logkMEAN = obj.sampler.getStats('mean', 'logk_group');
			epsilonMEAN = obj.sampler.getStats('mean', 'epsilon_group');
			alphaMEAN = obj.sampler.getStats('mean', 'alpha_group');

			obj.figParticipant(pSamples, pData, logkMEAN, epsilonMEAN, alphaMEAN)

			% EXPORTING ---------------------
			latex_fig(16, 18, 4)
			myExport(obj.saveFolder, obj.modelType, '-GROUP')
			% -------------------------------
		end
		% *********************************************************************
		% *********************************************************************
		
		
		% OVERRIDDEN FROM BASE CLASS ******************************************
		% *********************************************************************
		function figParticipant(obj, pSamples, pData, logkMEAN, epsilonMEAN, alphaMEAN)
			rows=1; cols=4;
			
			% BIVARIATE PLOT: lapse rate & comparison accuity
			subplot(rows, cols, 1)
			plot2DErrorAccuity(pSamples.epsilon(:), pSamples.alpha(:), epsilonMEAN, alphaMEAN);
			
			% PSYCHOMETRIC FUNCTION (using my posterior-prediction-plot-matlab GitHub repository)
			subplot(rows, cols, 2)
			plotPsychometricFunc(pSamples, [epsilonMEAN, alphaMEAN])
			
			% logk
			subplot(rows, cols, 3)
			plotPriorPostHist([], pSamples.logk(:));
			%histogram(pSamples.logk(:))
			axis square
			
			% TODO:
			% Plot in 2D data space
			subplot(rows, cols, 4)
			if ~isempty(pData)
				% participant level
				plot2DdataSpace(pData, logkMEAN)
			else
				% for group level where there is no data
				plotDiscountFunction(logkMEAN);
			end

		end
		% *********************************************************************
		% *********************************************************************
		
		
		
		% OVERRIDDEN FROM BASE CLASS ******************************************
		% *********************************************************************

		function figParticipantLevelWrapper(obj, variables, participant_prior_variables)
			% For each participant, call some plotting functions on the variables provided.

			logkMEAN = obj.sampler.getStats('mean', 'logk');
			epsilonMEAN = obj.sampler.getStats('mean', 'epsilon');
			alphaMEAN = obj.sampler.getStats('mean', 'alpha');
			
			for n = 1:obj.data.nParticipants
				fh = figure;
				fh.Name=['participant: ' obj.data.IDname{n}];

				% 1) figParticipant plot
				[pSamples] = obj.sampler.getSamplesAtIndex(n, variables);
				[pData] = obj.data.getParticipantData(n);
				obj.figParticipant(pSamples, pData, logkMEAN(n), epsilonMEAN(n), alphaMEAN(n))
				latex_fig(16, 18, 4)
				myExport(obj.saveFolder, obj.modelType, ['-' obj.data.IDname{n}])
				close(fh)

				% 2) Triplot
				obj.figParticiantTriPlot(n, variables, participant_prior_variables)
				myExport(obj.saveFolder, obj.modelType, ['-' obj.data.IDname{n} '-triplot'])
			end
		end
		% *********************************************************************
		% *********************************************************************
		
				
				
		function figGroupTriPlot(obj, variables, group_level_prior_variables)
			warning('Heavy but not exact duplication of figParticiantTriPlot() in ModelBaseClass')
			% samples from posterior
			[posteriorSamples] = obj.sampler.getSamplesAsMatrix(variables);

			[priorSamples] = obj.sampler.getSamplesAsMatrix(group_level_prior_variables);

			figure(87)
			variable_label_names={'m','c','alpha','epsilon'};
			triPlotSamples(posteriorSamples, priorSamples, variable_label_names, [])
		end

	end

end
