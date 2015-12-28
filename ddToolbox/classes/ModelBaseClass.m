classdef ModelBaseClass < handle
	%ModelBaseClass Base class to provide basic functionality
	%	xxxx

	properties (Access = public)
		modelType % string
		data % handle to Data class
		sampler % handle to Sampler class
		range % struct
		monitorparams
	end

	properties (GetAccess = public, SetAccess = protected)
		analyses % struct
	end

	methods(Abstract, Access = public)
		plot(obj, data)
		doAnalysis(obj) % <--- TODO: REMOVE THIS WRAPPER FUNCTION
		setMonitoredValues(obj, data)
		setObservedValues(obj, data)
		setInitialParamValues(obj, data)
	end

	methods (Access = public)

		% CONSTRUCTOR =====================================================
		function obj = ModelBaseClass(toolboxPath, sampler, data)
			obj.data = data;
		end
		% =================================================================

		function conductInference(obj)
			obj.sampler.conductInference()
		end

		function calcSampleRange(obj)
			% Define limits for each of the variables here for plotting purposes
			obj.range.epsilon = [0 0.5]; % show full range
			obj.range.alpha = [0 prctile(obj.sampler.samples.alpha(:), [99])];
			obj.range.m = prctile(obj.sampler.samples.m(:), [0.5 99.5]);
			obj.range.c = prctile(obj.sampler.samples.c(:), [1 99]);
		end

		% **************************************************************************************************
		% TODO: THIS FUNCTION CAN BE GENERALISED TO LOOP OVER WHATEVER FIELDS ARE IN obj.analyses.univariate
		% **************************************************************************************************
		function exportParameterEstimates(obj)
			participant_level = array2table(...
				[obj.analyses.univariate.m.mode'...
				obj.analyses.univariate.m.CI95'...
				obj.analyses.univariate.c.mode'...
				obj.analyses.univariate.c.CI95'...
				obj.analyses.univariate.alpha.mode'...
				obj.analyses.univariate.alpha.CI95'...
				obj.analyses.univariate.epsilon.mode'...
				obj.analyses.univariate.epsilon.CI95'],...
				'VariableNames',{'m_mode' 'm_CI5' 'm_CI95'...
				'c_mode' 'c_CI5' 'c_CI95'...
				'alpha_mode' 'alpha_CI5' 'alpha_CI95'...
				'epsilon_mode' 'epsilon_CI5' 'epsilon_CI95'},...
				'RowNames', obj.data.participantFilenames)

			savename = ['parameterEstimates_' obj.data.saveName '.txt'];
			writetable(participant_level, savename,...
				'Delimiter','\t')
			fprintf('The above table of participant-level parameter estimates was exported to:\n')
			fprintf('\t%s\n\n',savename)
		end

		function conditionalDiscountRates(obj, reward, plotFlag)
			% Extract and plot P( log(k) | reward)
			warning('THIS METHOD IS A TOTAL MESS - PLAN THIS AGAIN FROM SCRATCH')
			obj.conditionalDiscountRates_ParticipantLevel(reward, plotFlag)
			%conditionalDiscountRates_GroupLevel(reward, plotFlag)
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


	end

	methods (Access = protected)

		function figParticipantLevelWrapper(obj)
			% PLOT INDIVIDUAL LEVEL STUFF HERE ----------
			for n = 1:obj.data.nParticipants
				fh = figure;
				fh.Name=['participant: ' obj.data.IDname{n}];

				% get samples and data for this participant
				[pSamples] = obj.sampler.getSamplesAtIndex(n, {'m','c','alpha','epsilon'});
				[pData] = obj.data.getParticipantData(n);

				% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				obj.figParticipant(pSamples, pData)
				% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				latex_fig(16, 18, 4)
				myExport(obj.data.saveName, obj.modelType, ['-' obj.data.IDname{n}])

				% close the figure to keep everything tidy
				close(fh)


				% ALSO DO TRI-PLOT
				obj.figParticiantTriPlot(n)
				myExport(obj.data.saveName, obj.modelType, ['-' obj.data.IDname{n} '-triplot'])
			end
		end

		function figParticipant(obj, pSamples, pData)
			rows=1; cols=5;

			% BIVARIATE PLOT: lapse rate & comparison accuity
			subplot(rows, cols, 1)
			[structName] = plot2DErrorAccuity(pSamples.epsilon(:),...
				pSamples.alpha(:),...
				obj.range.epsilon,...
				obj.range.alpha);
			lrMODE = structName.modex;
			alphaMODE= structName.modey;

			% PSYCHOMETRIC FUNCTION (using my posterior-prediction-plot-matlab GitHub repository)
			subplot(rows, cols, 2)
			plotPsychometricFunc(pSamples, [lrMODE, alphaMODE])

			% M/C bivariate plot
			subplot(rows, cols, 3)
			[structName] = plot2Dmc(pSamples.m(:), pSamples.c(:),...
				obj.range.m, obj.range.c);
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

end
