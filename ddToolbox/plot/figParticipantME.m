function figParticipantME(pSamples, pData, mMEAN, cMEAN, epsilonMEAN, alphaMEAN, opts)
  rows=1; cols=5;

  % BIVARIATE PLOT: lapse rate & comparison accuity
  subplot(rows, cols, 1)
  plotBivariateDensity(pSamples.epsilon(:), pSamples.alpha(:),...
  	'xLabel','error rate, $\epsilon$',...
  	'ylabel','comparison accuity, $\alpha$')

  % PSYCHOMETRIC FUNCTION (using my posterior-prediction-plot-matlab GitHub repository)
  subplot(rows, cols, 2)
  plotPsychometricFunc(pSamples, [epsilonMEAN, alphaMEAN])

  % M/C bivariate plot
  subplot(rows, cols, 3)
  plotBivariateDensity(pSamples.m(:), pSamples.c(:),...
  	'xLabel','slope, $m$',...
  	'ylabel','intercept, $c$')

  % PLOT magnitude effect
  subplot(rows, cols, 4)
  plotMagnitudeEffect(pSamples, [mMEAN, cMEAN])

  % Plot in 3D data space
  subplot(rows, cols, 5)
  if ~isempty(pData)
    plot3DdataSpace(pData, [mMEAN, cMEAN])
  else
%     opts.maxlogB	= max(abs(obj.data.observedData.B(:)));
%     opts.maxD		= max(obj.data.observedData.DB(:));
    plotDiscountSurface(mMEAN, cMEAN, opts);
  end
  % 			set(gca,'XTick',[10 100])
  % 			set(gca,'XTickLabel',[10 100])
  % 			set(gca,'XLim',[10 100])
end
