function figParticipantLOGK(plotdata)

rows=1; cols=4;

subplot(rows, cols, 1)
epsilon_alpha = mcmc.BivariateDistribution(plotdata.samples.posterior.epsilon,...
	plotdata.samples.posterior.alpha,...
	'xLabel','error rate, $\epsilon$',...
	'ylabel','comparison accuity, $\alpha$',...
	'pointEstimateType', plotdata.pointEstimateType);

subplot(rows, cols, 2)
plotPsychometricFunc(plotdata.samples, plotdata.pointEstimateType);

subplot(rows, cols, 3)
logk = mcmc.UnivariateDistribution(plotdata.samples.posterior.logk(:),...
 'killYAxis', true,...
 'xLabel', '$\log(k)$',...
 'pointEstimateType', plotdata.pointEstimateType);

% Plot in 2D data space
subplot(rows, cols, 4)
plotDiscountFunction(plotdata);

end
