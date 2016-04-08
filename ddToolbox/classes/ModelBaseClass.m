classdef ModelBaseClass < handle
	%ModelBaseClass Base class to provide basic functionality
	%	xxxx

	properties (Access = public)
		modelType % string
		data % handle to Data class
		sampler % handle to Sampler class
		variables % array of variables
		varList
		saveFolder
		mcmc % handle to mcmc fit object
	end

	methods(Abstract, Access = public)
		plot(obj, data)
	end

	methods (Access = public)

		% CONSTRUCTOR =====================================================
		function obj = ModelBaseClass(toolboxPath, sampler, data, saveFolder)
			obj.data = data;
			obj.saveFolder = saveFolder;
		end
		% =================================================================

		% middle-man
		function conductInference(obj)
			obj.mcmc = obj.sampler.conductInference( obj , obj.data );
		end

% 		function plotMCMCchains(obj)
% 			% TODO: refactor this. Maybe all variables just get passed to
% 			% MCMCdiagnoticsPlot(). In which case this method can be
% 			% removed and called directly from whatever calls this method.
%
% 			% select just those with analysisFlag == true
% 			str			= {obj.variables.str};
% 			str			= str([obj.variables.plotMCMCchainFlag]==true);
% 			bounds		= {obj.variables.bounds};
% 			bounds		= bounds([obj.variables.plotMCMCchainFlag]==true);
% 			str_latex	= {obj.variables.str_latex};
% 			str_latex	= str_latex([obj.variables.plotMCMCchainFlag]==true);
%
% 			MCMCdiagnoticsPlot(obj.mcmc.getAllSamples(),...
% 				obj.mcmc.getAllStats(),...
% 				[],...
% 				str,...
% 				bounds,...
% 				str_latex);
% 		end

		% middle-man
		function setBurnIn(obj, nburnin)
			obj.sampler.setBurnIn(nburnin)
		end
		function setMCMCtotalSamples(obj, totalSamples)
			obj.sampler.setMCMCtotalSamples(totalSamples)
		end
		function setMCMCnumberOfChains(obj, nchains)
			obj.sampler.setMCMCnumberOfChains(nchains)
		end
		function plotMCMCchains(obj,vars)
			obj.mcmc.plotMCMCchains(vars);
		end


		% ===============================================================
		% IS THIS OBJECT WANTING TO BE IN THE NEW MCMC-CONTAINER CLASS ??
		function exportParameterEstimates(obj)

			%% participant level
			LEVEL = 1;
			varNames = obj.extractLevelNVarNames(LEVEL);
			colHeaderNames = obj.createColumnHeaders(varNames);
			paramEstimates = obj.grabParamEstimates(obj.mcmc, varNames);
			paramEstimateTable = array2table(paramEstimates,...
				'VariableNames',colHeaderNames,...
				'RowNames', obj.data.IDname);

			%% group level
			if sum([obj.variables.analysisFlag]==2)>0
				LEVEL = 2;
				varNames = obj.extractLevelNVarNames(LEVEL);
				%colHeaderNames = obj.createColumnHeaders(varNames);
				paramEstimates = obj.grabParamEstimates(obj.mcmc, varNames);
				group_level = array2table(paramEstimates,...
					'VariableNames',colHeaderNames,...
					'RowNames', {'GroupLevelInference'});
				paramEstimateTable = [paramEstimateTable ; group_level];
			end

			%% display to command window
			paramEstimateTable

			%% Export
			savename = fullfile('figs', obj.saveFolder, 'parameterEstimates.txt');
			writetable(paramEstimateTable, savename,...
				'Delimiter','\t',...
				'WriteRowNames',true)
			fprintf('The above table of parameter estimates was exported to:\n')
			fprintf('\t%s\n\n',savename)

		end

		function colHeaderNames = createColumnHeaders(obj, varNames)
			colHeaderNames = {};
			for n=1:numel(varNames)
				colHeaderNames{end+1} = sprintf('%s_mean', varNames{n});
				colHeaderNames{end+1} = sprintf('%s_HDI5', varNames{n});
				colHeaderNames{end+1} = sprintf('%s_HDI95', varNames{n});
			end
		end

		function varNames = extractLevelNVarNames(obj, N)
			varNames = {obj.variables.str};
			varNames = varNames( [obj.variables.analysisFlag]==N );
		end

		function data = grabParamEstimates(obj, mcmc, varNames)
			data=[];
			for n=1:numel(varNames)
				data = [data mcmc.getStats('mean',varNames{n})];
				data = [data mcmc.getStats('hdi_low',varNames{n})];
				data = [data mcmc.getStats('hdi_high',varNames{n})];
			end
		end




		% ===============================================================
		% WHERE SHOULD THESE FUNCTIONS LIVE?

		function conditionalDiscountRates(obj, reward, plotFlag)
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

		function conditionalDiscountRates_ParticipantLevel(obj, reward, plotFlag)
			nParticipants = obj.data.nParticipants;
			count=1;
			for p = 1:nParticipants
				params(:,1) = obj.sampler.getSamplesFromParticipantAsMatrix(p, {'m'});
				params(:,2) = obj.sampler.getSamplesFromParticipantAsMatrix(p, {'c'});
				% ==============================================
				[posteriorMean(count), lh(count)] =...
					calculateLogK_ConditionOnReward(reward, params, plotFlag);
				%lh(count).DisplayName=sprintf('participant %d', p);
				%row(count) = {sprintf('participant %d', p)};
				% ==============================================
				count=count+1;
			end
			warning('GET THESE NUMBERS PRINTED TO SCREEN')
			% 			logkCondition = array2table([posteriorMode'],...
			% 				'VariableNames',{'logK_posteriorMode'},...)
			% 				'RowNames', num2cell([1:nParticipants]) )
		end

















		% **********************************************************************
		% PLOTTING *************************************************************
		% **********************************************************************



		function posteriorPredictive(obj)
			%% Calculation
			% Calculate log posterior odds of data under the model and a
			% control model where prob of responding is 0.5.
			prob = @(responses, predicted) prod(binopdf(responses, ...
				ones(size(responses)),...
				predicted));
			nParticipants = obj.data.nParticipants;
			for p=1:nParticipants
				participantResponses = obj.data.participantLevel(p).data.R;% <-- replace with a get method
				participant(p).predicted = obj.sampler.getParticipantPredictedResponses(p);
				pModel = prob(participantResponses, participant(p).predicted');
				controlPredictions = ones(size(participantResponses)) .* 0.5;
				pRandom = prob(participantResponses, controlPredictions);
				logSomething(p) = log( pModel ./ pRandom);
			end
			%% Plotting
			figure(77), clf, colormap(gray)
			for p=1:nParticipants
				subplot(nParticipants,1,p)
				% plot predicted probability of choosing delayed
				bar(participant(p).predicted,'BarWidth',1)
				if p<nParticipants, set(gca,'XTick',[]), end
				box off
				% plot response data
				hold on
				plot([1:obj.data.participantLevel(p).trialsForThisParticant],... % <-- replace with a get method
					obj.data.participantLevel(p).data.R,... % <-- replace with a get method
					'o')
				addTextToFigure('TR',...
					sprintf('%s: %3.2f\n', obj.data.IDname{p}, logSomething(p)),...
					10);
			end
			xlabel('trials')
		end

		% just a middle-man method. Should we remove?
		function figTriPlot(obj, variables, priorSamples, posteriorSamples)
			%posteriorSamples = obj.mcmc.getSamplesFromParticipantAsMatrix(n, variables);
			%priorSamples = obj.mcmc.getSamplesAsMatrix(participant_prior_variables);
			figure(87)
			triPlotSamples(...
				priorSamples,...
				posteriorSamples,...
				variables, [])
		end

		function plotPsychometricParams(obj)
			% Plot priors/posteriors for parameters related to the psychometric
			% function, ie how response 'errors' are characterised
			%
			% plotPsychometricParams(hModel.mcmc.samples)

			figure(7), clf
			P=obj.data.nParticipants;
			%====================================
			subplot(3,2,1)
			plotPriorPostHist(...
				obj.mcmc.getSamplesAsMatrix({'alpha_group_prior'}),...
				obj.mcmc.getSamplesAsMatrix({'alpha_group'}));
			title('Group \alpha')

			subplot(3,4,5)
			plotPriorPostHist(...
				obj.mcmc.getSamplesAsMatrix({'groupALPHAmuprior'}),...
				obj.mcmc.getSamplesAsMatrix({'groupALPHAmu'}));
			xlabel('\mu_\alpha')

			subplot(3,4,6)
			plotPriorPostHist(...
				obj.mcmc.getSamplesAsMatrix({'groupALPHAsigmaprior'}),...
				obj.mcmc.getSamplesAsMatrix({'groupALPHAsigma'}));
			xlabel('\sigma_\alpha')

			subplot(3,2,5),
			for p=1:P-1 % plot participant level alpha (alpha(:,:,p))
				%histogram(vec(samples.alpha(:,:,p)));
				[F,XI]=ksdensity(...
					obj.mcmc.getSamplesFromParticipantAsMatrix(p,{'alpha'}),... %vec(samples.alpha(:,:,p)),...
					'support','positive',...
					'function','pdf');
				plot(XI, F)
				hold on
			end
			xlabel('\alpha_p')
			box off

			%====================================
			subplot(3,2,2)
			plotPriorPostHist(...
				obj.mcmc.getSamplesAsMatrix({'epsilon_group_prior'}),...
				obj.mcmc.getSamplesAsMatrix({'epsilon_group'}));
			title('Group \epsilon')

			subplot(3,4,7),
			plotPriorPostHist(...
				obj.mcmc.getSamplesAsMatrix({'groupWprior'}),...
				obj.mcmc.getSamplesAsMatrix({'groupW'}));
			xlabel('\omega (mode)')

			subplot(3,4,8),
			plotPriorPostHist(...
				obj.mcmc.getSamplesAsMatrix({'groupKprior'}),...
				obj.mcmc.getSamplesAsMatrix({'groupK'}));
			xlabel('\kappa (concentration)')

			subplot(3,2,6),
			for p=1:P-1 % plot participant level alpha (alpha(:,:,p))
				%histogram(vec(samples.epsilon(:,:,p)));
				[F,XI]=ksdensity(...
					obj.mcmc.getSamplesFromParticipantAsMatrix(p,{'epsilon'}),... % vec(samples.epsilon(:,:,p)),...
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

		function figParticipantLevelWrapper(obj, variables, participant_prior_variables)
			% For each participant, call some plotting functions on the variables provided.

			mMEAN = obj.mcmc.getStats('mean', 'm');
			cMEAN = obj.mcmc.getStats('mean', 'c');
			epsilonMEAN = obj.mcmc.getStats('mean', 'epsilon');
			alphaMEAN = obj.mcmc.getStats('mean', 'alpha');

			for n = 1:obj.data.nParticipants
				fh = figure;
				fh.Name=['participant: ' obj.data.IDname{n}];

				% 1) figParticipant plot
				[pSamples] = obj.mcmc.getSamplesAtIndex(n, variables);
				[pData] = obj.data.getParticipantData(n);
				obj.figParticipant(pSamples, pData, mMEAN(n), cMEAN(n), epsilonMEAN(n), alphaMEAN(n))
				latex_fig(16, 18, 4)
				myExport(obj.saveFolder, obj.modelType, ['-' obj.data.IDname{n}])
				close(fh)

				% 2) Triplot
				posteriorSamples = obj.mcmc.getSamplesFromParticipantAsMatrix(n, variables);
				priorSamples = obj.mcmc.getSamplesAsMatrix(participant_prior_variables);

				obj.figTriPlot(variables, priorSamples, posteriorSamples)

				myExport(obj.saveFolder, obj.modelType, ['-' obj.data.IDname{n} '-triplot'])
			end
		end

		function figParticipant(obj, pSamples, pData, mMEAN, cMEAN, epsilonMEAN, alphaMEAN)
			rows=1; cols=5;

			% BIVARIATE PLOT: lapse rate & comparison accuity
			subplot(rows, cols, 1)
			plot2DErrorAccuity(pSamples.epsilon(:), pSamples.alpha(:), epsilonMEAN, alphaMEAN);

			% PSYCHOMETRIC FUNCTION (using my posterior-prediction-plot-matlab GitHub repository)
			subplot(rows, cols, 2)
			plotPsychometricFunc(pSamples, [epsilonMEAN, alphaMEAN])

			% M/C bivariate plot
			subplot(rows, cols, 3)
			plot2Dmc(pSamples.m(:), pSamples.c(:), mMEAN, cMEAN);

			% PLOT magnitude effect
			subplot(rows, cols, 4)
			plotMagnitudeEffect(pSamples, [mMEAN, cMEAN])

			% Plot in 3D data space
			subplot(rows, cols, 5)
			if ~isempty(pData)
				plot3DdataSpace(pData, [mMEAN, cMEAN])
			else
				opts.maxlogB	= max(abs(obj.data.observedData.B(:)));
				opts.maxD		= max(obj.data.observedData.DB(:));
				plotDiscountSurface(mMEAN, cMEAN, opts);
			end
			% 			set(gca,'XTick',[10 100])
			% 			set(gca,'XTickLabel',[10 100])
			% 			set(gca,'XLim',[10 100])
		end

	end

end
