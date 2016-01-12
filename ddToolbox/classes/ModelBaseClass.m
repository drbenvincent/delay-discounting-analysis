classdef ModelBaseClass < handle
	%ModelBaseClass Base class to provide basic functionality
	%	xxxx

	properties (Access = public)
		modelType % string
		data % handle to Data class
		sampler % handle to Sampler class
		monitorparams
		variables % array of variables
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
			str				= {obj.variables.str};
			bounds		= {obj.variables.bounds};
			str_latex = {obj.variables.str_latex};
			% select just those with analysisFlag
			str				= str([obj.variables.plotMCMCchainFlag]==true);
			bounds		= bounds([obj.variables.plotMCMCchainFlag]==true);
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

		function setInitialParamValues(obj)
			for chain=1:obj.sampler.mcmcparams.nchains

				% create initial values for some single-value items (ie
				% non-participant level)
				for v = 1:numel(obj.variables)
					if isempty(obj.variables(v).seed), continue, end
					if obj.variables(v).seed.single==false, continue, end

					beep
					varName = obj.variables(v).str;
					obj.sampler.initial_param(chain).(varName) = obj.variables(v).seed.func();
				end

				for p=1:obj.data.nParticipants
					for v = 1:numel(obj.variables)
						if isempty(obj.variables(v).seed), continue, end
						if obj.variables(v).seed.single==true, continue, end

						varName = obj.variables(v).str;
						obj.sampler.initial_param(chain).(varName)(p) = obj.variables(v).seed.func();
					end
				end

			end
		end

		function exportParameterEstimates(obj)
			% Loop over all fields in obj.analyses.univariate and display 
			% the posterior mean and CI95. 
			% Put into a table and export.

			varNames = {obj.variables.str};
			varNames = varNames( [obj.variables.analysisFlag]==1 );

			data=[];
			colHeader = {};
			for n=1:numel(varNames)
				data = [data obj.sampler.getStats('mean',varNames{n})];
				data = [data obj.sampler.getStats('hdi_low',varNames{n})];
				data = [data obj.sampler.getStats('hdi_high',varNames{n})];
				
				colHeader{end+1} = sprintf('%s_mean', varNames{n});
				colHeader{end+1} = sprintf('%s_HDI5', varNames{n});
				colHeader{end+1} = sprintf('%s_HDI95', varNames{n});
			end

			param_estimates = array2table(data,...
				'VariableNames',colHeader,...
				'RowNames', obj.data.IDname);

			%% see if there are any group-level parameters
			if sum([obj.variables.analysisFlag]==2)>0
				% there are group-level parameters
				varNames = {obj.variables.str};
				varNames = varNames( [obj.variables.analysisFlag]==2 );

				data=[];
				% **colHeader** Need to keep the same values so we can append group
				% to participant table.
				for n=1:numel(varNames)
% 					data = [data obj.sampler.stats.mean.(varNames{n})'];
% 					data = [data [obj.sampler.stats.hdi_low.(varNames{n}); obj.sampler.stats.hdi_high.(varNames{n})]' ];
					data = [data obj.sampler.getStats('mean',varNames{n})];
					data = [data obj.sampler.getStats('hdi_low',varNames{n})];
					data = [data obj.sampler.getStats('hdi_high',varNames{n})];
				end

				group_level = array2table(data,...
					'VariableNames',colHeader,...
					'RowNames', {'GroupLevelInference'});

				param_estimates = [param_estimates ; group_level];
			end

			%% display to command window
			param_estimates

			%% Export
			savename = fullfile('figs', obj.saveFolder, 'parameterEstimates.txt');
			writetable(param_estimates, savename,...
				'Delimiter','\t')
			fprintf('The above table of parameter estimates was exported to:\n')
			fprintf('\t%s\n\n',savename)
		end

		function conditionalDiscountRates(obj, reward, plotFlag)
			% Extract and plot P( log(k) | reward)
			warning('THIS METHOD IS A TOTAL MESS - PLAN THIS AGAIN FROM SCRATCH')
			obj.conditionalDiscountRates_ParticipantLevel(reward, plotFlag)

			if plotFlag % FORMATTING OF FIGURE
				removeYaxis
				title(sprintf('$P(\\log(k)|$reward=$\\pounds$%d$)$', reward),'Interpreter','latex')
				xlabel('$\log(k)$','Interpreter','latex')
				axis square
				%legend(lh.DisplayName)
			end
		end

		function conditionalDiscountRates_ParticipantLevel(obj, reward, plotFlag)
			nParticipants = obj.data.nParticipants;
			count=1;
			for p = 1:nParticipants
				params(:,1) = obj.sampler.getSamplesFromParticipantAsMatrix(p, {'m'});
				params(:,2) = obj.sampler.getSamplesFromParticipantAsMatrix(p, {'c'});
				% ==============================================
				[posteriorMode(count), lh(count)] =...
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
			figure(77), clf, colormap(gray)
 			temp = obj.sampler.getSamples({'Rpostpred'});
 			samples = temp.Rpostpred;

			% flatten chains
			s=size(samples);
			samples = reshape(samples, s(1)*s(2), s(3), s(4));
			[nSamples, nParticipants, nTrials] = size(samples);

			for p=1:nParticipants

				%% plot predicted probability of choosing delayed
				participantSamples = squeeze(samples(:,p,:));
				predicted = sum(participantSamples,1)./nSamples;
				subplot(nParticipants,1,p)
				bar(predicted,'BarWidth',1)
				if p<nParticipants
					set(gca,'XTick',[])
				end
				box off

				%% plot actual data
				hold on
				responses = obj.data.participantLevel(p).data.R;
				trialsForThisParticipant = obj.data.participantLevel(p).trialsForThisParticant;
				plot([1:trialsForThisParticipant],...
					responses,'o')

				%addTextToFigure('TR', obj.data.IDname{p}, 10);

				%% Calculate posterior prob of data
				pModel = prod(binopdf(responses, ones(trialsForThisParticipant,1), predicted'));

				random = ones(size(predicted)) .* 0.5;
				pRandom = prod(binopdf(responses, ones(trialsForThisParticipant,1), random'));

				logSomething = log( pModel ./ pRandom);
				info = sprintf('%s: %3.2f\n', obj.data.IDname{p},logSomething)

				addTextToFigure('TR', info, 10);
			end

			xlabel('trials')
		end

		function figParticiantTriPlot(obj,n, variables, participant_prior_variables)
			posteriorSamples = obj.sampler.getSamplesFromParticipantAsMatrix(n, variables);
			
			[priorSamples] = obj.sampler.getSamplesAsMatrix(participant_prior_variables);
			
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
				% get samples and data for this participant
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
				warning('PLOT SURFACE HERE')
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
				plotErrorBars({participantIDlist{:}},...
					obj.sampler.getStats('mean',variables{v}),...
					[obj.sampler.getStats('hdi_low',variables{v})'; obj.sampler.getStats('hdi_high',variables{v})'],...
					variables{v});
				a=axis; axis([0.5 a(2)+0.5 a(3) a(4)]);
			end
		end
		
	end

end
