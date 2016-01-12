classdef ModelBaseClass < handle
	%ModelBaseClass Base class to provide basic functionality
	%	xxxx

	properties (Access = public)
		modelType % string
		data % handle to Data class
		sampler % handle to Sampler class
		monitorparams
		variables % array of variables
		varList
		saveFolder
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

		function conductInference(obj)
			obj.sampler.conductInference()
		end

		function setObservedValues(obj)
			% the model is changing sampler information
			obj.sampler.observed = obj.data.observedData;
			obj.sampler.observed.nParticipants	= obj.data.nParticipants;
			obj.sampler.observed.totalTrials	= obj.data.totalTrials;
		end

		function plotMCMCchains(obj)
			% TODO: refactor this. Maybe all variables just get passed to 
			% MCMCdiagnoticsPlot(). In which case this method can be
			% removed and called directly from whatever calls this method.
			
			% select just those with analysisFlag == true
			str			= {obj.variables.str};
			str			= str([obj.variables.plotMCMCchainFlag]==true);
			bounds		= {obj.variables.bounds};
			bounds		= bounds([obj.variables.plotMCMCchainFlag]==true);
			str_latex	= {obj.variables.str_latex};
			str_latex	= str_latex([obj.variables.plotMCMCchainFlag]==true);

			MCMCdiagnoticsPlot(obj.sampler.getAllSamples(),...
				obj.sampler.getAllStats(),...
				[],...
				str,...
				bounds,...
				str_latex);
		end

		function setMonitoredValues(obj)
			% TODO: move this method to Sampler base class?
			% currently just monitors ALL variables
			obj.monitorparams = {obj.variables.str};
		end

		function exportParameterEstimates(obj)
			
			% grab variable names for participant level
			varNames = {obj.variables.str};
			varNames = varNames( [obj.variables.analysisFlag]==1 );
			
			% Create list of column labels
			colHeader = {};
			for n=1:numel(varNames)
				colHeader{end+1} = sprintf('%s_mean', varNames{n});
				colHeader{end+1} = sprintf('%s_HDI5', varNames{n});
				colHeader{end+1} = sprintf('%s_HDI95', varNames{n});
			end
			
			% create table for participant params
			varNames = {obj.variables.str};
			varNames = varNames( [obj.variables.analysisFlag]==1 );
			paramEstimates = obj.grabParamEstimates(obj.sampler, varNames);
			paramEstimateTable = array2table(paramEstimates,...
				'VariableNames',colHeader,...
				'RowNames', obj.data.IDname);

			%% create table for group-level params, if there are any
			if sum([obj.variables.analysisFlag]==2)>0
				% grab variable names for group level
				varNames = {obj.variables.str};
				varNames = varNames( [obj.variables.analysisFlag]==2 );
				% create table for group level params
				paramEstimates = obj.grabParamEstimates(obj.sampler, varNames);
				group_level = array2table(paramEstimates,...
					'VariableNames',colHeader,...
					'RowNames', {'GroupLevelInference'});
				paramEstimateTable = [paramEstimateTable ; group_level];
			end

			%% display to command window
			paramEstimateTable

			%% Export
			savename = fullfile('figs', obj.saveFolder, 'parameterEstimates.txt');
			writetable(paramEstimateTable, savename,...
				'Delimiter','\t')
			fprintf('The above table of parameter estimates was exported to:\n')
			fprintf('\t%s\n\n',savename)
		end
		
		function data = grabParamEstimates(obj, sampler, varNames)
			data=[];
			for n=1:numel(varNames)
				data = [data sampler.getStats('mean',varNames{n})];
				data = [data sampler.getStats('hdi_low',varNames{n})];
				data = [data sampler.getStats('hdi_high',varNames{n})];
			end
		end

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


		function setBurnIn(obj, nburnin)
			obj.sampler.setBurnIn(nburnin)
		end
		function setMCMCtotalSamples(obj, totalSamples)
			obj.sampler.setMCMCtotalSamples(totalSamples)
		end
		function setMCMCnumberOfChains(obj, nchains)
			obj.sampler.setMCMCnumberOfChains(nchains)
		end

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

		function figParticiantTriPlot(obj,n, variables, participant_prior_variables)
			posteriorSamples = obj.sampler.getSamplesFromParticipantAsMatrix(n, variables);
			priorSamples = obj.sampler.getSamplesAsMatrix(participant_prior_variables);
			figure(87)
			triPlotSamples(posteriorSamples, priorSamples, variables, [])
		end

	end


	methods (Access = protected)

		function figParticipantLevelWrapper(obj, variables, participant_prior_variables)
			% For each participant, call some plotting functions on the variables provided.

			mMEAN = obj.sampler.getStats('mean', 'm');
			cMEAN = obj.sampler.getStats('mean', 'c');
			epsilonMEAN = obj.sampler.getStats('mean', 'epsilon');
			alphaMEAN = obj.sampler.getStats('mean', 'alpha');
			
			for n = 1:obj.data.nParticipants
				fh = figure;
				fh.Name=['participant: ' obj.data.IDname{n}];

				% 1) figParticipant plot
				[pSamples] = obj.sampler.getSamplesAtIndex(n, variables);
				[pData] = obj.data.getParticipantData(n);
				obj.figParticipant(pSamples, pData, mMEAN(n), cMEAN(n), epsilonMEAN(n), alphaMEAN(n))
				latex_fig(16, 18, 4)
				myExport(obj.saveFolder, obj.modelType, ['-' obj.data.IDname{n}])
				close(fh)

				% 2) Triplot
				obj.figParticiantTriPlot(n, variables, participant_prior_variables)
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

		
		function figUnivariateSummary(obj, participantIDlist, variables)
			% loop over variables provided, plotting univariate summary
			% statistics.
			figure
			for v = 1:numel(variables)
				subplot(numel(variables),1,v)
				hdi = [obj.sampler.getStats('hdi_low',variables{v})';...
					obj.sampler.getStats('hdi_high',variables{v})'];
				plotErrorBars({participantIDlist{:}},...
					obj.sampler.getStats('mean',variables{v}),...
					hdi,...
					variables{v});
				a=axis; axis([0.5 a(2)+0.5 a(3) a(4)]);
			end
		end
		
	end

end
