function figParticipantME(pSamples, pData, mMEAN, cMEAN, epsilonMEAN, alphaMEAN, opts)
  rows=1; cols=5;

  subplot(rows, cols, 1)
  BivariateDistribution(pSamples.epsilon(:), pSamples.alpha(:),...
  	'xLabel','error rate, $\epsilon$',...
  	'ylabel','comparison accuity, $\alpha$');

  subplot(rows, cols, 2)
  plotPsychometricFunc(pSamples, [epsilonMEAN, alphaMEAN]);

  subplot(rows, cols, 3)
  BivariateDistribution(pSamples.m(:), pSamples.c(:),...
  	'xLabel','slope, $m$',...
  	'ylabel','intercept, $c$');

  subplot(rows, cols, 4)
  plotMagnitudeEffect(pSamples, [mMEAN, cMEAN]);

  % Plot in 3D data space
  subplot(rows, cols, 5)
  if ~isempty(pData)
		% participant, we have data
		plotDiscountSurface([mMEAN cMEAN], opts, 'data', pData);
	else
		% no data for group level
		plotDiscountSurface([mMEAN, cMEAN], opts);
  end
  % 			set(gca,'XTick',[10 100])
  % 			set(gca,'XTickLabel',[10 100])
  % 			set(gca,'XLim',[10 100])
end
