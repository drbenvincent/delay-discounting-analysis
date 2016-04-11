function figParticipantLOGK(pSamples, pData, logkMEAN, epsilonMEAN, alphaMEAN)
rows=1; cols=4;

% BIVARIATE PLOT: lapse rate & comparison accuity
subplot(rows, cols, 1)
BivariateDistribution(pSamples.epsilon(:), pSamples.alpha(:),...
	'xLabel','error rate, $\epsilon$',...
	'ylabel','comparison accuity, $\alpha$')

% PSYCHOMETRIC FUNCTION (using my posterior-prediction-plot-matlab GitHub repository)
subplot(rows, cols, 2)
plotPsychometricFunc(pSamples, [epsilonMEAN, alphaMEAN])

% logk
subplot(rows, cols, 3)
plotPriorPostHist([], pSamples.logk(:));
%histogram(pSamples.logk(:))
removeYaxis()
axis square
xlabel('$\log(k)$', 'interpreter', 'latex')

% TODO:
% Plot in 2D data space
subplot(rows, cols, 4)
if ~isempty(pData)
	% participant level
	plot2DdataSpace(pData, logkMEAN, pSamples.logk(:))
else
	% for group level where there is no data
	plotDiscountFunction(logkMEAN, pSamples.logk(:));
end

end
