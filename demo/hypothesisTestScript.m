function hypothesisTestScript(modelObject)
% This is an example script written to show how we can draw conclusions
% from the data analysis.
%
% In this example, we test the hypothesis that the group level slope (G^m)
% is less than one.

figure

% extract the samples from the variables of interest
priorSamples = modelObject.mcmc.getSamplesAsMatrix({'m_group_prior'});
posteriorSamples = modelObject.mcmc.getSamplesAsMatrix({'m_group'});

%% METHOD 1 - Hypothesis test
subplot(1,2,1)
HT_BayesFactor(priorSamples, posteriorSamples)

%% METHOD 2 - examine credible interval
subplot(1,2,2)
mcmc.UnivariateDistribution(posteriorSamples,...
	'priorSamples', priorSamples,...
	'plotStyle','hist');

end
