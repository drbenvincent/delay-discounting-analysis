function postPred = calcPosteriorPredictive(obj)
    %Calculate various posterior predictive measures
    % data saved to postPred(p).xxx

    % TODO: remove obj being passed in?

    display('Calculating posterior predictive measures...')
    nParticipants = obj.data.nParticipants;

    %% Calculate various posterior predictive measures

    for p=1:nParticipants
        % get data
        trialIndOfThisParicipant = obj.data.observedData.ID==p;
        P = obj.mcmc.getPChooseDelayed(trialIndOfThisParicipant);
        nQuestions = size(P,1);
        totalSamples = size(P,2);
        participantResponses = obj.data.participantLevel(p).table.R;
        participantPredictedResponses = obj.mcmc.getParticipantPredictedResponses(trialIndOfThisParicipant);

        % Calculate metrics
        postPred(p).score = calcPostPredOverallScore(participantPredictedResponses, participantResponses);

        [postPred(p).GOF_distribtion,...
            postPred(p).percentPredictedDistribution] ...
            = calcGoodnessOfFitDistribution(nQuestions, totalSamples, P, participantResponses );

        % TODO: make judgements about whether model is good enough
    end
end

%% Posterior predictive model checking #1
% This approach comes up with a single goodness of fit score.
% It is the log ratio between the posterior predicted responses
% of the model and the predicted responses of a control model
% (which responses randomly).
% NOTE: That this is based upon Rpostpred.

function score = calcPostPredOverallScore(predicted, participantResponses)
    % Calculate log posterior odds of data under the model and a
    % control model where prob of responding is 0.5.
    % Responses are Bernoulli distributed, which is a special case
    % of the Binomial with 1 event.
    prob = @(responses, predicted) prod(binopdf(responses, ...
        ones(size(responses)),...
        predicted));
    % Calculate fit between posterior predictive responses and actual
    %participant(p).predicted = obj.getParticipantPredictedResponses(p);
    %participantResponses = obj.data.participantLevel(p).table.R;
    pModel = prob(participantResponses, predicted');

    % calculate fit between control (random) model and actual
    % responses
    controlPredictions = ones(size(participantResponses)) .* 0.5;
    pRandom = prob(participantResponses, controlPredictions);

    score = log( pModel ./ pRandom);
end

%% Posterior predictive model checking #2
% This takes a different approach. Because we calculate
% P(choose delayed) directly (variable P in the model) then we
% haev these predicted probabilities for every MCMC sample.
% This means we can compute a distribution of model fits
% compared to the control model.
% We can then examine whether the 95% CI overlaps with 1, which
% we can take as indicating the model does not predict people's
% responases better than chance.
function [GOF_distribtion, percentPredictedDistribution] = calcGoodnessOfFitDistribution(nQuestions, totalSamples, P, participantResponses )
    % return a distribution of goodness of fit scores. One
    % value for each MCMC sample.
    % This is quite memory-intensive, so we are calculating it
    % on demand and not storing it.

    % Expand the participant responses so we can do vectorised
    % calculations below
    participantResponsesREP = repmat(participantResponses, [1,totalSamples]);

    %% Calculate % responses predicted by the model
    %modelPrediction(P<0.5)=0;
    modelPrediction = zeros(size(P));
    modelPrediction(P>=0.5)=1;
    isCorrectPrediction = modelPrediction == participantResponsesREP;
    percentPredictedDistribution = sum(isCorrectPrediction,1)./nQuestions;

    %% Calculate goodness of fit
    % P(responses | model)
    % product is over trials
    pModel = prod(binopdf(participantResponsesREP, ones(size(participantResponsesREP)), P));

    % P(responses | control model)
    controlP = ones(size(P)).*0.5;
    pControl = prod(binopdf(participantResponsesREP, ones(size(participantResponsesREP)), controlP));

    % Calculate log goodness of fit ratio
    GOF_distribtion = log(pModel./pControl);
end
