classdef Model
	%Model Base class to provide basic functionality

	properties (Access = public)
		modelFile
		samplerType
		saveFolder
		mcmc % handle to mcmc fit object
		discountFuncType
		pointEstimateType
		postPred
		parameterEstimateTable
	end

	properties (Hidden)
		% User supplied preferences
		mcmcSamples
		chains
		modelType % string (ie modelType.jags, or modelType.stan)
		sampler % handle to SamplerWrapper class
		data % handle to Data class
		varList
		plotFuncs % structure of function handles
		initialParams
		shouldPlot
	end

	methods(Abstract, Access = public)
	end

	methods (Access = public)

		function obj = Model(data, varargin)
			p = inputParser;
			p.FunctionName = mfilename;
			p.addRequired('data', @(x) isa(x,'DataClass'));
			p.addParameter('saveFolder','my_analysis', @isstr);
			p.addParameter('pointEstimateType','mode',@(x) any(strcmp(x,{'mean','median','mode'})));
			p.parse(data, varargin{:});

			% add p.Results fields into obj
			fields = fieldnames(p.Results);
			for n=1:numel(fields)
				obj.(fields{n}) = p.Results.(fields{n});
			end
		end



		% MIDDLE-MAN METHODS ================================================

		function obj = conductInference(obj, samplerType, varargin)
			% TODO: get the observed data from the raw group data here.
			samplerType     = lower(samplerType);

			obj.modelFile = makeProbModelsPath(obj.modelType, samplerType);

			p = inputParser;
			p.FunctionName = mfilename;
			p.addRequired('samplerType',@ischar);
			% additional user-supplied preferences
			p.addParameter('mcmcSamples',[], @isscalar)
			p.addParameter('chains',[], @isscalar)
			p.addParameter('shouldPlot','no',@(x) any(strcmp(x,{'all','no'})));
			p.parse(samplerType, varargin{:});

			% add p.Results fields into obj
			fields = fieldnames(p.Results);
			for n=1:numel(fields)
				obj.(fields{n}) = p.Results.(fields{n});
			end

			%% Create sampler object
			% TODO: This can happen on the fly, when we call model.conduct_inference()
			switch obj.samplerType
				case{'jags'}
					% Create sampler object
					obj.sampler = MatjagsWrapper(obj.modelFile);

					% *** update obj.sampler.mcmcparams here ***

					% 					% override any user-defined prefs
					% 					if ~isempty( obj.mcmcSamples )
					% 						obj.sampler.setMCMCtotalSamples(obj.mcmcSamples)
					% 					end
					% 					if ~isempty( obj.chains )
					% 						obj.sampler.setMCMCnumberOfChains(obj.chains)
					% 					end
				case{'stan'}
					obj.sampler = MatlabStanWrapper(obj.modelFile);
					%obj.sampler.setStanHome('~/cmdstan-2.9.0') % TODO: sort this out

					% *** update obj.sampler.mcmcparams here ***
			end


			%% Ask the Sampler to do MCMC sampling, return an mcmcObject ~~~~~~~~~~~~~~~~~
			%obj.mcmc = obj.sampler.conductInference( obj , obj.data );
			obj.mcmc = obj.sampler.conductInference( obj , obj.data );
			%obj.mcmc = mcmcObject;
			% fix/check ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

			%% Post-sampling activities
			obj = obj.calcPosteriorPredictive();
			obj.mcmc.convergenceSummary(obj.saveFolder, obj.data.IDname)
			obj.exportParameterEstimates();

			% Deal with plotting options
			if ~strcmp(obj.shouldPlot,'no')
				obj.plot()
			end

			obj.tellUserAboutPublicMethods()
		end

        % TODO: remove these ^^^^^^^^^^^^^^^^^^^^^^^^^^
		function obj = setBurnIn(obj, nburnin)
			obj.sampler.setBurnIn(nburnin)
		end

		function obj = setMCMCtotalSamples(obj, totalSamples)
			obj.sampler.setMCMCtotalSamples(totalSamples)
		end

		function obj = setMCMCnumberOfChains(obj, nchains)
			obj.sampler.setMCMCnumberOfChains(nchains)
		end
        % ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

		function obj = plotMCMCchains(obj,vars)
			obj.mcmc.plotMCMCchains(vars);
		end

		function finalTable = exportParameterEstimates(obj, varargin)
			%% Create table of parameter estimates
			paramEstimateTable = obj.mcmc.exportParameterEstimates(...
				obj.varList.participantLevel,...
				obj.varList.groupLevel,...
				obj.data.IDname,...
				obj.saveFolder,...
				obj.pointEstimateType,...
				varargin{:});
			%% Create table of posterior prediction measures
			% Add mean score (log ratio of model vs control)
			ppScore = [obj.postPred(:).score]';
			% Calculate point estimates of perceptPredicted. use the point
			% estimate type that the user specified
			pointEstFunc = str2func(obj.pointEstimateType);
			for p=1:obj.data.nParticipants
				percentPredicted(p,1) = pointEstFunc( obj.postPred(p).percentPredictedDistribution );
			end
			% Check if HDI of percentPredicted overlaps with 0.5
			% Using mcmc-utils-matlab package
			for p=1:obj.data.nParticipants
				[HDI] = mcmc.HDIofSamples(...
					obj.postPred(p).percentPredictedDistribution,...
					0.95);
				if HDI(1)<0.5
					warning_percent_predicted(p,1) = true;
				else
					warning_percent_predicted(p,1) = false;
				end
			end
			% make table
			postPredTable = table(ppScore,...
				percentPredicted,...
				warning_percent_predicted,...
				'RowNames',obj.data.IDname);

			%% Combine the tables
			finalTable = join(paramEstimateTable, postPredTable,...
				'Keys','RowNames');
			display(finalTable)

			%% Export table to textfile
			fname = ['parameterEstimates_Posterior_' obj.pointEstimateType '.csv'];
			savePath = fullfile('figs',obj.saveFolder,fname);
			exportTable(finalTable, savePath);

			%% Store the table
			obj.parameterEstimateTable = finalTable;

		end





		function obj = conditionalDiscountRates(obj, reward, plotFlag)
			% Extract and plot P( log(k) | reward)
			warning('THIS METHOD IS A TOTAL MESS - PLAN THIS AGAIN FROM SCRATCH')
			obj.conditionalDiscountRates_ParticipantLevel(reward, plotFlag)

			if plotFlag
				removeYaxis
				title(sprintf('$P(\\log(k)|$reward=$\\pounds$%d$)$', reward),'Interpreter','latex')
				xlabel('$\log(k)$','Interpreter','latex')
				axis square
			end
		end





		% **********************************************************************
		% **********************************************************************
		% PLOTTING *************************************************************
		% **********************************************************************
		% **********************************************************************
		% This plot method is highly unsatisfactory. We have a whole bunch of logic
		% which decides on the properties of the model (hierachical or not) and
		% (logk vs magnitude effect). It then uses a bunch of get methods in order
		% to grab the data in the appropriate format. We then pass this data to plot
		% functions/classes.
		%
		% Thinking needs to be done about the best way to refactor all this mess.





		function plot(obj)
			close all

			% IDEAS:
			% - Loop over participants (and group if there is one) and
			% create an array of objects of a new participant class. This
			% class will contain all the data for that person, as well as
			% the plotting functions.
			%
			% - Or....


			%% PARTICIPANT LEVEL  =========================================
			% We will ALWAYS have participants.
			obj.plotParticiantStuff( )


			%% GROUP LEVEL ================================================
			% We are going to call this function, but it will be a 'null function' for models not doing hierachical inference. This is set in the concrete model class constructors.
			obj.plotFuncs.plotGroupLevel( obj )


			%% POSTERIOR PREDICTION PLOTS =================================
			for p=1:obj.data.nParticipants

				% 				% Calc goodness of fit and % responses predicted,
				% 				% distributions
				% 				[GOFdistribution, percentPredictedDistribution] = calcGoodnessOfFitDistribution(p);

				figure(1), colormap(gray), clf

				subplot(2,2,1)
				obj.pp_plotTrials(p)

				subplot(2,2,2)
				obj.pp_plotGOFdistribution(obj.postPred(p).GOF_distribtion)

				subplot(2,2,3)
				obj.pp_plotPredictionAndResponse(p)

				subplot(2,2,4)
				obj.pp_ploptPercentPredictedDistribution(p)


				%% Export figure
				drawnow
				latex_fig(16, 9, 6)
				myExport('PosteriorPredictive',...
					'saveFolder',obj.saveFolder,...
					'prefix', obj.data.IDname{p},...
					'suffix', obj.modelType)
			end

		end











	end

	methods (Access = private)

		function varNames = extractLevelNVarNames(obj, N)
			varNames={};
			for var = each(fieldnames(obj.variables))
				if obj.variables.(var).analysisFlag == N
					varNames{end+1} = var;
				end
			end
		end

		function bool = isGroupLevelModel(obj)
			% we determine if the model has group level parameters by checking if
			% we have a 'groupLevel' subfield in the varList.
			if isfield(obj.varList,'groupLevel')
				bool = ~isempty(obj.varList.groupLevel);
			end
		end

		function tellUserAboutPublicMethods(obj)
			methods(obj)
		end


		function conditionalDiscountRates_ParticipantLevel(obj, reward, plotFlag)
			nParticipants = obj.data.nParticipants;
			%count=1;
			for p = 1:nParticipants
				params(:,1) = obj.mcmc.getSamplesFromParticipantAsMatrix(p, {'m'});
				params(:,2) = obj.mcmc.getSamplesFromParticipantAsMatrix(p, {'c'});
				% ==============================================
				[posteriorMean(p), lh(p)] =...
					calculateLogK_ConditionOnReward(reward, params, plotFlag);
				%lh(count).DisplayName=sprintf('participant %d', p);
				%row(count) = {sprintf('participant %d', p)};
				% ==============================================
				%count=count+1;
			end
			warning('GET THESE NUMBERS PRINTED TO SCREEN')
			% 			logkCondition = array2table([posteriorMode'],...
			% 				'VariableNames',{'logK_posteriorMode'},...)
			% 				'RowNames', num2cell([1:nParticipants]) )
		end




		%% POSTERIOR PREDICTION ===========================================

		function obj = calcPosteriorPredictive(obj)
			display('Calculating posterior predictive measures...')
			nParticipants = obj.data.nParticipants;

			%% Calculate various posterior predictive measures
			% data saved to obj.postPred(p).xxx

			for p=1:nParticipants

				% Calculate overall log prob of model, compared to random
				obj.postPred(p).score = obj.postPredOverallScore(p);

				% Calculate:
				% - distribution of log ratio scores
				% - distribution of percent of responses predicted
				[obj.postPred(p).GOF_distribtion,...
					obj.postPred(p).percentPredictedDistribution] ...
					= obj.calcGoodnessOfFitDistribution(p);

				% TODO: make judgements about whether model is good enough

			end
		end

		function RpostPred = getParticipantPredictedResponses(obj,p)
			trialIndOfThisParicipant = obj.data.observedData.ID==p;
			RpostPred = obj.mcmc.getParticipantPredictedResponses(trialIndOfThisParicipant);
		end

		%% Posterior predictive model checking #1
		% This approach comes up with a single goodness of fit score.
		% It is the log ratio between the posterior predicted responses
		% of the model and the predicted responses of a control model
		% (which responses randomly).
		% NOTE: That this is based upon Rpostpred.

		function score = postPredOverallScore(obj, p)
			% Calculate log posterior odds of data under the model and a
			% control model where prob of responding is 0.5.
			% Responses are Bernoulli distributed, which is a special case
			% of the Binomial with 1 event.
			prob = @(responses, predicted) prod(binopdf(responses, ...
				ones(size(responses)),...
				predicted));
			% Calculate fit between posterior predictive responses and actual
			participant(p).predicted = obj.getParticipantPredictedResponses(p);
			participantResponses = obj.data.participantLevel(p).table.R;
			pModel = prob(participantResponses, participant(p).predicted');

			% calculate fit between control (random) model and actual
			% responses
			controlPredictions = ones(size(participantResponses)) .* 0.5;
			pRandom = prob(participantResponses, controlPredictions);

			score = log( pModel ./ pRandom);
		end

		%% Posterior predictive model checking #2
		% This takes a different approach. Because we calculate
		% P(choose delayed) directly (variable P in the model) then we
		% haev these predicted probabilities for every MCMC sample.
		% This means we can compute a distribution of model fits
		% compared to the control model.
		% We can then examine whether the 95% CI overlaps with 1, which
		% we can take as indicating the model does not predict people's
		% responases better than chance.
		function [GOF_distribtion, percentPredictedDistribution] = calcGoodnessOfFitDistribution(obj,p)
			% return a distribution of goodness of fit scores. One
			% value for each MCMC sample.
			% This is quite memory-intensive, so we are calculating it
			% on demand and not storing it.

			% get predicted P(choose delayed)
			trialIndOfThisParicipant = obj.data.observedData.ID==p;
			P = obj.mcmc.getPChooseDelayed(trialIndOfThisParicipant);
			% 			% trim off any empty data from the ragged array approach
			% 			P = P([1:obj.data.participantLevel(p).trialsForThisParticant],:);

			nQuestions = size(P,1);
			totalSamples = size(P,2);
			% get participant responses
			participantResponses = obj.data.participantLevel(p).table.R;
			%totalSamples = obj.sampler.mcmcparams.totalSamples;

			% Expand the participant responses so we can do vectorised
			% calculations below
			participantResponsesREP = repmat(participantResponses, [1,totalSamples]);

			%% Calculate % responses predicted by the model
			%modelPrediction(P<0.5)=0;
			modelPrediction = zeros(size(P));
			modelPrediction(P>=0.5)=1;
			isCorrectPrediction = modelPrediction == participantResponsesREP;
			percentPredictedDistribution = sum(isCorrectPrediction,1)./nQuestions;

			%% Calculate goodness of fit
			% P(responses | model)
			% product is over trials
			pModel = prod(binopdf(participantResponsesREP, ones(size(participantResponsesREP)), P));

			% P(responses | control model)
			controlP = ones(size(P)).*0.5;
			pControl = prod(binopdf(participantResponsesREP, ones(size(participantResponsesREP)), controlP));

			% Calculate log goodness of fit ratio
			GOF_distribtion = log(pModel./pControl);
		end



		function pp_plotGOFdistribution(obj,gofscores)
			uni = mcmc.UnivariateDistribution(gofscores(:),...
				'xLabel', 'goodness of fit score',...
				'plotStyle','hist',...
				'pointEstimateType',obj.pointEstimateType);
		end

		function pp_ploptPercentPredictedDistribution(obj,p)
			nQuestions = obj.data.participantLevel(p).trialsForThisParticant;

			uni = mcmc.UnivariateDistribution(obj.postPred(p).percentPredictedDistribution(:),...
				'xLabel', '$\%$ proportion responses accounted for',...
				'plotStyle','hist',...
				'pointEstimateType',obj.pointEstimateType);

			axis tight
			vline(0.5)
			set(gca,'XLim',[0 1])
		end

		function pp_plotTrials(obj,p)
			% plot predicted probability of choosing delayed
			bar(obj.getParticipantPredictedResponses(p),'BarWidth',1)
			if p<obj.data.nParticipants, set(gca,'XTick',[]), end
			box off
			axis tight
			% plot response data
			hold on
			plot([1:obj.data.participantLevel(p).trialsForThisParticant],... % <-- replace with a get method
				obj.data.participantLevel(p).table.R,... % <-- replace with a get method
				'+')
			myString = sprintf('%s', obj.data.IDname{p});
			title(myString)

			xlabel('trial')
			ylabel('response')
			legend('prediction','response', 'Location','East')
		end

		function pp_plotPredictionAndResponse(obj, p)
			h(1) = plot(obj.getParticipantPredictedResponses(p),...
				obj.data.participantLevel(p).table.R,...
				'+');
			xlabel('P(choose delayed)')
			ylabel('Response')
			legend(h, 'data')
			box off
		end





		function plotParticiantStuff(obj)

			% UNIVARIATE SUMMARY STATISTICS ---------------------------------
			% We are going to add on group level inferences to the end of the
			% list. This is because the group-level inferences an be
			% seen as inferences we can make about an as yet unobserved
			% participant, in the light of the participant data available thus
			% far.
			IDnames = obj.data.IDname;
			if obj.isGroupLevelModel()
				IDnames{end+1}='GROUP';
			end
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
			obj.mcmc.figUnivariateSummary(IDnames, obj.varList.participantLevel, obj.pointEstimateType)
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
			latex_fig(16, 5, 5)
			myExport('UnivariateSummary',...
				'saveFolder',obj.saveFolder,...
				'prefix', obj.modelType)
			% --------------------------------------------------------------------




			pVariableNames = obj.varList.participantLevel;


			% LOOP OVER PARTICIPANTS
			for n = 1:obj.data.nParticipants
				participantFigFunc()
				participantTriPlot()
			end


			function participantFigFunc()
				% TODO ??????????????????
				opts.maxlogB	= max(abs(obj.data.observedData.B(:)));
				opts.maxD		= max(obj.data.observedData.DB(:));
				% ??????????????????

				fh = figure;
				fh.Name=['participant: ' obj.data.IDname{n}];

				% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
				participantSamples = obj.mcmc.getSamplesAtIndex(n, pVariableNames);
				pData = obj.data.getParticipantData(n);

				% create a string describing goodness of fit
				percentPredicted = obj.postPred(n).percentPredictedDistribution(:);
				pp = mcmc.UnivariateDistribution(percentPredicted, 'shouldPlot', false);
				goodnessStr = sprintf('%% predicted: %3.1f (%3.1f - %3.1f)',...
					pp.(obj.pointEstimateType)*100,...
					pp.HDI(1)*100,...
					pp.HDI(2)*100);

				obj.plotFuncs.participantFigFunc(participantSamples,...
					obj.pointEstimateType,...
					'pData', pData,...
					'opts',opts,...
					'goodnessStr',goodnessStr);
				% ~~~~~~~~~~~~~~~~~~~~~~~~~~~

				latex_fig(16, 18, 4)
				% 				myExport(obj.data.IDname{n},...
				% 					'saveFolder', obj.saveFolder,...
				% 					'prefix', obj.modelType);
				myExport('fig',...
					'saveFolder', obj.saveFolder,...
					'prefix', obj.data.IDname{n},...
					'suffix', obj.modelType);
				close(fh)
			end

			function participantTriPlot()
				figure(87)

				% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
				participantSamples = obj.mcmc.getSamplesFromParticipantAsMatrix(n, pVariableNames);
				priorSamples = obj.mcmc.getSamplesAsMatrix(obj.varList.participantLevelPriors);

				mcmc.TriPlotSamples(participantSamples,...
					pVariableNames,...
					'PRIOR',priorSamples,...
					'pointEstimateType',obj.pointEstimateType);
				% ~~~~~~~~~~~~~~~~~~~~~~~~~~~

				myExport('triplot',...
					'saveFolder', obj.saveFolder,...
					'prefix', obj.data.IDname{n},...
					'suffix', obj.modelType);

				% 				myExport([obj.data.IDname{n} '-triplot'],...
				% 					'saveFolder', obj.saveFolder,...
				% 					'prefix', obj.modelType);
			end



			%% SUMMARY PLOTS
			switch obj.discountFuncType
				case{'me'} % code smell
					% MC cluster plot
					probMass = 0.5; % <-- 50% prob mass to avoid too much clutter on graph
					% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
					figure(12)
					plotMCclusters(obj.mcmc,...
						obj.data, [1 0 0],...
						probMass,...
						obj.pointEstimateType)
					% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
					myExport('MC_summary',...
						'saveFolder', obj.saveFolder,...
						'prefix', obj.modelType)

				case{'logk'}
					% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
					figure(12)
					plotLOGKclusters(obj.mcmc, obj.data, [1 0 0], obj.pointEstimateType)
					% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
					myExport('LOGK_summary',...
						'saveFolder', obj.saveFolder,...
						'prefix', obj.modelType)
			end

		end


	end

end
