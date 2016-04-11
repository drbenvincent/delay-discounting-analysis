function figParticipantME(pSamples, pData, mMEAN, cMEAN, epsilonMEAN, alphaMEAN, opts)
  rows=1; cols=5;

  subplot(rows, cols, 1)
  BivariateDistribution(pSamples.epsilon(:), pSamples.alpha(:),...
  	'xLabel','error rate, $\epsilon$',...
  	'ylabel','comparison accuity, $\alpha$');

  subplot(rows, cols, 2)
  plotPsychometricFunc(pSamples, [epsilonMEAN, alphaMEAN])

  subplot(rows, cols, 3)
  BivariateDistribution(pSamples.m(:), pSamples.c(:),...
  	'xLabel','slope, $m$',...
  	'ylabel','intercept, $c$');

  subplot(rows, cols, 4)
  plotMagnitudeEffect(pSamples, [mMEAN, cMEAN])



  % TODO: combine into a class?
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
