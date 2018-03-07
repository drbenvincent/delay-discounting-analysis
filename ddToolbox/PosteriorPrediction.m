classdef PosteriorPrediction
	%PosteriorPrediction Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (SetAccess = private, GetAccess = private)
		postPred
		postPredTable
		CREDIBLE_INTERVAL
        controlModelProbChooseDelayed
	end
	
	methods
		
		function obj = PosteriorPrediction(coda, data, observedData, pointEstimateType)
			% Calculate various posterior predictive measures.
			% Data saved to a struture: postPred(p).xxx
			obj.CREDIBLE_INTERVAL = 0.95;
			disp('Calculating posterior predictive measures...')
			
			for p = 1:data.getNRealExperimentFiles()
				% get data
				trialIndOfThisParicipant	= observedData.ID==p;
				responses_inferredPB		= coda.getPChooseDelayed(trialIndOfThisParicipant);
				responses_actual			= data.getParticipantResponses(p);
				responses_predicted			= coda.getParticipantPredictedResponses(trialIndOfThisParicipant);
				obj.postPred(p).proportion_chose_delayed = data.getProportionDelayedOptionsChosen(p);
				
				obj.controlModelProbChooseDelayed(p) = obj.postPred(p).proportion_chose_delayed;
				
				% Calculate metrics
				obj.postPred(p).log_loss_distribution	= obj.calcLogLossDistribution(responses_inferredPB, responses_actual);
				obj.postPred(p).percentPredictedDistribution = obj.calcPercentResponsesCorrectlyPredicted(responses_inferredPB, responses_actual);
				% Store
				obj.postPred(p).responses_actual	= responses_actual;
				obj.postPred(p).responses_predicted = responses_predicted;
				% Store other useful stuff
				obj.postPred(p).IDname = data.getIDnames(p);
			end
			
			obj.postPredTable = obj.makePostPredTable(data, pointEstimateType);
			
		end
		
		function plot(obj, plotOptions, modelFilename, model)
			% loop over all experiments/people, producing plot figures
			N = length(obj.postPred);
			for n = 1:N
				obj.posterior_prediction_figure(n, plotOptions, model)
				
				% Exporting
				prefix_string = obj.postPred(n).IDname{:};
				obj.exportFigure(plotOptions, prefix_string, modelFilename)
			end
		end
		
		% PUBLIC GETTERS --------------------------------------------------
		
		function pp = getPercentPredictedDistribution(obj)
			pp = {obj.postPred(:).percentPredictedDistribution};
		end
		
		function pp = getLogLossDistribution(obj)
			pp = {obj.postPred(:).log_loss_distribution};
		end
		
		function postPredTable = getPostPredTable(obj)
			postPredTable = obj.postPredTable;
		end
		
		
	end
	
	methods (Access = private)
		
		function posterior_prediction_figure(obj, n, plotOptions, plotDiscountFunction)
			% Sort figure
			figure(1), colormap(gray), clf
			latex_fig(16, 9, 6)
			% Arrange subplots
			h = layout([1 4; 2 3]);
			subplot(h(1)), obj.pp_plotTrials(n)
			subplot(h(2)), obj.pp_plotLogLossDistribution(n, plotOptions)
			subplot(h(3)), obj.pp_plotPercentPredictedDistribution(n, plotOptions)
			plotDiscountFunction(n, h(4))
			
			drawnow
		end
		
		function pp_plotLogLossDistribution(obj, n, plotOptions)
			uni = mcmc.UnivariateDistribution(...
				obj.postPred(n).log_loss_distribution(:),...
				'xLabel', 'Log Loss',...
				'plotStyle','hist',...
				'pointEstimateType', plotOptions.pointEstimateType);
		end
		
		function pp_plotPercentPredictedDistribution(obj, n, plotOptions)
			uni = mcmc.UnivariateDistribution(...
				obj.postPred(n).percentPredictedDistribution(:),...
				'xLabel', '$\%$ proportion responses accounted for',...
				'plotStyle','hist',...
				'pointEstimateType', plotOptions.pointEstimateType);
			axis tight
			
			% Control model predict P(choose delayed) = observed proportion
			% of choosing delayed. If we set the decision critieria at 0.5,
			% then if P(choose delayed)>0.5 then it will predict 100% of
			% responses are for delayed option. So the proportion accounted
			% for will be equal to proportion actually chose delayed. But
			% if P(choose delayed)<0.5, then it can correctly predict
			% number of trials equal to the number that actually chose
			% immediate. So...
			controlModelProbChooseDelayed = obj.postPred(n).proportion_chose_delayed;
			controlModelProbChooseImmediate = 1-controlModelProbChooseDelayed;
			proportionAccountedByControl = max([controlModelProbChooseDelayed controlModelProbChooseImmediate]);
			vline(proportionAccountedByControl);
			
			set(gca,'XLim',[0 1])
		end
		
		function pp_plotTrials(obj, n)
			% plot predicted probability of choosing delayed
			bar(obj.postPred(n).responses_predicted, 'BarWidth',1);
			% formatting
			box off
			axis tight
			% plot response data
			hold on
			plot([1:numel(obj.postPred(n).responses_actual)], obj.postPred(n).responses_actual, '+');
			% plot predicted proportion of choosing delayed
			h = hline(obj.postPred(n).proportion_chose_delayed);
			uistack(h.line, 'top')
			% formatting
			xlabel('trial')
			ylabel('response')
			legend('prediction','response','control model',...
				'Location','East')
		end
		
		function postPredTable = makePostPredTable(obj, data, pointEstimateType)
			postPredTable = table(...
				obj.calc_percent_predicted_point_estimate(pointEstimateType),...
				obj.calc_log_loss_point_estimate(pointEstimateType),...
				obj.any_percent_predicted_warnings(),...
				'RowNames', data.getIDnames('experiments'),...
				'VariableNames',{'percentPredicted' 'LogLoss' 'warning_percent_predicted'});
			
			if data.isUnobservedPartipantPresent()
				% add extra row of NaN's on the bottom for the unobserved participant
				unobserved = table(NaN, NaN, NaN,...
					'RowNames', data.getIDnames('group'),...
					'VariableNames', postPredTable.Properties.VariableNames);
				
				postPredTable = [postPredTable; unobserved];
			end
		end
		
		function percentPredicted = calc_percent_predicted_point_estimate(obj, pointEstimateType)
			% Calculate point estimates of perceptPredicted. use the point
			% estimate type that the user specified
			pointEstFunc = str2func(pointEstimateType);
			percentPredicted = cellfun(pointEstFunc,...
				obj.getPercentPredictedDistribution())';
		end
		
		function percentPredicted = calc_log_loss_point_estimate(obj, pointEstimateType)
			% Calculate point estimates of perceptPredicted. use the point
			% estimate type that the user specified
			pointEstFunc = str2func(pointEstimateType);
			percentPredicted = cellfun(pointEstFunc,...
				obj.getLogLossDistribution())';
		end
		
		function pp_warning = any_percent_predicted_warnings(obj)
			% warnings when we have less than 95% confidence that we can
			% predict more responses than the control model
			ppLowerThreshold = obj.controlModelProbChooseDelayed;
			hdiFunc = @(x) HDIofSamples(x, obj.CREDIBLE_INTERVAL);
			warningFunc = @(x,lowerThresh) x(1) < lowerThresh;
			warnOnHDI = @(x,lowerThresh) warningFunc( hdiFunc(x), lowerThresh );
			pp_warning = cellfun( warnOnHDI,...
				obj.getPercentPredictedDistribution(),...
				num2cell(ppLowerThreshold))';
		end
		
	end
	
	methods (Access = private, Static)
		
		function logloss = calcLogLossDistribution(predicted, actual)
			% log loss for binary variables
			logloss = - (sum(actual .* log(predicted) + (1 - actual) ...
				.* log(1 - predicted))) ./ length(actual);
		end
		
		function percentResponsesPredicted = calcPercentResponsesCorrectlyPredicted(responses_predictedMCMC, responses_actual)
			% Calculate % responses predicted by the model
			DECISION_THRESHOLD = 0.5;
			totalSamples				= size(responses_predictedMCMC,2);
			nQuestions					= numel(responses_actual);
			modelPrediction				= zeros(size(responses_predictedMCMC));
			modelPrediction(responses_predictedMCMC>=DECISION_THRESHOLD)=1;
			responses_actual			= repmat(responses_actual, [1,totalSamples]);
			isCorrectPrediction			= modelPrediction == responses_actual;
			percentResponsesPredicted	= sum(isCorrectPrediction,1)./nQuestions;
		end
		
		function exportFigure(plotOptions, prefix_string, modelFilename)
			% TODO: Exporting is not the responsibility of PosteriorPrediction class, so we need to extract this up to Model subclasses. They call it as: obj.postPred.plot(obj.plotOptions, obj.modelFilename)
			if plotOptions.shouldExportPlots
				myExport(plotOptions.savePath,...
					'PosteriorPredictive',...
					'prefix', prefix_string,...
					'suffix', modelFilename,...
					'formats', plotOptions.exportFormats)
			end
		end
		
	end
	
end
