function hypothesisTestScript(modelObject)
% This is an example script written to show how we can draw conclusions
% from the data analysis.
%
% In this example, we test the hypothesis that the group level slope (G^m)
% is less than one.

assert(isa(modelObject,'ModelHierarchicalME'),...
	'This example script is designed to work with models of type "ModelHierarchicalME".')

% extract prior samples
priorSamples = modelObject.coda.getSamplesAsMatrix({'m_prior'});

% extract group-level posterior samples
assert(modelObject.data.isUnobservedPartipantPresent(),'We seem to not have group level estimates')
posteriorSamples = modelObject.coda.getSamplesFromExperimentAsMatrix(...
	modelObject.data.getIndexOfUnobservedParticipant(),...
	{'m'});


figure

%% METHOD 1 - Hypothesis test
subplot(1,2,1)
HT_BayesFactor(priorSamples, posteriorSamples, '<', 0)

%% METHOD 2 - examine credible interval
subplot(1,2,2)
mcmc.UnivariateDistribution(posteriorSamples,...
	'priorSamples', priorSamples,...
	'plotStyle','hist');
title('Parameter Estimation')

end
