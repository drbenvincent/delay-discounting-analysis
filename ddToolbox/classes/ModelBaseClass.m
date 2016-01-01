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

	properties (GetAccess = public, SetAccess = protected)
		analyses % struct
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

			MCMCdiagnoticsPlot(obj.sampler.samples, obj.sampler.stats,...
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
				% non-participant level
				for v = 1:numel(obj.variables)
					if isempty(obj.variables(v).seed), continue, end
					if obj.variables(v).seed.single==false, continue, end

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

		function doAnalysis(obj)
			str = {obj.variables.str};
			bounds = {obj.variables.bounds};
			% select just those with analysisFlag~=0
			str = str([obj.variables.analysisFlag]~=0);
			bounds = bounds([obj.variables.analysisFlag]~=0);

			obj.analyses.univariate  = univariateAnalysis(...
				obj.sampler.samples,...
				str,...
				bounds);
		end

		function exportParameterEstimates(obj)
			% Loop over all fields in obj.analyses.univariate and display the mode and CI95. Put into a table and export.

			varNames = {obj.variables.str};
			varNames = varNames( [obj.variables.analysisFlag]==1 );

			data=[];
			colHeader = {};
			for n=1:numel(varNames)
				data = [data obj.analyses.univariate.(varNames{n}).mode'];
				data = [data obj.analyses.univariate.(varNames{n}).CI95'];

				colHeader{end+1} = sprintf('%s_mode', varNames{n});
				colHeader{end+1} = sprintf('%s_CI5', varNames{n});
				colHeader{end+1} = sprintf('%s_CI95', varNames{n});
			end

			param_estimates = array2table(data,...
				'VariableNames',colHeader,...
				'RowNames', obj.data.IDname);

			% display to command window
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
				samples.m = vec(obj.sampler.samples.m(:,:,p));
				samples.c = vec(obj.sampler.samples.c(:,:,p));
				params(:,1) = samples.m(:);
				params(:,2) = samples.c(:);
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
			samples = obj.sampler.samples.Rpostpred;

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

		function figParticiantTriPlot(obj,n, variables)
			% samples from posterior

			samples = obj.sampler.getSamplesFromParticipantAsMatrix(n, variables);
			% temp = obj.sampler.getSamplesAtIndex(n, variables);
			% % TODO *** SORT THIS OUT. DO THIS IN A METHODS IN JAGSSampler object???
			% fieldList = fields(temp);
			% samples = [];
			% for f=1:numel(fieldList)
			% 	samples = [ samples temp.(fieldList{f})];
			% end
			% **********************************************

			% *** DON'T DELETE ***
			% samples from prior
			%temp = obj.sampler.getSamplesAtIndex(n, {'mprior', 'cprior','alphaprior','epsilonprior'});
			% 			priorSamples= [obj.sampler.samples.mprior(:),...
			% 				obj.sampler.samples.cprior(:),...
			% 				obj.sampler.samples.alphaprior(:),...
			% 				obj.sampler.samples.epsilonprior(:)];
			figure(87)
			if isfield(obj.sampler.samples,'glMprior')
				priorSamples= [obj.sampler.samples.glMprior(:),...
					obj.sampler.samples.glCprior(:),...
					obj.sampler.samples.glALPHAprior(:),...
					obj.sampler.samples.glEpsilonprior(:)];
				triPlotSamples(samples, priorSamples, variables, [])
			else
				triPlotSamples(samples, [], variables, [])
			end
		end

	end


	methods (Access = protected)

		function figParticipantLevelWrapper(obj, variables)
			% For each participant, call some plotting functions on the variables provided.

			for n = 1:obj.data.nParticipants
				fh = figure;
				fh.Name=['participant: ' obj.data.IDname{n}];

				% 1) figParticipant plot
				% get samples and data for this participant
				[pSamples] = obj.sampler.getSamplesAtIndex(n, variables);
				[pData] = obj.data.getParticipantData(n);
				obj.figParticipant(pSamples, pData)
				latex_fig(16, 18, 4)
				myExport(obj.saveFolder, obj.modelType, ['-' obj.data.IDname{n}])
				close(fh)

				% 2) Triplot
				obj.figParticiantTriPlot(n, variables)
				myExport(obj.saveFolder, obj.modelType, ['-' obj.data.IDname{n} '-triplot'])
			end
		end

		function figParticipant(obj, pSamples, pData)
			rows=1; cols=5;

			% BIVARIATE PLOT: lapse rate & comparison accuity
			subplot(rows, cols, 1)
			[structName] = plot2DErrorAccuity(pSamples.epsilon(:),...
				pSamples.alpha(:));
			lrMODE = structName.modex;
			alphaMODE= structName.modey;

			% PSYCHOMETRIC FUNCTION (using my posterior-prediction-plot-matlab GitHub repository)
			subplot(rows, cols, 2)
			plotPsychometricFunc(pSamples, [lrMODE, alphaMODE])

			% M/C bivariate plot
			subplot(rows, cols, 3)
			[structName] = plot2Dmc(pSamples.m(:), pSamples.c(:));
			modeM = structName.modex;
			modeC = structName.modey;

			% PLOT magnitude effect
			subplot(rows, cols, 4)
			plotMagnitudeEffect(pSamples, [modeM, modeC])

			% Plot in 3D data space
			subplot(rows, cols, 5)
			if ~isempty(pData)
				plot3DdataSpace(pData, [modeM, modeC])
			else
				warning('PLOT SURFACE HERE')
				opts.maxlogB	= max(abs(obj.data.observedData.B(:)));
				opts.maxD		= max(obj.data.observedData.DB(:));
				plotDiscountSurface(modeM, modeC, opts);
			end
			% 			set(gca,'XTick',[10 100])
			% 			set(gca,'XTickLabel',[10 100])
			% 			set(gca,'XLim',[10 100])
		end

	end


	methods (Static)

		function figUnivariateSummary(uni, participantIDlist, variables)
			% loop over variables provided, plotting univariate summary
			% statistics.
			figure
			for v = 1:numel(variables)
				subplot(numel(variables),1,v)
				plotErrorBars({participantIDlist{:}},...
					[uni.(variables{v}).mode], [uni.(variables{v}).CI95],...
					variables{v});
				a=axis; axis([0.5 a(2)+0.5 a(3) a(4)]);
			end
		end

	end

end
