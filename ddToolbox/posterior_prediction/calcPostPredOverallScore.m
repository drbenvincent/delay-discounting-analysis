function score = calcPostPredOverallScore(responses_predicted, responses_actual)
% Calculate log posterior odds of data under the model and a
% control model where prob of responding is 0.5.
responses_control_model = ones(size(responses_predicted)).*0.5;

score = calcLogOdds(...
	calcDataLikelihood(responses_actual, responses_predicted'),...
	calcDataLikelihood(responses_actual, responses_control_model'));
end