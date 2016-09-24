function [score] = calcGoodnessOfFitDistribution(responses_predictedMCMC, responses_actual)
% Expand the participant responses so we can do vectorised calculations below
totalSamples			= size(responses_predictedMCMC,2);
responses_actual		= repmat(responses_actual, [1,totalSamples]);
responses_control_model = ones(size(responses_actual)) .* 0.5;

score = calcLogOdds(...
	calcDataLikelihood(responses_actual, responses_predictedMCMC),...
	calcDataLikelihood(responses_actual, responses_control_model));
end