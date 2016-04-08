function figParticipantME(pSamples, pData, mMEAN, cMEAN, epsilonMEAN, alphaMEAN, opts)
  rows=1; cols=5;

  % BIVARIATE PLOT: lapse rate & comparison accuity
  subplot(rows, cols, 1)
  plot2DErrorAccuity(pSamples.epsilon(:), pSamples.alpha(:), epsilonMEAN, alphaMEAN);

  % PSYCHOMETRIC FUNCTION (using my posterior-prediction-plot-matlab GitHub repository)
  subplot(rows, cols, 2)
  plotPsychometricFunc(pSamples, [epsilonMEAN, alphaMEAN])

  % M/C bivariate plot
  subplot(rows, cols, 3)
  plot2Dmc(pSamples.m(:), pSamples.c(:), mMEAN, cMEAN);

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
