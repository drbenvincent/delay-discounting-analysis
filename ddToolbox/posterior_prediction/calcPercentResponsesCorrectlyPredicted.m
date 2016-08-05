function percentResponsesPredicted = calcPercentResponsesCorrectlyPredicted(responses_predictedMCMC, responses_actual)
%% Calculate % responses predicted by the model
totalSamples				= size(responses_predictedMCMC,2);
nQuestions					= numel(responses_actual);
modelPrediction				= zeros(size(responses_predictedMCMC));
modelPrediction(responses_predictedMCMC>=0.5)=1;
responses_actual			= repmat(responses_actual, [1,totalSamples]);
isCorrectPrediction			= modelPrediction == responses_actual;
percentResponsesPredicted	= sum(isCorrectPrediction,1)./nQuestions;
end