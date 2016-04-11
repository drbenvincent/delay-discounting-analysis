function figParticipantLOGK(pSamples, pData, logkMEAN, epsilonMEAN, alphaMEAN)
rows=1; cols=4;

subplot(rows, cols, 1)
BivariateDistribution(pSamples.epsilon(:), pSamples.alpha(:),...
	'xLabel','error rate, $\epsilon$',...
	'ylabel','comparison accuity, $\alpha$');

subplot(rows, cols, 2)
plotPsychometricFunc(pSamples, [epsilonMEAN, alphaMEAN]);

subplot(rows, cols, 3)
UnivariateDistribution(pSamples.logk(:),...
 'killYAxis', true,...
 'xLabel', '$\log(k)$');

% Plot in 2D data space
subplot(rows, cols, 4)
if ~isempty(pData)
	% participant level, we have data
	plotDiscountFunction(logkMEAN, pSamples.logk(:),'data',pData);
else
	% for group level where there is no data
	plotDiscountFunction(logkMEAN, pSamples.logk(:));
end

end
