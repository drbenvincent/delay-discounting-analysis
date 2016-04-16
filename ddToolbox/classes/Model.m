classdef Model < handle
	%Model Base class to provide basic functionality
	%	xxxx

	properties (Access = public)
		modelType % string
		data % handle to Data class
		sampler % handle to Sampler class
		variables % array of variables
		varList
		saveFolder
		mcmc % handle to mcmc fit object
		plotFuncs % structure of function handles
		discountFuncType
	end

	methods(Abstract, Access = public)
	end

	methods (Access = public)

		function obj = Model(toolboxPath, sampler, data, saveFolder)
			obj.data = data;
			obj.saveFolder = saveFolder;
		end

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
			bool = isfield(obj.varList,'groupLevel');
		end

		% MIDDLE-MAN METHODS ================================================

		function conductInference(obj)
			obj.mcmc = obj.sampler.conductInference( obj , obj.data );
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

		function plotMCMCchains(obj,vars)
			obj.mcmc.plotMCMCchains(vars);
		end

		function exportParameterEstimates(obj, varargin)
			obj.mcmc.exportParameterEstimates(...
				obj.extractLevelNVarNames(1),... % Participant-level
				obj.extractLevelNVarNames(2),...  % group-level)
				obj.data.IDname,...
				obj.saveFolder,...
				varargin)
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

















		% **********************************************************************
		% PLOTTING *************************************************************
		% **********************************************************************




		function plot(obj)
			close all

			% TODO: THIS IS A COMPLETE MESS

			% IDEAS:
			% - Loop over participants (and group if there is one) and create an array of objects of a new participant class. This class will contain all the data for that person, as well as the plotting functions.
			%
			% - Or....

			if obj.isGroupLevelModel()
				IDnames = obj.data.IDname;
				% We are going to add on group level inferences to the end of the
				% list. This is because the group-level inferences an be
				% seen as inferences we can make about an as yet unobserved
				% participant, in the light of the participant data available thus
				% far.
				IDnames{end+1}='GROUP';
			else
				IDnames = obj.data.IDname;
			end

			% plot univariate summary statistics ---------------------------------
			obj.mcmc.figUnivariateSummary(IDnames, obj.varList.participantLevel)
			latex_fig(16, 5, 5)
			myExport('UnivariateSummary',...
				'saveFolder',obj.saveFolder,...
				'prefix', obj.modelType)
			% --------------------------------------------------------------------

			%% PARTICIPANT LEVEL

			if obj.isGroupLevelModel()
				participant_level_prior_variables = cellfun(...
					@getPriorOfVariable,...
					obj.varList.groupLevel,...
					'UniformOutput',false );
			else
				participant_level_prior_variables = cellfun(...
					@getPriorOfVariable,...
					obj.varList.participantLevel,...
					'UniformOutput',false );
			end

			% TODO ??????????????????
			opts.maxlogB	= max(abs(obj.data.observedData.B(:)));
			opts.maxD		= max(obj.data.observedData.DB(:));
			% ??????????????????

			% plot wrapper -------------------------------------------------------
			figParticipantLevelWrapper(...
				obj.mcmc,...
				obj.data,...
				obj.varList.participantLevel,...
				participant_level_prior_variables,...
				obj.saveFolder,...
				obj.modelType,...
				opts,...
				obj.plotFuncs.participantFigFunc)
			% --------------------------------------------------------------------

			%% GROUP LEVEL ======================================
			if obj.isGroupLevelModel()
				group_level_prior_variables = cellfun(...
					@getPriorOfVariable,...
					obj.varList.groupLevel,...
					'UniformOutput',false );

				% PSYCHOMETRIC PARAMS ----------------------------------------------
				figPsychometricParamsHierarchical(obj.mcmc, obj.data)
				myExport('PsychometricParams',...
					'saveFolder', obj.saveFolder,...
					'prefix', obj.modelType)
				% ------------------------------------------------------------------


				posteriorSamples = obj.mcmc.getSamplesAsMatrix(obj.varList.groupLevel);
				priorSamples = obj.mcmc.getSamplesAsMatrix(group_level_prior_variables);
				% TRIPLOT ----------------------------------------------------------
				figure(87)
				TriPlotSamples(posteriorSamples, obj.varList.groupLevel, 'PRIOR', priorSamples);
				myExport('GROUP-triplot',...
					'saveFolder', obj.saveFolder,...
					'prefix', obj.modelType)
				% ------------------------------------------------------------------


				% GROUP (UNSEEN PARTICIPANT) PLOT

				% strip the '_group' off of variablenames
				for n=1:numel(obj.varList.groupLevel)
					temp=regexp(obj.varList.groupLevel{n},'_','split');
					groupLevelVarName{n} = temp{1};
				end
				% get point estimates. TODO: this can be a specific method in mcmc.
				for n=1:numel(obj.varList.groupLevel)
					pointEstimate.(groupLevelVarName{n}) =...
						obj.mcmc.getStats('mean', obj.varList.groupLevel{n});
				end

				[pSamples] = obj.mcmc.getSamples(obj.varList.groupLevel);
				% flatten
				for n=1:numel(obj.varList.groupLevel)
					pSamples.(obj.varList.groupLevel{n}) = vec(pSamples.(obj.varList.groupLevel{n}));
				end
				% rename
				pSamples = renameFields(...
					pSamples,...
					obj.varList.groupLevel,...
					groupLevelVarName);
				

				% TODO ??????????????????
				opts.maxlogB	= max(abs(obj.data.observedData.B(:)));
				opts.maxD		= max(obj.data.observedData.DB(:));
				% ??????????????????

				% get group level pointEstimates
				pointEstimates = obj.mcmc.getParticipantPointEstimates(1, obj.varList.groupLevel);
				pointEstimates = renameFields(...
					pointEstimates,...
					obj.varList.groupLevel,...
					groupLevelVarName);

				% ------------------------------------------------------------------
				obj.plotFuncs.participantFigFunc(pSamples,...
					pointEstimates,...
					'opts', opts)
				myExport('GROUP',...
					'saveFolder', obj.saveFolder,...
					'prefix', obj.modelType)
				% ------------------------------------------------------------------

			else
				% this model does not have group level params... don't do anything
			end


% 			%% MC CONTOUR PLOTS
% 			probMass = 0.5; % <---- 50% prob mass chosen to avoid too much clutter on graph
% 			plotMCclusters(obj.mcmc, obj.data, [1 0 0], probMass)
		end




		function posteriorPredictive(obj)
			% TODO: SEPARATE CALCULATION AND PLOTTING INTO DIFFERENT FUNCTIONS?

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

	end

end
